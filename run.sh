#!/bin/bash

docker build -t test .
SOME_PATH=`pwd`
docker run -p 8080:8080 -v $SOME_PATH:/home test
