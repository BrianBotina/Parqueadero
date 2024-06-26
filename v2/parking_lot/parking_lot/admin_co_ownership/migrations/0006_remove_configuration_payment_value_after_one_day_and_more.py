# Generated by Django 4.2.11 on 2024-05-04 02:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('admin_co_ownership', '0005_configuration_payment_value_after_one_day'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='configuration',
            name='payment_value_after_one_day',
        ),
        migrations.AddField(
            model_name='configuration',
            name='max_hours_before_change_payment_to_days',
            field=models.IntegerField(default=0, verbose_name='Cantidad de horas antes de empezar a cobrar por día'),
        ),
        migrations.AddField(
            model_name='configuration',
            name='payment_value_after_max_hours',
            field=models.DecimalField(decimal_places=2, default=1, max_digits=10, verbose_name='Valor a cobrar después de la cantidad maxima de horas'),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='configuration',
            name='grace_time',
            field=models.IntegerField(default=0, verbose_name='Tiempo de gracia para el periodo especificado'),
        ),
    ]
