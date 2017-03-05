from django.db import models
from django.utils import timezone


class Post(models.Model):
    author = models.ForeignKey('auth.User')
    title = models.CharField(max_length=2000)
    text = models.TextField()
    created_date = models.DateTimeField(default=timezone.now)
    published_date = models.DateTimeField(blank=True, null=True)

    def publish(self):
        self.published_date = timezone.now()
        self.save()

    def __str__(self):
        return self.title

class Student(models.Model):
    author = models.ForeignKey('auth.User')
    curriculum = models.TextField()
    history = models.TextField()
    obligatory = models.TextField()
    credits = models.IntegerField()
    excel = models.TextField()
    probation = models.BooleanField()

    def submit(self):
        self.save()

    def __str__(self):
        return self.curriculum