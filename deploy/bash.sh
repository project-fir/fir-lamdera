#!/bin/bash

docker run --rm -it \
    -w /root/code \
    -v ~/code/fir-lamdera/:/root/code \
    fir-lamdera:dev \
    bash
