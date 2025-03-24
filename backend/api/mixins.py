from rest_framework import permissions


class UserOwnershipMixin:
    """
    Mixin to ensure users can only access their own data.
    Assumes the model has a 'user' field.
    """

    def get_queryset(self):
        """
        Filter queryset to return only objects that belong to the current user
        """
        # Make sure the base queryset is available
        if not hasattr(self, 'queryset') and not super().get_queryset:
            raise ValueError(f"{self.__class__.__name__} must define queryset or override get_queryset()")

        # Get base queryset from the parent ViewSet
        try:
            qs = super().get_queryset()
        except:
            qs = self.queryset.all()

        # Filter by the current user
        return qs.filter(user=self.request.user)

    def perform_create(self, serializer):
        """
        Set the user field to the current user when creating objects
        """
        serializer.save(user=self.request.user)