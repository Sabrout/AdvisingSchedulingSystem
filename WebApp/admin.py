from django.contrib import admin
from .models import Post
from .models import Student

admin.site.register(Post)
admin.site.register(Student)