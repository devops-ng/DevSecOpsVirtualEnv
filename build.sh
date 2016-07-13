#!/bin/bash

vagrant_build() {
  BOX_FILE=CentOS-7-x86_64
  USE_LOCAL=0
  VAGRANT_CLOUD='https://atlas.hashicorp.com/johandry/boxes/DevSecOps_CentOS_7'

  # Get the box name defined in the Vagrantfile
  BOX_NAME=$(grep '^  config.vm.box =' Vagrantfile | sed 's/.*= "\(.*\)"/\1/')

  SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

  export PACKER_CACHE_DIR=packer/packer_cache

  vagrant status | grep -q 'running (virtualbox)' && \
    echo "Destroying the running VMs" && \
    vagrant destroy -f

  [[ -f ${SCRIPT_DIR}/vagrant/boxes/${BOX_FILE}.box ]] && \
    echo "Removing old ${BOX_FILE}.box" && \
    rm ${SCRIPT_DIR}/vagrant/boxes/${BOX_FILE}.box

  vagrant box list | grep -q "${BOX_NAME}" && \
    echo "Removing old box ${BOX_NAME} from Vagrant" && \
    vagrant box remove ${BOX_NAME}

  echo "Building CentOS 7 box with Packer"
  packer build ${SCRIPT_DIR}/packer/centos7.json

  if [[ $USE_LOCAL -eq 1 ]]; then
    [[ -f ${SCRIPT_DIR}/vagrant/boxes/${BOX_FILE}.box ]] && \
      echo "Adding new box to Vagrant" && \
      vagrant box add ${BOX_NAME} ${SCRIPT_DIR}/vagrant/boxes/${BOX_FILE}.box

      vagrant box list | grep -q "${BOX_NAME}" && \
        echo -e "\033[93;1mThe new CentOS 7 box for DevSecOps is ready to use:\033[0m" && \
        echo "  vagrant up" && \
        echo "  vagrant status" && \
        echo "  vagrant ssh" && \
        echo -e "\033[93;1mAnd to be destroyed:\033[0m" && \
        echo "  vagrant destroy" && \
        echo
  else
    echo -e "\033[93;1mUpdate/upload the box to ${VAGRANT_CLOUD}\033[0m"
    echo "  At this time this process is not automated due to the account limitations. It would be automated later."
    echo -e "\033[93;1mOnce the box is updated in Vagrant Could it will be ready to be used:\033[0m"
    echo "  vagrant init ${BOX_NAME}"
    echo "  vagrant up"
    echo "  vagrant status"
    echo "  vagrant ssh"
    echo
  fi
}

docker_build(){
  echo "Wait, it is not completed yet!"
}

builder=vagrant_build
[[ "$1" -eq "--vagrant" ]] && builder=vagrant_build
[[ "$1" -eq "--docker"  ]] && builder=docker_build

eval "${builder}"
