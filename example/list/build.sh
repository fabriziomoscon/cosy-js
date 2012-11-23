#!/bin/bash

if [ ! -d ./build ]
then
    mkdir -p ./build
fi

../../node_modules/.bin/browserify ./script/bootstrap.js -o ./build/app.js
