#!/bin/bash

mkdir -p ./keys
mkdir -p ./env/easydeploy/keys

rm ./keys/*
rm ./env/easydeploy/keys/*

#password for both keys is --> easydeploy
ssh-keygen -t rsa -b 4096 -C "test@example.com" -N '' -f ./keys/id_rsa
cp -R ./keys/ ./env/easydeploy/keys

chmod 400 ./keys/*
