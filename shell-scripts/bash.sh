#!/bin/bash

docker run --rm -it \
    -v ~/code/fir-lamdera/:/root/code \
    -w /root/code \
    fir-lamdera:dev \
    bash
