import decimal

from django.contrib.auth.decorators import login_required, user_passes_test
from django.http import HttpResponseRedirect
from django.shortcuts import render, get_object_or_404
from django.urls import reverse
from datetime import date, datetime, timezone

from security_guard.models import VisitorParkingUse, InhabitantParkingUse, VisitorVehicle, Visitor, SecurityGuard, Shift, VisitorsPayments
from admin_co_ownership.models import CoOwnership, ParkingPlace, InhabitantVehicle, Configuration
from . import is_security_guard, set_default_context
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
    context = set_default_context(request.user)
    if not context['shift_started']:
        context['action'] = 'error'
        return render(request, 'security_guard/shift_error.html', context=context)

    context['action'] = action
    if request.method == 'POST':
        form = GetParkingFromBarcodeForm(request.POST)
        if form.is_valid():
            barcode = form.cleaned_data['barcode']
            parking_place = ParkingPlace.objects.filter(barcode=barcode, user_type__in=[person, 'M'])
            if len(parking_place) == 0:
                context['action'] = 'parking not registered'
                return render(request, 'security_guard/parking_use.html', context=context)
            parking_place = parking_place[0]
            if action == 'entry':
                if parking_place.in_use:
                    context['action'] = 'in use'
                    return render(request, 'security_guard/parking_use.html', context=context)
                if person == 'I':
                    vehicles = InhabitantVehicle.objects.filter(parking_place=parking_place)
                    context['inhabitant_vehicles'] = vehicles
                    return render(request, 'security_guard/vehicles_for_parking_place.html', context=context)
                elif person == 'V':
                    vehicle = get_object_or_404(VisitorVehicle, pk=pk)
                    return HttpResponseRedirect(reverse('entryVisitorVehicle', kwargs={'pk': vehicle.id, 'barcode': barcode}))
            if action == 'departure':
                if not parking_place.in_use:
                    context['action'] = 'not in use'
                    return render(request, 'security_guard/parking_use.html', context=context)
                if person == 'I':
                    return HttpResponseRedirect(reverse('departureInhabitantVehicle', kwargs={'parking_place_id': parking_place.id}))
                elif person == 'V':
                    vehicle = get_object_or_404(VisitorVehicle, pk=pk)
                    return HttpResponseRedirect(reverse('departureVisitorVehicle', kwargs={'pk': vehicle.id, 'barcode': barcode}))
    else:
        form = GetParkingFromBarcodeForm()
    context['form'] = form
    return render(request, 'security_guard/barcode_parking_place.html', context=context)


@login_required
@user_passes_test(is_security_guard)
def entry_inhabitant_vehicle(request, pk):
    """
    :param request:
    :param pk:
    :return render:
    """
    context = set_default_context(request.user)
    if not context['shift_started']:
        context['action'] = 'error'
        return render(request, 'security_guard/shift_error.html', context=context)

    context['action'] = 'entry'
    vehicle = get_object_or_404(InhabitantVehicle, pk=pk)
    if vehicle.due_date < date.today():
        context['action'] = 'soat is due'
        return render(request, 'security_guard/parking_use.html', context=context)
    if not vehicle.owner.up_to_date:
        context['action'] = 'not up to date'
        return render(request, 'security_guard/parking_use.html', context=context)
    inhabitant_parking_use = InhabitantParkingUse()
    inhabitant_parking_use.vehicle = vehicle
    inhabitant_parking_use.save()
    parking_place = get_object_or_404(ParkingPlace, id=vehicle.parking_place_id)
    parking_place.in_use = True
    parking_place.save()
    return render(request, 'security_guard/parking_use.html', context=context)


@login_required
@user_passes_test(is_security_guard)
def departure_inhabitant_vehicle(request, parking_place_id):
    """
    :param parking_place_id:
    :param request:
    :return render:
    """
    context = set_default_context(request.user)
    if not context['shift_started']:
        context['action'] = 'error'
        return render(request, 'security_guard/shift_error.html', context=context)

    context['action'] = 'departure'
    parking_place = get_object_or_404(ParkingPlace, pk=parking_place_id)
    inhabitant_parking_use = InhabitantParkingUse.objects.filter(vehicle__parking_place=parking_place).latest('id')
    inhabitant_parking_use.departure_date = datetime.now(timezone.utc)
    inhabitant_parking_use.save()
    parking_place.in_use = False
    parking_place.save()
    return render(request, 'security_guard/parking_use.html', context=context)


@login_required
@user_passes_test(is_security_guard)
def entry_visitor_vehicle(request, pk, barcode):
    """
    :param request:
    :param pk:
    :param barcode:
    :return render:
    """
    context = set_default_context(request.user)
    if not context['shift_started']:
        context['action'] = 'error'
        return render(request, 'security_guard/shift_error.html', context=context)

    context['action'] = 'entry'
    vehicle = get_object_or_404(VisitorVehicle, pk=pk)
    visitor_parking_use = VisitorParkingUse()
    visitor_parking_use.vehicle = vehicle
    visitor_parking_use.save()
    parking_place = get_object_or_404(ParkingPlace, barcode=barcode)
    parking_place.in_use = True
    parking_place.save()
    return render(request, 'security_guard/parking_use.html', context=context)


@login_required
@user_passes_test(is_security_guard)
def departure_visitor_vehicle(request, pk, barcode):
    """
    :param pk:
    :param request:
    :param barcode:
    :return render:
    """
    context = set_default_context(request.user)
    if not context['shift_started']:
        context['action'] = 'error'
        return render(request, 'security_guard/shift_error.html', context=context)

    vehicle = get_object_or_404(VisitorVehicle, pk=pk)
    parking_place = get_object_or_404(ParkingPlace, barcode=barcode)
    visitor_parking_use = VisitorParkingUse.objects.filter(vehicle=vehicle).latest('id')
    if visitor_parking_use.departure_date is not None:
        context['action'] = 'not entry'
        return render(request, 'security_guard/parking_use.html', context=context)
    visitor_parking_use.departure_date = datetime.now(timezone.utc)
    parking_place.in_use = False
    co_ownership = context['co_ownership']
    configuration = get_object_or_404(Configuration, co_ownership=co_ownership)
    visit_payment_type = configuration.visit_payment_type
    dt = visitor_parking_use.departure_date - visitor_parking_use.entry_date
    if configuration.max_hours_before_change_payment_to_days > 0:
        hours = get_total_time_in_specific_format(dt.total_seconds(), 'H')
        if hours > configuration.max_hours_before_change_payment_to_days:
            multiplier = dt.days
            payment_value = float(configuration.payment_value_after_max_hours)
        else:
            multiplier = (get_multiplier_by_visit_payment_type(visit_payment_type, dt.total_seconds())
                          - float(configuration.grace_time))
            payment_value = get_payment_by_vehicule_type(vehicle.type, configuration)
    else:
        multiplier = (get_multiplier_by_visit_payment_type(visit_payment_type, dt.total_seconds())
                      - float(configuration.grace_time))
        payment_value = get_payment_by_vehicule_type(vehicle.type, configuration)
    multiplier = multiplier if multiplier > 0 else 0
    total_pay = payment_value * multiplier
    total_pay = round(total_pay, 2)
    visitor_parking_use.save()
    parking_place.save()
    money = decimal.Decimal(total_pay)
    shift = Shift.objects.latest('id')
    shift.final_money += money
    shift.save()
    visitor_payment = VisitorsPayments()
    visitor_payment.visitor = get_object_or_404(Visitor, pk=pk)
    visitor_payment.value = money
    visitor_payment.save()
    context['action'] = 'departureVisitor'
    context['money'] = total_pay
    return render(request, 'security_guard/parking_use.html', context=context)


def get_total_time_in_specific_format(seconds, format):
    days = int(seconds / 60 / 60 / 24)
    if format == 'D':
        return days
    hours = int(seconds / 60 / 60)
    if format == 'H':
        return hours
    minutes = int(seconds / 60)
    return minutes


def get_payment_by_vehicule_type(vehicle_type, configuration):
    if vehicle_type == 'C':
        return float(configuration.car_payment_value)
    elif vehicle_type == 'M':
        return float(configuration.motorcycle_payment_value)
    elif vehicle_type == 'B':
        return float(configuration.bicycle_payment_value)
    return 0.0


def get_multiplier_by_visit_payment_type(visit_payment_type, seconds):
    if visit_payment_type == 'H':
        return get_total_time_in_specific_format(seconds, 'H')
    elif visit_payment_type == 'M':
        return get_total_time_in_specific_format(seconds, 'M')
    elif visit_payment_type == 'D':
        return get_total_time_in_specific_format(seconds, 'D')
    return 0
