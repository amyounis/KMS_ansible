#! /bin/bash

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi


PS3='Please enter your deployment choice: '
options=("docker" "bare" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "docker")
            branchname="docker"
            ;;
        "bare")
            branchname="master"
	    ;;
        "Quit")
            exit 1
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

function print {
  ScreenWidth=`tput cols`
  Arg=$@
  ArgSize=${#Arg}
  let "Rem = $ScreenWidth - $ArgSize - 1"
  printf "\n" ; printf "$Arg " ; printf '*%.0s' $(seq 1 $Rem) ; printf "\n" 
}

function isinstalled {
  if yum list installed "$@" >/dev/null 2>&1; then
    true
  else
    false
  fi
}


print "Testing Internet Connection"
if ! ping  -c 4 8.8.8.8 &>/dev/null
then 
  echo -e "${RED}please insure that your machine is connected to internet${NC}" && exit 1
else
  echo -e "${GREEN}OK${NC}"
fi

print "Installing EPEL Repo"
if ! isinstalled epel-release
then 
  yum -q -y install epel-release && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

#print "Installing rpmforge Repo"
#if [ ! -f /etc/yum.repos.d/rpmforge.repo ]
#then 
#  rpm -i 'http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm'
#  rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
#  echo -e "${GREEN}OK${NC}"
#else
#  echo -e "${GREEN}OK${NC}"
#fi

print "Installing GIT"
if ! isinstalled git
then 
  yum -q -y git && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

print "Installing Ansible"
if ! isinstalled ansible
then
  yum -q -y install ansible && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

print "Clone KMS_install Repo"
if [ ! -d /tmp/KMS_install ] 
then
  git clone --branch $branchname https://github.com/amyounis/KMS_install.git /tmp/KMS_install && cd /tmp/KMS_install && echo -e "${GREEN}OK${NC}"
else
  cd /tmp/KMS_install && echo -e "${GREEN}OK${NC}"
fi

print "Running Ansible Playbook"
ansible-playbook site.yml -i hosts
