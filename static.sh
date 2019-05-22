#/bin/bash

cd "$(dirname "$0")"

rm -rf docs
reveal-md terraform.md --static docs