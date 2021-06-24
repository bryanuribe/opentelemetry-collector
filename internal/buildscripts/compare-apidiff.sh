#!/usr/bin/env bash

# This script is used to compare API state snapshots to the current package state in order to validate releases are not breaking backwards compatibility.

usage() {
  echo "Usage: $0"
  echo
  echo "-c  Check-incompatibility mode. Script will fail if an incompatible change is found. Default: 'false'"
  echo "-p  Package to generate API state snapshot of. Default: ''"
  echo "-d  directory where prior states will be read from. Default: './internal/data/apidiff'"
  echo "-i  directory where comparison package is located. Default: ''"
  exit 1
}

changes_found() {
  echo "Incompatible Changes Found."
  echo "Check the logs in the Github Action log-group: 'Comparing apidiff states'."
  exit 1
}

package=""
old_dir="./internal/data/apidiff"
new_dir="./internal/data/apidiff"
check_only=false


while getopts "cp:d:i:" o; do
    case "${o}" in
        c) 
            check_only=true
            ;;
        p)
            package=$OPTARG
            ;;
        d)
            old_dir=$OPTARG
            ;;
        i)
            new_dir=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z $package ]; then
  usage
fi

set -e

echo $old_dir/$package
echo $new_dir/$package

if [ -d $old_dir/$package ] && [ -d $new_dir/$package ]; then
  echo "here"
  changes=$(apidiff $old_dir/$package/apidiff.state $new_dir/$package/apidiff.state)
  echo $changes
  if [ ! -z "$changes" -a "$changes"!=" " ]; then
    SUB='Incompatible changes:'
    if [ $check_only = true ] && [[ "$changes" =~ .*"$SUB".* ]]; then
      changes_found
    else
      echo "Changes found in $package:"
      echo "$changes"
    fi
  fi
fi
