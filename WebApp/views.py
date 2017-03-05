from django.shortcuts import render
from .models import Post
from .models import Student
from django.utils import timezone
from .forms import PostForm
from .forms import StudentForm
from django.shortcuts import redirect
import Parse
import openpyxl as ox


Curriculum = ""
History = ""
Obligatory = ""
Schedule = ""
Credits = 0
Probation = False


# Create your views here.
def post_list(request):
    posts = Post.objects.filter(published_date__lte=timezone.now()).order_by('published_date')
    return render(request, 'WebApp/post_list.html', {'posts': posts})

def post_new(request):
    if request.method == "POST":
        form = PostForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.published_date = timezone.now()
            post.save()
            return redirect('post_new')
    else:
        form = PostForm()
    return render(request, 'WebApp/post_edit.html', {'form': form})

def enter_data(request):
    if request.method == "POST":
        form = StudentForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.save()
            # Parse Here
            Schedule = Parse.parse_excel(ox.load_workbook("WebApp/data.xlsx"))
            Curriculum = Parse.parse_curr(post.curriculum)
            History = Parse.parse_history(post.history)
            Obligatory = Parse.parse_oblig(post.obligatory)

            Credits = post.credits
            Probation = post.probation

            # print("Curriculum")
            # print("------------")
            # print(Curriculum)
            # print("__________________________________________")
            # print("History")
            # print("------------")
            # print(History)
            # print("__________________________________________")
            # print("Obligatory")
            # print("------------")
            # print(Obligatory)
            # print("__________________________________________")
            # print("Schedule")
            # print("------------")
            # print(Schedule)
            # print("__________________________________________")
            # print("Credits")
            # print("------------")
            # print(str(Credits))
            # print("__________________________________________")
            # print("Probation")
            # print("------------")
            # print(str(Probation))
            # print("__________________________________________")
            query = Parse.final_parse(Curriculum, History, Obligatory, Schedule, Credits, Probation)
            print(Parse.run_prolog(query))


            return redirect('enter_data')
    else:
        form = StudentForm()
    return render(request, 'WebApp/index.html', {'form': form})


# Some Extra Parsing
