#!/bin/bash 

env_name="$2"

case "$1" in
"") echo -e "NO PARAMETERS\n""USAGE:     $0 <zip/unzip> <ENV_NAME>\n"; exit 65;;  # If no parameters were recived

zip*) ./zip.sh $env_name;;   # If filename starts from "zip" 

unzip*) ./unzip.sh $env_name;; # If filename starts from "unzip" 

* ) echo "Wrong argument";;     
esac
