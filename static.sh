#/bin/bash

cd "$(dirname "$0")"

rm -rf docs
reveal-md terraform.md --static docs
cp -r images docs 
sed -i 's@/images/@./images/@g' docs/index.html docs/terraform.html