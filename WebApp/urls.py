from django.conf.urls import url
from . import views

urlpatterns = [
    url(r'^$', views.enter_data, name='enter_data'),
    url(r'^postlist$', views.post_list, name='post_list'),
    url(r'^post/new/$', views.post_new, name='post_new'),
]