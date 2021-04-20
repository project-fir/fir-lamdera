### Fir prototype

Vision: (VSCode)[] combined with (LitViz)[https://github.com/gicentre/litvis] combined with (Figma)[https://www.figma.com/], but completely infected with the Elm
philosophy. If it isn't Elm we don't use it, 100% absolutist. I believe this will take (some) power away from highly technical non-domain experts, allowing 
domain experts to do their work without it being polluted by non-domain concerns (like null-pointer exceptions and dependency hell).

I've decided to go with (Lamdera)[https://dashboard.lamdera.app/features] to prototype. Scale will not be a concern by 2030.

This assumes you have docker ready to go, and you've already cloned this repo to your dev machine

```
cd /into/this/directory

# build the fir-lamdera:dev image
./shell-scripts/build.sh

# if you're editing code, this is all you need
docker-compose dev up


# If you need to lamdera install any dependencies, do so inside the container
./shell-scripts/bash.sh
```

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
   * Not a definition, but ideas for v0.2: Goal, learn what is going to be hard about bring good autocomplete to a collaborative LitViz IDE
       * collaborative "turle" language for drawing
       * really good auto complete and it's supporting UX, almost laughably good for a trivial language
