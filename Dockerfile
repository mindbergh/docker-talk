# DOCKER-VERSION 1.2.0
# @file Dockerfile
# @brief An example Dockerfile taken from the TartanHacks web app.
# @author Oscar Bezi, oscar@bezi.io
# @since 7 January 2015
#===============================================================================
FROM node:0.10
MAINTAINER Oscar Bezi

RUN npm install -g coffee-script
# after deploy replace this with production solution
RUN npm install -g nodemon

# where the production files will go
RUN mkdir -p /opt/app
WORKDIR /opt/app

ADD package.json /opt/app/package.json
RUN npm install

CMD nodemon server.coffee;
