# -*- coding: utf-8 -*-
# Generated by Django 1.10.4 on 2017-01-17 17:21
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('WebApp', '0003_auto_20170117_1919'),
    ]

    operations = [
        migrations.AlterField(
            model_name='student',
            name='credits',
            field=models.IntegerField(),
        ),
    ]
