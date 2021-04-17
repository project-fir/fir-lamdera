This assumes you have docker ready to go

```
cd /into/this/directory

# build the fir-lamdera:dev image
./deploy/build.sh

# run bash inside a container
./deploy/bash.sh

# this will mount this directory to the root user's home code directory /root/code
# You can then run `lamdera init` in the container, and it'll create files for you that get saved to your host machine 
```