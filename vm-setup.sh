#!/bin/bash

sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y ssh npm nodejs-legacy build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

\curl -sSL https://get.rvm.io | bash && source ~/.rvm/scripts/rvm && rvm install 2.3.0 && rvm use --default 2.3.0 && ruby -v

sudo npm install -g azure-cli

curl -O https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.81-linux-amd64 && chmod +x bosh-init-0.0.81-linux-amd64 && sudo mv bosh-init-0.0.81-linux-amd64 /usr/local/bin/bosh-init

ssh-keygen -t rsa -b 2048
openssl req -x509 -key ~/.ssh/id_rsa -nodes -days 365 -newkey rsa:2048 -out bosh.pem

openssl req -new -x509 -extensions v3_req -keyout cf.key -out cf.pem -days 3650 -config openssl.cnf -subj "/C=US/ST=Texas/L=Frisco/O=Pivotal/CN=*.rj-test.io"
openssl rsa -in cf.key -out cf.key
