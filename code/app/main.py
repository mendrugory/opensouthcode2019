import os
from notejam import app
from notejam.config import DevelopmentConfig

app.config.from_object(DevelopmentConfig)

if __name__ == '__main__':
    port = os.getenv("APP_PORT", 80)
    app.run(host='0.0.0.0', debug=True, port=port)
