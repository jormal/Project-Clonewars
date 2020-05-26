#!/bin/bash

TIMEFORMAT="+%Y-%m-%dT%H:%M:%S"

WORK_DIR=$(dirname $(realpath $0))
LOG_DIR=${WORK_DIR%%/}/deploy_log/
LOG_FILE=${LOG_DIR%%/}/"deploy_`date "+%y%m%d_%H%M%S"`.log"

VERSION=""

function main() {
  read_arg $@
  create_logline "Run deploy script."
  create_deployment
  create_logline "Finish deploy script."
  exit 0
}

function read_arg() {
  while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key in
      -h|--help)
        create_help
        shift 1
        ;;
      -v|--version)
        VERSION="$2"
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  if [ "$VERSION" = "" ]
  then
    create_logline "Wrong version."
    exit -1
  fi
  mkdir -p $LOG_DIR 2>/dev/null
}

function create_help() {
  echo -e "\nUsage:\tdeploy.sh [OPTIONS]"
  echo -e "\nDeploy IR translator"  
  echo -e "\nOptions:"
  echo -e "\t-v, --version 0.0.0\t Version of IR translator which want to deploy (REQUIRED)"
  exit 0
}

function create_deployment() {
  create_logline "Push docker image $VERSION version start."
  docker pull jormal/ir-translator:$VERSION 1>/dev/null
  create_logline "Push docker image $VERSION version end."
  
  create_logline "Push docker image latest version start."
  docker pull jormal/ir-translator:latest 1>/dev/null
  create_logline "Push docker image latest version end."

  create_logline "Build binary file of running script start."
  pyinstaller -F --distpath ${WORK_DIR%%/}/deployed/$VERSION/ \
    --workpath ${WORK_DIR%%/}/deployed/$VERSION/build --clean ${WORK_DIR%%/}/ir-trans.py 1>/dev/null
  rm ${WORK_DIR%%/}/ir-trans.spec 1>/dev/null
  rm -rf ${WORK_DIR%%/}/__pycache__/ 1>/dev/null
  create_logline "Build binary file of running script end."

  create_logline "Deploy binary file start."
  sudo rm /usr/bin/ir-trans 1>/dev/null
  sudo ln ${WORK_DIR%%/}/deployed/$VERSION/ir-trans /usr/bin/ir-trans 1>/dev/null
  create_logline "Deploy binary file end."
}

function create_logline() {
  echo -e "[`date $TIMEFORMAT`] $1" >> $LOG_FILE
  echo -e "[`date $TIMEFORMAT`] $1"
}

main $@