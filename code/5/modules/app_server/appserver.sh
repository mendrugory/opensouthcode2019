#!/bin/bash

sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo service docker start
sudo docker run -d --rm -p 80:80 \
    -e MYSQL_DATABASE_DB=${db_name} \
    -e MYSQL_DATABASE_HOST=${db_address} \
    -e MYSQL_DATABASE_USER=${db_username} \
    -e MYSQL_DATABASE_PASSWORD=${db_password} \
    --name notejam mendrugory/notejam