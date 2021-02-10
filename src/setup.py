from setuptools import setup, find_packages

setup (
  name                 = "todobackend",
  version              = "0.1.0",
  description          = "Todobackend Django REST service",
  packages             = find_packages(),
  include_package_data = True,
  scripts              = ["manage.py"],
  install_requires     = [  "asgiref==3.3.1",
                            "Django==3.1.6",
                            "django-cors-headers==3.7.0",
                            "djangorestframework==3.12.2",
                            "mysqlclient==2.0.3",
                            "pytz==2021.1",
                            "sqlparse==0.4.1",
                            "uwsgi>=2.0"],
  extras_require       = {
                            "test": [
                                "colorama==0.4.4",
                                "coverage==5.4",
                                "django-nose==1.4.7",
                                "nose==1.3.7",
                                "pinocchio==0.4.2"
                            ]
                         }
)