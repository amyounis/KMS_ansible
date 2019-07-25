#! /bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function isinstalled {
  if yum list installed "$@" >/dev/null 2>&1; then
    true
  else
    false
  fi
}

clear

echo "########## testing internet connection ##########"
if ! ping  -c 4 8.8.8.8 &>/dev/null
then 
  echo -e "${RED}please insure that your machine is connected to internet${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

echo "########## installing epel-relese ##########"
if ! isinstalled epel-release
then 
  yum -q -y install epel-release && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

echo "########## installing ansible ##########"
if ! isinstalled ansible
then
  yum -q -y install ansible && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

echo "########## running ansible playboock ##########"
ansible-playbook site.yml -i hosts
