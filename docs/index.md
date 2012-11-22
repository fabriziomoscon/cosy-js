Cosy & Snuggle
==============

# Cosy #

> Cosy lets you build resuable components designed to interract with the DOM.

## Why cosy? ##

One of the more common issues when dealing with the browser is how to go about
connecting your awesome bit of the code to the right part of the DOM. There are
many strategies for doing this but the pattern tends to be the same.  Cosy
provides an easy way of doing this that lets you worry about your awesome code
and not about how get it into the DOM.

Once we can do this we're free to think about the harder problems we're faced
with when trying to build rich, responsive and managable web sites and
applications.  Much work has gone into this with many MVC, MVVM, MV* frameworks
out there and number of them in pretty damn good shape.  It would be pretty
foolish to try and solve that problem again so is there another problem that
isn't being solved? We think there is and we've built the snuggle control
library on top of cosy to solve just that problem.

Check out the [cosy introduction](./cosy/index.md) for a more detailed
explanation of how cosy works.

# Snuggle #

> Snuggle lets you build resuable UI controls designed to interract with your
data.

## Why snuggle? ##

It's probably fair to say the the MV* (model, view and something else like a
controler) pattern is the prevailing way of producing web based software today.
The only issue with it is that it's a little bit vague about what happens in
each of it's parts.  Much work has gone into making the model layer independant
of persistence strategies and more recent work has gone in to minimising the
resonsibilities (and event the existence) of controllers.  That does mean we're
still left with the view in which most people seem to be content with templating
and direct DOM manipulation.  There are lots of libraries/frameworks that add
real power to this and the VM (view model) pattern has gone a long way to help
but maybe there something we could put into the mix to make our lives even
better. This is where snuggle steps in, by using cosy to bind to the DOM it
provides way to build reusable and composable UI controls that can communicate
with your model and your view in a way that's primarily driven by
interractions/behaviours and data rather than templates and models.

### Isn't that what jQuery, etc is for? ###

In many respects, yes, and in fact both cosy and snuggle will use the DOM
library of your choice (only jQuery right now) under the hood and expose it to
you when you need it.  These libraries, however, provide a very low level way of
talking about your UI.  It's certainly better than having to deal with the DOM
directly but, when we're designing interractions isn't it better to talk about
something called an "expander" rather than "the thing that will open and close
this other thing when it's clicked on"?  These collections of behaviour are
easily created, with some thought, in any library but snuggle helps take out
much of the repitition and boilerplate by giving you the concept of controls.

## Getting Started ###

See the snuggle [getting started guide](./snuggle/index.md) for more information

### Installation ###

    npm install cosy-js

### Bootstrapping ###

```js
snuggle = require('cosy-js').snuggle;

controls = require('/path/to/your/controls');
libs = require('/path/to/your/libraries');

debug = false;

snuggle.up($('html'), controls, libs, debug);
```

## Key Concepts (w/ examples) ##

### Controls & Declarative Binding (w/ expander example) ###

### Properties (w/ counter example) ###

### Partials & Templates (w/ Mustache standard example) ###

### Lists (w/ List example) ###

### Structuring your code ###


## Further Reading ###

### Cosy core ###

### Cosy Snuggle ###

### Building Controls ###

