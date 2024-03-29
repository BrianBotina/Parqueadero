import decimal

from django.contrib.auth.decorators import login_required, user_passes_test
from django.http import HttpResponseRedirect
from django.shortcuts import render, get_object_or_404
from django.urls import reverse
from django.utils import timezone

from security_guard.models import VisitorParkingUse, InhabitantParkingUse, VisitorVehicle, Visitor, SecurityGuard, Shift, VisitorsPayments
from admin_co_ownership.models import CoOwnership, ParkingPlace, InhabitantVehicle, Configuration
from . import is_security_guard
from security_guard.forms import GetParkingFromBarcodeForm


@login_required
@user_passes_test(is_security_guard)
def barcode_parking_place(request, action, person, pk=None):
    """
    :param pk:
    :param person:
    :param action:
    :param request:
    :return render:
    """
    context = {
        'action': action
    }
    if request.method == 'POST':
        form = GetParkingFromBarcodeForm(request.POST)
        if form.is_valid():
            barcode = form.cleaned_data['barcode']
            parking_place = get_object_or_404(ParkingPlace, barcode=barcode)
            if action == 'entry':
                if parking_place.in_use:
                    return render(request, 'security_guard/parking_use.html', {'action': 'in use'})
                if person == 'I':
                    vehicles = InhabitantVehicle.objects.filter(parking_place=parking_place)
                    context['inhabitant_vehicles'] = vehicles
                    return render(request, 'security_guard/vehicles_for_parking_place.html', context=context)
                elif person == 'V':
                    vehicle = get_object_or_404(VisitorVehicle, pk=pk)
                    vehicle.parking_place = parking_place
                    vehicle.save()
                    return HttpResponseRedirect(reverse('entryVisitorVehicle', kwargs={'pk': vehicle.id}))
            if action == 'departure':
                if not parking_place.in_use:
                    return render(request, 'security_guard/parking_use.html', {'action': 'not in use'})
                return HttpResponseRedirect(reverse('departureInhabitantVehicle', kwargs={'parking_place_id': parking_place.id}))
    else:
        form = GetParkingFromBarcodeForm()
    return render(request, 'security_guard/barcode_parking_place.html', {'form': form})


@login_required
@user_passes_test(is_security_guard)
def entry_inhabitant_vehicle(request, pk):
    """
    :param request:
    :param pk:
    :return render:
    """
    vehicle = get_object_or_404(InhabitantVehicle, pk=pk)
    if vehicle.due_date < timezone.now():
        return render(request, 'security_guard/parking_use.html', {'action': 'soat is due'})
    if not vehicle.owner.up_to_date:
        return render(request, 'security_guard/parking_use.html', {'action': 'not up to date'})
    inhabitant_parking_use = InhabitantParkingUse()
    inhabitant_parking_use.vehicle = vehicle
    inhabitant_parking_use.save()
    parking_place = get_object_or_404(ParkingPlace, id=vehicle.parking_place_id)
    parking_place.in_use = True
    parking_place.save()
    return render(request, 'security_guard/parking_use.html', {'action': 'entry'})


@login_required
@user_passes_test(is_security_guard)
def departure_inhabitant_vehicle(request, parking_place_id):
    """
    :param parking_place_id:
    :param request:
    :return render:
    """
    parking_place = get_object_or_404(ParkingPlace, pk=parking_place_id)
    inhabitant_parking_use = InhabitantParkingUse.objects.filter(vehicle__parking_place=parking_place).latest('id')
    inhabitant_parking_use.departure_date = timezone.now()
    inhabitant_parking_use.save()
    parking_place.in_use = False
    parking_place.save()
    return render(request, 'security_guard/parking_use.html', {'action': 'departure'})


@login_required
@user_passes_test(is_security_guard)
def entry_visitor_vehicle(request, pk):
    """
    :param request:
    :param pk:
    :return render:
    """
    vehicle = get_object_or_404(VisitorVehicle, pk=pk)
    visitor_parking_use = VisitorParkingUse()
    visitor_parking_use.vehicle = vehicle
    visitor_parking_use.save()
    parking_place = get_object_or_404(ParkingPlace, id=vehicle.parking_place_id)
    parking_place.in_use = True
    parking_place.save()
    return render(request, 'security_guard/parking_use.html', {'action': 'entry'})


@login_required
@user_passes_test(is_security_guard)
def departure_visitor_vehicle(request, pk):
    """
    :param pk:
    :param request:
    :return render:
    """
    vehicle = get_object_or_404(VisitorVehicle, pk=pk)
    parking_place = vehicle.parking_place
    visitor_parking_use = VisitorParkingUse.objects.filter(vehicle=vehicle).latest('id')
    if visitor_parking_use.departure_date is not None:
        return render(request, 'security_guard/parking_use.html', {'action': 'not entry'})
    visitor_parking_use.departure_date = timezone.now()
    parking_place.in_use = False
    security_guard = get_object_or_404(SecurityGuard, user=request.user)
    co_ownership = security_guard.co_ownership
    configuration = get_object_or_404(Configuration, co_ownership=co_ownership)
    visit_payment_type = configuration.visit_payment_type
    multiplier = 0
    payment_value = 0.0
    dt = visitor_parking_use.departure_date - visitor_parking_use.entry_date
    if visit_payment_type == 'H':
        multiplier = dt.seconds / 60 / 60
    elif visit_payment_type == 'M':
        multiplier = decimal.Decimal(dt.seconds / 60)
    elif visit_payment_type == 'D':
        multiplier = decimal.Decimal(dt.days / 7)
    if vehicle.type == 'C':
        payment_value = float(configuration.car_payment_value)
    elif vehicle.type == 'M':
        payment_value = float(configuration.motorcycle_payment_value)
    elif vehicle.type == 'B':
        payment_value = float(configuration.bicycle_payment_value)
    multiplier -= float(configuration.grace_time)
    multiplier = multiplier if multiplier > 0 else 0
    total_pay = payment_value * multiplier
    total_pay = round(total_pay, 2)
    visitor_parking_use.save()
    parking_place.save()
    return render(request, 'security_guard/total_to_pay.html', {'pk': vehicle.owner.id, 'money': total_pay})


@login_required
@user_passes_test(is_security_guard)
def make_payment(request, pk, money):
    """
    :param pk:
    :param request:
    :param money:
    :return:
    """
    money = decimal.Decimal(money)
    shift = Shift.objects.latest('id')
    shift.final_money += money
    shift.save()
    visitor_payment = VisitorsPayments()
    visitor_payment.visitor = get_object_or_404(Visitor, pk=pk)
    visitor_payment.value = money
    visitor_payment.save()
    return render(request, 'security_guard/parking_use.html', {'action': 'departure'})