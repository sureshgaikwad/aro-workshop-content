#!/usr/bin/env bash

mkdir -p ~/bin
mkdir -p ~/scratch
cd ~/scratch

echo "Installing various Azure CLI extensions"
az extension add --name "connectedk8s" --yes
az extension add --name "k8s-configuration" --yes
az extension add --name "k8s-extension" --yes

echo "Installing OC cli"

if ! which oc > /dev/null; then
  curl -Ls https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar xzf -

  install oc ~/bin
  install kubectl ~/bin
fi

echo "Configure OC bash completion"
# oc completion bash > ~/bin/oc_bash_completion


echo "Installing Quarkus"
if ! which quarkus > /dev/null; then
  curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/
  curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio
fi

echo "Installing tekton cli"
if ! which tkn > /dev/null; then
  curl -Ls https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/latest/tkn-linux-amd64.tar.gz | tar xzf -
  install tkn ~/bin
fi

echo "Installing Helm"

wget https://get.helm.sh/helm-v3.9.3-linux-amd64.tar.gz >/dev/null
tar xvf helm-v3.9.3-linux-amd64.tar.gz > /dev/null
sudo cp linux-amd64/helm /usr/local/bin 

echo "Installing Maven"
wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xvf apache-maven-3.6.3-bin.tar.gz > /dev/null
sudo cp apache-maven-3.6.3 /opt/ 


#echo "Installing Siege"
#if ! which siege > /dev/null; then
#  echo "Compiling Siege, this may take a few minutes..."
#  curl -Ls http://download.joedog.org/siege/siege-4.1.5.tar.gz | tar xzf -
#  cd siege-4.1.5
#  ./configure --prefix=${HOME} --with-ssl
#  make > /dev/null
#  make install > /dev/null
#  mkdir -p ~/.siege
#  siege.config > /dev/null
#fi

echo "Configuring Environment specific variables"
cat <<"EOF" > ~/.workshoprc
#!/bin/bash
# source ~/bin/oc_bash_completion
export AZ_USER=$(az ad signed-in-user show --query "userPrincipalName" -o tsv | cut -d @ -f1)
export USERID="${AZ_USER}"
#export AZ_RG="${AZ_USER}-rg"
#export AZ_ARO="${AZ_USER}-cluster"
export AZ_LOCATION='eastus'
export OCP_PASS=$(az aro list-credentials --name "${AZ_ARO}" --resource-group "${AZ_RG}" --query="kubeadminPassword" -o tsv)
export OCP_USER=kubeadmin
export OCP_CONSOLE="$(az aro show --name ${AZ_ARO} --resource-group ${AZ_RG} -o tsv --query consoleProfile)"
export OCP_API="$(az aro show --name ${AZ_ARO} --resource-group ${AZ_RG} --query apiserverProfile.url -o tsv)"
export M2_HOME="/opt/apache-maven-3.6.3"

alias kubectl=oc
alias k=oc

EOF

export UNIQUE=$RANDOM
echo "export UNIQUE=${UNIQUE}" >> ~/.workshoprc
echo "export AZR_STORAGE_ACCOUNT_NAME=openenvadmin${UNIQUE}" >> ~/.workshoprc
echo "export AZ_RG=`echo $RESOURCEGROUP`" >> ~/.workshoprc
echo "export AZ_ARO=aro-cluster-$GUID" >> ~/.workshoprc
echo "export PATH=$PATH:$M2_HOME/bin" >> ~/.workshoprc

# echo "source ~/.workshoprc" >> ~/.bashrc

cd ~
echo "******SETUP COMPLETE *******"
echo
echo
echo "Run '. ~/.workshoprc' to load environment specific variables"
echo "Rerun this command any time you start a new terminal"

