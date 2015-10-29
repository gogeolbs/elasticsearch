#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

if [[ $UID != 0 ]]; then
  echo "Please run this script with sudo:"
  echo "sudo $0 $*"
  exit 1
fi

push=0

function show_help
{
  echo "Usage: sudo $0 -t TAG (Usually a build number)"  
  echo "Usage: sudo $0 -p (Push to local registry) -t TAG (Usually a build number)"
}

while getopts :h?:t::p FLAG; do
  case "$FLAG" in
  h|\?)
    show_help
    exit 0
    ;;
  p)
    push=1
    ;;
  t)
    TAG=$OPTARG
    ;;
  esac
done

if [[ -z $TAG ]]; then
  TAG="latest"
fi

NAME=elasticsearch:$TAG
REMOTE=server1.local.gogeo.io:5000

docker build -t "$NAME" .

if [[ $? -gt 0 ]]; then
  echo "Error in build image"
  exit 1
fi

if [[ $push -eq 1 ]]; then
  echo "Pushing tag: $TAG to $REMOTE"
  docker tag -f $NAME $REMOTE/$NAME
  docker push $REMOTE/$NAME
fi
