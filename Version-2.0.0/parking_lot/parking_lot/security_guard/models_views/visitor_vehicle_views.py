from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.http import HttpResponseRedirect
from django.shortcuts import render, get_object_or_404
from django.urls import reverse
from django.views.generic import ListView

from security_guard.models import VisitorVehicle, Visitor
from security_guard.forms import CreateVisitorVehicleForm
from . import is_security_guard


class VisitorVehicleListView(LoginRequiredMixin, UserPassesTestMixin, ListView):
    model = VisitorVehicle
    paginate_by = 10

    def get_queryset(self):
        owner_id = self.kwargs.get("pk", None)
        return VisitorVehicle.objects.filter(owner_id=owner_id)

    def get_context_data(self, **kwargs):
        context = super(VisitorVehicleListView, self).get_context_data(**kwargs)
        owner_id = self.kwargs.get('pk', None)
        action = self.kwargs.get('action', None)
        context['pk'] = owner_id
        context['action'] = action
        return context

    def test_func(self):
        return is_security_guard(self.request.user)


@login_required
@user_passes_test(is_security_guard)
def create_visitor_vehicle(request, pk):
    """
    :param pk:
    :param request:
    :return: render
    """
    owner = get_object_or_404(Visitor, pk=pk)
    if request.method == 'POST':

        # Create a form instance and populate it with data from the request (binding):
        form = CreateVisitorVehicleForm(request.POST, request.FILES)
        # Check if the form is valid:
        if form.is_valid():
            visitor_vehicle = form.save(commit=False)
            visitor_vehicle.owner = owner
            visitor_vehicle.save()
            # redirect to a new URL:
            return HttpResponseRedirect(reverse('barcodeVEntry', kwargs={'pk': visitor_vehicle.id}))
    else:
        form = CreateVisitorVehicleForm()
    return render(request, 'security_guard/visitorvehicle_form.html', {'form': form, 'pk': pk})
