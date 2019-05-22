#/bin/bash

cd "$(dirname "$0")"

rm -rf slides
reveal-md terraform.md --static slides