# from django.urls import path, include
# from rest_framework.routers import DefaultRouter
# from . import views

# router = DefaultRouter()
# router.register(r'treatment-plans', views.TreatmentPlanViewSet)
# router.register(r'patient-treatments', views.PatientTreatmentViewSet)
# router.register(r'progress-reports', views.ProgressReportViewSet)
# router.register(r'substances', views.SubstanceViewSet)

# urlpatterns = [
#     path('api/', include(router.urls)),
#     path('', include('api.urls'))
# ]

#adjusted to see if backend works 
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'screening', views.ScreeningTestViewSet, basename='screening')
router.register(r'treatment-plans', views.TreatmentPlanViewSet, basename='treatment-plans')
router.register(r'patient-treatments', views.PatientTreatmentViewSet, basename='patient-treatments')

urlpatterns = [
    path('', include(router.urls)),
]