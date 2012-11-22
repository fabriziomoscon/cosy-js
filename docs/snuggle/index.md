Getting Cosy With Snuggle
=========================

While cosy provides us with an easy way to bind code to the DOM we don't want
to really spend our time thinking about cosy commands and frames of reference
(see the [cosy introduction](../cosy/index.md) for more about these).  Luckily,
this is where snuggle steps in by providing a set of useful commands for
building UI controls.

What are these useful commands you speak of?
--------------------------------------------

Snuggle comes with a set of commonly needed commands to make working with the
DOM (and cosy) as easy as possible.  At present the following commands are
available:

 * control

    The core concept in snuggle is that of a control, the `control` command
    allows you to bind a control to the DOM.

 * class

    The `class` command lets you create a control using a JavaScript class
    to be created with the `new` operator.

 * import

    It's always nice to keep your code clean and well organised, it does make
    life trick when you have to keep writing `nicely.namespaced.fooControl` to get
    at your commands and classes.  The `import` command lets you import a
    namespace into the current frame of reference.  So if I import
    `nicely.namespaced` I can then just write `fooControl` from then on.

 * partial

    Snuggle has built in support for templating, the `partial` command lets you
    tell snuggle which templates should be made available to the templating
    engine as partials.

 * props

    As well as controls the other main concept to understand is that of
    properties.  These are containers for data that needs to be shared between
    controls they can be watched for changed and have scope. The `props`
    command allows you to create properties that will be available to any
    controls further down the DOM.

 * call

    Because snuggle wraps around cosy, it makes it pretty difficult to add your
    own commands.  The `call` command lets you call your own commands without
    having to mess around with the details of adding them to snuggle.

 * attach

    Sometimes you need to make cosy play nice with some existing library or you
    need to somehow delay the evalutation of the DOM.  The attach command
    provides you with a reasonable way to do this.

`snuggle.up`
------------

Just has cosy has `cosy.up` snuggle has a equivalant command called
`snuggle.up`.

```js
snuggle = require('cosy-js').snuggle;

controls = require('/path/to/your/controls');
libs = require('/path/to/your/libraries');

debug = false;

snuggle.up($('html'), controls, libs, debug);
```

As you can see, the way snuggle is invoked is very similar to the way that cosy
is, but with some important diferences.  This first is that we have divided our
code into controls and libraries.

 * Controls

    A control is the code you want to bind to the DOM element. It contains all
    of your UI logic. And can be used with the `control` and `class` commands.

 * Libraries

    A library is a collection of useful code that you want to make available to
    your control.  This can include commonly used patterns, other controls or
    just some helpers.

Show me the snuggly
-------------------

In the [cosy introduction](../cosy/index.md) we showed you a silly little
example of how you could write some cosy commands to do a bit of DOM
manipulation.  Here's the same example written using snuggle (please bear in
mind that the code is equally as silly as the example).

```html
<html>
  <body data-cosy-import="example">
    <div data-cosy-control="silly.remover 'bar-container'">
      Foo
      <div data-role="bar-container">
        Bar
        <button data-role="foo">Remove Foo</button>
        <button data-role="bar">Remove Bar</button>
      </div>
    </div>
  </body>
</html>
```


```js
snuggle = require('cosy-js').snuggle;

sillyHelper: function (control, role, element) {
    control.onEvent(role, 'click', function() {
        element.remove()
    });
};

sillyRemover = function (containerName) {
    this.helper.remover(this, 'foo', this.element);
    this.helper.remover(this, 'bar', this.role(containerName));
};

controls = {
    example: {
        silly: {
            remover: sillyRemover
        }
    }
};

libs = {
    helper: {
        remover: sillyHelper
    }
}

debug = false;

snuggle.up($('html'), controls, libs, debug);
```

For some less silly examples please refer to the examples in the code.
