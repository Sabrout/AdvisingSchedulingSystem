# -*- coding: utf-8 -*-
# Generated by Django 1.10.4 on 2017-01-17 17:15
from __future__ import unicode_literals

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('WebApp', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Student',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('curr', models.TextField()),
                ('history', models.TextField()),
                ('obligatory', models.TextField()),
                ('credits', models.TextField()),
                ('excel', models.TextField()),
                ('probation', models.BinaryField()),
                ('author', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]