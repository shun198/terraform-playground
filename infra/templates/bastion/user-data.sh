#!/bin/bash
# https://dev.classmethod.jp/articles/jdbc-postgresql-auth-type-error/
# https://www.postgresql.org/download/linux/ubuntu/
sudo yum update -y
sudo yum install -y postgresql
{% comment %} sudo amazon-linux-extras install -y docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker ec2-user {% endcomment %}
