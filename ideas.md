#### Motivation:
I really enjoy coding in Lamdera, and want to explore the idea of a simple open-source exploratory data-analysis tool. I haven't pushed Lamdera to the limits (yet).

My hypothesis is Elm's type safety + Lamdera's evergreen are powerful tools for exploratory analytics work. Currently, 
much of this work gets bogged down in glue code requiring expensive engineers

The real dream is to be able to have domain experts build their own customtooling for the task at hand, the way engineers invest in text editors

Can a Lamdera app "hug" a data warehouse to provide a delightful data exploration platform.

To test this idea, I'm going to use Elastic Search. I've already set up an instance on elastic cloud, and got a trivial pipeline working.

The Elm architecture:
For more details see [the Elm docs](https://guide.elm-lang.org/architecture/), but the gist is:
 * you define `Model` and `Msg` types. `Model` describes the state needed to run your app, `Msg` describe all the things that can happen in your app.
 * Then, you must supply four things:
    * `init` your model
    * `update` your model to its new state, upon receiving a msg
    * `subscribe` to msgs from others / system (setting an event to fire ever X seconds is a simple example)
    * render your model's `view`, outputs HTML for the browser to render

Lamdera's extension:

For the case of building web-apps to power small businesses, I think Lamdera is a viable option

What does this mean for data analytics?

How can I practically do this?

This is interesting, I find this key when considering the practicalities of a data-driven organization. Software engineering technical skill is hard to come by, and you'll have to do some finagling to get them to support your project. Here, the type checking can be in the hands of the analyst. The post-upload notifactions.
![schema fields](./assets/fig1.png)


The post-upload notifactions.
![schema fields](./assets/fig2.png)
