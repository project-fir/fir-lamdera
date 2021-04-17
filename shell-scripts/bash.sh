#!/bin/bash

docker run --rm -it \
    -p 8000:8000 \
    -v ~/code/fir-lamdera/:/root/code \
    -w /root/code \
    fir-lamdera:dev \
    bash
