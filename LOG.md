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
   * Not a definition, but ideas for v0.2: Goal, learn what is going to be hard about bring good autocomplete to a collaborative LitViz-like IDE
       * collaborative "turtle" (I've also heard it called Logo) language for drawing
       * really good auto complete and it's supporting UX, almost laughably good for a trivial language
 * 4/24-4/25: With the goal of assigning a random color to a live collaborators "live tile", I hit an unexpected rabbit hole, random number generators.
   * Turns out drawing a random number has side effects, I was unaware of this so spent time reading about why. I think I get it now and have a branch with
     random number generation working. Now I need to figure out how to wire up a series of events to build a user + pass along to generator + return to frontend
   * Found some sources of inspiration re, text editors: https://dkodaj.github.io/rte/, https://package.elm-lang.org/packages/mweiss/elm-rte-toolkit/latest/
 * Sep 2021: Yes it's been awhile. I've built up some Elm / Lamdera chops, now starting to think about how to use Lamdera in the context of data-analysis. I have a week off,
   and want to start exploring what it'd be like to incorporate Lamdera into an existing ecosystem. My thoughts atm:
    * While "pure lamdera" is my happy place, it's a bit far from most company's realities. Could a datastore + Lamdera hybrid approach help convince others this paradigm isn't crazy?
        - Pros:
            * might help keep Lamdera cost down as I approach "medium data", pro looks like it could get pricey for what I want to achieve. Also hobbyst tier stops at 5MB (tho I think that might be negotiable)
            * provide type safety "wrapped around" the data store - need to jam on this one more.
        - cons:
            * We are intentionally crossing a `semantic boundary`. Reducing such boundaries is a large motivation for Lamdera in the first place. I'm setting myself up for some upstream-swimming.
    * Options that come to mind:
        - MongoDB
            * Very fast, BSON basically is just JSON
            * Quickly scouring the web, I see no MongoDB protocol implemented in Elm.
        - ElasticSearch
            * HTTP API out of the box
            * API support ElasticQuery DSL, which has (limited) Elm support.
            * In additional to being a quasi-datastore, ES also has search features. If the data-viz stuff doesn't work out, there still might be fun things to experiment with.
        - FaunaDB also looks interesting, but it's too much of a leap relative to my current skillset. I want to stay focused on the Lamdera aspect, if I'm successful Fauna deserves a closer look for sure.
        - DataWarehousing products like BigQuery and Snowflake have lots of setup, and are higher latency. Punting this, though needs more consideration.
    * I'm going with Elastic Search for now, with the expectation of running into HTTP-related latency issues.
    * starting to piece together a project plan, see `ideas.md` in this directory
    * using the idea of fewest semantic boundaries. Example is pulling in predisential data. Exporting to JSON and using the Elastic Cloud UI is how I'm going to do it. Current idea is to maintain proper lineage that this data is from a non-reproducible source, and using evergreen migrations to keep old pipelines up to date.
