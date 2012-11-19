Cosying up to the DOM
=====================

One of the main purpose of cosy lies in it's ability to read the DOM and bind
code to it.  It does this in two stages the read stage and the evaluate stage.

The read stage
----------------

The cosy `reader` takes a starting node and a CSS selector and constructs a
tree of all the elements matching the selector.  The tree has the same
hierachical structure as your HTML. e.g.

```js
reader = require('cosy-js').core.reader;
tree = reader.read($('html'), '[data-cosy-foo]');
```

The tree that the `reader` returns contains all the matching elements and a
parse of any `data-cosy` attributes they might have into cosy `commands`.

The evaluate stage
--------------------

Once you have a tree you can then use it to bind code to the elements.  This
is where the evaluator steps in.  The evaluator takes a tree and evaluates any
parsed `data-cosy` attibutes attached to each node in the tree.

```js
evaluator = require('cosy-js').core.evaluator;
evaluator.apply(tree, frame);
```
The `evaluator` takes the root node in the tree and evaluates it using the
`frame` that is passed. This results in a new `frame`.  Each of the children
is then evaluated using the new `frame`.  Rinse and repeat.

Wait what's a frame?
---------------------

A `frame` in cosy is short for 'frame of reference' and is an object containing
the functions and variables available to the `evaluator` when evaluating a
`command`.

When the cosy `evaluator` tries to evaluate each node in the tree it takes the
parsed cosy `commands` for that node and uses the current frame to evaluate
each.  Each `command` is then able to add and remove items from that `frame`
and the resulting `frame` is then used to evalutate the node's children.

Evaluating commands
---------------------

A cosy `command` takes the following form: `foo arg1 arg2 arg3`, this is
equivalent to adding a `data-cosy-foo="arg1 arg2 arg3"` attribute to an element
in the DOM.  The cosy `evaluator` takes each of the words in the command and
looks them up using the current `frame` (if the args are valid JavaScript
literals then they are used directly).

With any luck the first word in the command matches a function in the current
`frame` if so the `evaluator` calls that function passing in the current
`frame` and the looked up args e.g. if our frame looked something like this:

```js
{
    hello: function (frame, engligh, worldEn, worldOther) {
        if (engligh) {
            console.log("Hello " + worldEn);
        } else {
            console.log("Hello " + worldOther);
        }
    },
    worlds: {
        french: 'monde'
    }
}
```

We would expect to see the following output (note the fact we can use the evaluator
on a string as well as a tree node):

```js
evaluator.apply("hello true 'world' worlds.french", frame);
// Hello world

evaluator.apply("hello false 'world' worlds.french", frame);
// Hello monde
```

Where's my DOM element?
-------------------------

So one of the main uses of cosy is that it helps to bind your code to the DOM.
We've, so far, talked about parsing the tree and executing code but not about
actually doing anything useful with the DOM.  To do this cosy simply exposes
the element that you're at as a part of the current `frame` in a property
called `__node` (cosy uses the double underscore to get out of your way).

In addition, should you need to get at the frame that came before you, cosy
also adds `__parent` to the frame so you could access that if you need to use
it (which should be unlikely right now).

`cosy.up`
---------

Most of the above is pretty common for any cosy code so we've bundled it all
into the `up` function which reads the DOM, sets up a working frame and
evaluates the lot:

```js
cosy = require('cosy-js');
imports = require('/path/to/your/code');

cosy.up($('html'), imports);

```

The default behaviour of cosy `up` is to take each of the keys in imports and
build a [data-cosy-{key}] selector for each.  To get a more detailed usage it's
probably now a good time to look at `snuggle.up`.

A small (silly) example
-----------------------

Just so we don't leave you out in the cold here's a silly example of how you
you might write and use a cosy command (note how the quotes aren't needed in
the remover because we want cosy to do the work for us).

```html
<html>
  <body>
    <div data-cosy-removee="'foo'">
      Foo
      <div data-cosy-removee="'bar'">
        Bar
        <button data-cosy-remover="foo">Remove Foo</button>
        <button data-cosy-remover="bar">Remove Bar</button>
      </div>
    </div>
  </body>
</html>
```


```js
cosy = require('cosy-js');
imports = {
    removee: function (frame, name) {
        // Copy the DOM node we're on into the frame using name as the key
        frame[name] = frame.__node;
    },
    remover: function (frame, element) {
        // Remove the element we've been passed
        element.remove();
    }
}

cosy.up($('html'), imports);
```
