#!/bin/bash
terraform_home="/usr/bin"
terraform_file="terraform_0.12.23_linux_amd64.zip"
terragrunt_file="terragrunt_linux_amd64"
function terraform_install() {
  [[ -f ${terraform_home}/terraform ]] && echo "`${terraform_home}/terraform version` already installed at ${terraform_home}/terraform" && return 0
  LATEST_URL="https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_linux_amd64.zip"
  cd /tmp/; wget ${LATEST_URL}
  cd /tmp/; unzip ${terraform_file}
  sudo mv /tmp/terraform ${terraform_home}


  echo "Installed: `${terraform_home}/terraform version`"
}

function terragrunt_install() {
  [[ -f ${terraform_home}/terragrunt ]] && echo "`${terraform_home}/terragrunt version` already installed at ${terraform_home}/terragrunt" && return 0
  LATEST_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v0.21.11/terragrunt_linux_amd64"
  cd /tmp/; wget ${LATEST_URL}
  sudo mv /tmp/${terragrunt_file} ${terraform_home}/terragrunt
  chmod +x ${terraform_home}/terragrunt
  

  echo "Installed: `${terraform_home}/terragrunt --version`"
}

function kubectl_install() {
  [[ -f ${terraform_home}/kubectl ]] && echo "`${terraform_home}/kubectl version --client --short` already installed at ${terraform_home}/kubectl" && return 0
  LATEST_URL="https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl"
  cd /tmp/; wget ${LATEST_URL}
  sudo mv /tmp/kubectl ${terraform_home}/kubectl
  chmod +x ${terraform_home}/kubectl
  

  echo "Installed: `${terraform_home}/kubectl --version`"
}

terraform_install

terragrunt_install

kubectl_install
