# DOCKER-VERSION 1.2.0
# @file Dockerfile
# @brief The dockerfile for the Node.js app container.  Uses nodemon to
# livereload code during development.  *Not production viable*
# @author Oscar Bezi, oscar@bezi.io
# @since 7 January 2015
#===============================================================================
FROM node:0.10
MAINTAINER Oscar Bezi

# replace sh with bash so I can use if statements below
ENTRYPOINT ["/bin/bash", "-c"]

RUN npm install -g coffee-script
# after deploy replace this with production solution
RUN npm install -g nodemon

# where the production files will go
RUN mkdir -p /opt/app
WORKDIR /opt/app

COPY . /opt/app
RUN npm install
