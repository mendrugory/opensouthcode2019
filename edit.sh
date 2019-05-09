#/bin/bash

firefox localhost:8080/stash

docker run --rm --name markdown-to-slides -p 8080:8080 -v /home/gonzalo/presentaciones/2019/opensouthcode2019:/app/slides mendrugory/markdown-to-slides
