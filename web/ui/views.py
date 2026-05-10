from django.shortcuts import render
from django.conf import settings


def _ctx(request):
    return {"API_URL": settings.API_URL, "WS_URL": settings.WS_URL}


def login_page(request):
    return render(request, "ui/login.html", _ctx(request))


def dashboard(request):
    return render(request, "ui/dashboard.html", _ctx(request))


def history(request):
    return render(request, "ui/history.html", _ctx(request))
