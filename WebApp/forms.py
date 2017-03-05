from django import forms

from .models import Post
from .models import Student

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ('title', 'text',)

class StudentForm(forms.ModelForm):
    class Meta:
        model = Student
        fields = ('curriculum', 'history','obligatory', 'credits','excel', 'probation',)