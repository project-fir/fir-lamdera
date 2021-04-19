This assumes you have docker ready to go

```
cd /into/this/directory

# build the fir-lamdera:dev image
./deploy/build.sh

# run bash inside a container
./deploy/bash.sh

# this will mount this directory to the root user's home code directory /root/code
# You can then run `lamdera init` in the container, and it'll create files for you that get saved to your host machine 

# ^ use the above to add elm deps

# For normal dev, just do
docker-compose dev up
```

Enjoy!

### Log

 * 4/17-4/18: I started with some toy examples and dove a bit too head first into the Markdown parser component and my head was spinning
 * 4/19: Let's take a step back..
   I want to get better at elm-ui and also gather some initial feedback of the collaborative cell idea, so I'll do both
    * Definition of v0.1:
       * elm-ui "cells" arranged in a jupyter notebook style, start with plain multiline input
       * don't go wild, but put some effort into the look, monospace font??
       * "collaborators" display - keep it simple
       * each cell has one global lock, other clients see a gray-ed out box, with live updates being broadcasted/received
       * client can release lock, locks are auto release upon disconnected, and broacasted to other clients
       * state of cells and text typed inside persists out on the interwebz
