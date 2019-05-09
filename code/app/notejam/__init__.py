import os
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.login import LoginManager
from flask.ext.mail import Mail

app = Flask(__name__)
app.config.from_object('notejam.config.Config')
db = SQLAlchemy(app)

from models import *

db.init_app(app)
db.create_all()
db.session.commit()

login_manager = LoginManager()
login_manager.login_view = "signin"
login_manager.init_app(app)

mail = Mail()
mail.init_app(app)

from notejam import views
