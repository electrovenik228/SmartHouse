from django.urls import path
from . import views

urlpatterns = [
    path("login", views.login_page, name="login"),
    path("dashboard", views.dashboard, name="dashboard"),
    path("history", views.history, name="history"),
]
