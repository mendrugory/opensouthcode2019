import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    DEBUG = False
    TESTING = False
    SECRET_KEY = 'notejam-flask-secret-key'
    CSRF_ENABLED = True
    CSRF_SESSION_KEY = 'notejam-flask-secret-key'
    MYSQL_DATABASE_USER = os.getenv('MYSQL_DATABASE_USER', "root")
    MYSQL_DATABASE_PASSWORD = os.getenv('MYSQL_DATABASE_PASSWORD', "password")
    MYSQL_DATABASE_HOST = os.getenv('MYSQL_DATABASE_HOST', "mysql")
    MYSQL_DATABASE_DB = os.getenv('MYSQL_DATABASE_DB', "notejam")
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://{}:{}@{}/{}'.format(MYSQL_DATABASE_USER, MYSQL_DATABASE_PASSWORD, MYSQL_DATABASE_HOST, MYSQL_DATABASE_DB)


class ProductionConfig(Config):
    DEBUG = False


class DevelopmentConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class TestingConfig(Config):
    TESTING = True
    SECRET_KEY = 'notejam-flask-secret-key'
    CSRF_ENABLED = False
    CSRF_SESSION_KEY = 'notejam-flask-secret-key'