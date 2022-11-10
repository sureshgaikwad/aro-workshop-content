#!/usr/bin/env bash

cd ~
curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz > openshift-client-linux.tar.gz

mkdir openshift

tar -zxvf openshift-client-linux.tar.gz -C openshift

curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/
curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio

curl -L https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-`uname -s`-`uname -m` -o envsubst
chmod +x envsubst
mkdir envsub
mv envsubst envsub/

wget https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/latest/tkn-linux-amd64.tar.gz
mkdir tkn
tar -xvf tkn-linux-amd64.tar.gz -C tkn 

wget http://download.joedog.org/siege/siege-latest.tar.gz
mkdir siege
tar -xvf siege-latest.tar.gz -C siege

echo 'export PATH=$PATH:~/siege:~/openshift:~/envsub:~/tkn' >> ~/.bashrc
source ~/.bashrc

oc completion bash > ~/openshift/oc_bash_completion
