# treatment_plans/views.py
from bson import ObjectId
from rest_framework import viewsets, permissions, status, serializers
from rest_framework.response import Response
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from .models import TreatmentPlan, PlanActivity, UserTreatmentPlan
from .serializers import TreatmentPlanSerializer, PlanActivitySerializer, UserTreatmentPlanSerializer
from assessment.models import AssistQuestionnaire
from assessment.ml_integration import AssessmentMLService
from django.utils import timezone


class TreatmentPlanViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TreatmentPlan.objects.all()
    serializer_class = TreatmentPlanSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        """
        Override get_object to handle MongoDB ObjectIds in the URL
        """
        queryset = self.filter_queryset(self.get_queryset())

        # Get the lookup value from the URL
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        lookup_value = self.kwargs[lookup_url_kwarg]

        # Try to convert to ObjectId if it's a string
        try:
            if isinstance(lookup_value, str) and len(lookup_value) == 24:
                lookup_value = ObjectId(lookup_value)
        except:
            pass

        # Use _id instead of id for lookup
        filter_kwargs = {'_id': lookup_value}
        obj = get_object_or_404(queryset, **filter_kwargs)

        # Check permissions
        self.check_object_permissions(self.request, obj)

        return obj

    @action(detail=False, methods=['get'])
    def recommend(self, request):
        """Get ML-based plan recommendation for the current user"""
        try:
            # Get user's latest questionnaire
            latest_questionnaire = AssistQuestionnaire.objects.filter(
                user=request.user
            ).order_by('-date_completed').first()

            if not latest_questionnaire:
                return Response(
                    {"detail": "No assessment found. Please complete the ASSIST questionnaire first."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Get recommendation using ML
            recommendation = AssessmentMLService.predict_treatment_plan(
                latest_questionnaire,
                {'user_id': request.user.id, 'username': request.user.username}
            )

            # Find the recommended plan
            try:
                recommended_plan = TreatmentPlan.objects.get(name=recommendation['recommended_plan'])
                plan_data = self.get_serializer(recommended_plan).data

                return Response({
                    'plan': plan_data,
                    'recommendation_details': recommendation
                })
            except TreatmentPlan.DoesNotExist:
                return Response(
                    {"detail": "Recommended plan not found in database."},
                    status=status.HTTP_404_NOT_FOUND
                )
        except Exception as e:
            return Response(
                {"detail": f"Error getting recommendation: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class UserTreatmentPlanViewSet(viewsets.ModelViewSet):
    serializer_class = UserTreatmentPlanSerializer
    permission_classes = [permissions.IsAuthenticated]

    queryset = UserTreatmentPlan.objects.all()
    

    def get_queryset(self):
        return UserTreatmentPlan.objects.filter(user=self.request.user)

    def get_object(self):
        """
        Override get_object to handle MongoDB ObjectIds in the URL
        """
        queryset = self.filter_queryset(self.get_queryset())

        # Get the lookup value from the URL
        lookup_url_kwarg = self.lookup_url_kwarg or self.lookup_field
        lookup_value = self.kwargs[lookup_url_kwarg]

        # Try to convert to ObjectId if it's a string
        try:
            if isinstance(lookup_value, str) and len(lookup_value) == 24:
                lookup_value = ObjectId(lookup_value)
        except:
            pass

        # Use _id instead of id for lookup
        filter_kwargs = {'_id': lookup_value}
        obj = get_object_or_404(queryset, **filter_kwargs)

        # Check permissions
        self.check_object_permissions(self.request, obj)

        return obj

    def perform_create(self, serializer):
        try:
            # Check if user already has a treatment plan
            if UserTreatmentPlan.objects.filter(user=self.request.user).exists():
                raise serializers.ValidationError(
                    "You already have a selected treatment plan and cannot change it.")

            serializer.save(user=self.request.user)
        except serializers.ValidationError:
            raise
        except Exception as e:
            raise serializers.ValidationError(f"Error creating treatment plan: {str(e)}")

    # Custom action to select a treatment plan
    @action(detail=False, methods=['post'])
    def select(self, request):
        """Select a treatment plan"""
        try:
            print("Treatment plan select request data:", request.data)

            # List all available plans in the database
            all_plans = list(TreatmentPlan.objects.all())
            print(f"All plans in database: {[plan.name for plan in all_plans]}")

            # Check for required fields
            if 'planName' not in request.data:
                return Response(
                    {"detail": "planName is required."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Get start date from request or use current time
            start_date = request.data.get('startDate', timezone.now())
            if isinstance(start_date, str):
                from dateutil import parser
                try:
                    start_date = parser.parse(start_date)
                except:
                    print(f"Error parsing date: {start_date}")
                    start_date = timezone.now()

            # Find the plan by name - try multiple approaches
            plan_name = request.data.get('planName')
            plan = None

            # Method 1: Direct exact match
            try:
                plan = TreatmentPlan.objects.get(name=plan_name)
            except TreatmentPlan.DoesNotExist:
                pass

            # Method 2: Case-insensitive match
            if plan is None:
                try:
                    plan = TreatmentPlan.objects.get(name__iexact=plan_name)
                except TreatmentPlan.DoesNotExist:
                    pass

            # Method 3: Contains match
            if plan is None:
                matching_plans = TreatmentPlan.objects.filter(name__icontains=plan_name)
                if matching_plans.exists():
                    plan = matching_plans.first()

            # Method 4: First plan as fallback (if no plans match)
            if plan is None:
                # If still not found, suggest similar plans
                available_plans = list(TreatmentPlan.objects.all().values_list('name', flat=True))
                print(f"Plan '{plan_name}' not found. Available plans: {available_plans}")

                # If plans exist, use the first one as a fallback
                if TreatmentPlan.objects.exists():
                    plan = TreatmentPlan.objects.first()
                    print(f"Using first available plan as fallback: {plan.name}")
                else:
                    return Response(
                        {"detail": "No treatment plans found in database. Please initialize the database."},
                        status=status.HTTP_404_NOT_FOUND
                    )

            print(f"Selected plan: {plan.name}")

            # Check if user already has a plan
            existing_plan = UserTreatmentPlan.objects.filter(user=request.user).first()
            if existing_plan:
                print(f"User already has plan: {existing_plan.plan.name}")

                # For testing, delete the existing plan
                # existing_plan.delete()
                # print("Deleted existing plan for testing")

                return Response(
                    {"detail": "You already have a selected treatment plan and cannot change it."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Create user treatment plan
            user_plan = UserTreatmentPlan(
                user=request.user,
                plan=plan,
                start_date=start_date
            )
            user_plan.save()
            print(f"Successfully created user plan with plan: {plan.name}")

            serializer = self.get_serializer(user_plan)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Exception as e:
            import traceback
            print(f"Error in select: {str(e)}")
            traceback.print_exc()
            return Response(
                {"detail": f"Error selecting treatment plan: {str(e)}"},
                status=status.HTTP_400_BAD_REQUEST
            )

    # Disable update and delete operations on treatment plans
    def update(self, request, *args, **kwargs):
        return Response(
            {"detail": "You cannot modify your treatment plan once it has been selected."},
            status=status.HTTP_403_FORBIDDEN
        )

    def destroy(self, request, *args, **kwargs):
        return Response(
            {"detail": "You cannot delete your treatment plan once it has been selected."},
            status=status.HTTP_403_FORBIDDEN
        )

    @action(detail=False, methods=['get'])
    def current(self, request):
        try:
            plan = UserTreatmentPlan.objects.get(user=request.user)
            serializer = self.get_serializer(plan)
            return Response(serializer.data)
        except UserTreatmentPlan.DoesNotExist:
            return Response({"detail": "No treatment plan found."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response(
                {"detail": f"Error retrieving treatment plan: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['get'])
    def status(self, request):
        """Check if user has completed assessment"""
        try:
            # Check if user has completed assessment
            has_completed = AssistQuestionnaire.objects.filter(
                user=request.user
            ).exists()

            return Response({"hasCompleted": has_completed})
        except Exception as e:
            return Response(
                {"detail": f"Error checking assessment status: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['get'])
    def progress(self, request):
        """Get user's progress in their treatment plan"""
        try:
            user_plan = UserTreatmentPlan.objects.get(user=request.user)

            # Get start date
            start_date = user_plan.start_date

            # Get current plan details
            plan = user_plan.plan

            # Get task completion statistics - avoid using filter().count() with MongoDB
            from tasks.models import Task
            all_tasks = list(Task.objects.filter(user=request.user))
            total_tasks = len(all_tasks)

            # Count completed tasks manually
            completed_tasks = sum(1 for task in all_tasks if task.is_completed)

            # Calculate days in program
            from django.utils import timezone
            current_date = timezone.now()
            days_in_program = (current_date - start_date).days

            # Get milestone information based on plan
            milestones = [
                {"name": "First Week", "days": 7, "completed": days_in_program >= 7},
                {"name": "First Month", "days": 30, "completed": days_in_program >= 30},
                {"name": "Three Months", "days": 90, "completed": days_in_program >= 90},
                {"name": "Six Months", "days": 180, "completed": days_in_program >= 180},
                {"name": "One Year", "days": 365, "completed": days_in_program >= 365},
            ]

            # Get next milestone
            next_milestone = next((m for m in milestones if not m["completed"]), None)

            return Response({
                "plan_name": plan.name,
                "days_in_program": days_in_program,
                "task_completion": {
                    "total": total_tasks,
                    "completed": completed_tasks,
                    "completion_rate": (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0
                },
                "milestones": milestones,
                "next_milestone": next_milestone,
                "start_date": start_date
            })

        except UserTreatmentPlan.DoesNotExist:
            return Response({"detail": "No treatment plan found."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response(
                {"detail": f"Error retrieving progress: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )