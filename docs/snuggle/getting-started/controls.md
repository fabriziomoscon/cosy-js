
Getting Started With Snuggle: Building Controls
===============================================

A control in snuggle is a simple function, with HTML attributes used to bind controls to DOM elements. In their simplest form, a control looks like this:

```html
<div data-cosy-control="example">
    <!-- control content here -->
</div>
```

```js
function example () {
    // code here
}
```

When a control function is called, `this` is set to an object with a bunch of convenience methods for working with the DOM and other controls. You don't have to use these methods, however, as `this.element` is a simple jQuery object representing the control's DOM element. This means you can just use vanilla jQuery if you wish:

```html
<div data-cosy-control="helloGoodbye">
    hello
</div>
```

```js
function helloGoodbye () {
    var element = this.element;
    element.click(function (event) {
        element.text('goodbye');
    });
}
```


Arguments
---------

You are able to pass arguments into control functions by adding space-separated arguments to the `data-cosy-control` attribute. These arguments are run through a JSON parser:

```html
<div data-cosy-control="helloThing 'world'">
    hello <span class="thing">...</span>
</div>
```

```js
function helloThing (thing) {
    this.element.find('.thing').text(thing);
}
```

Multiple arguments are allowed, and snuggle doesn't mess with your types:

```html
<div data-cosy-control="argsExample 'world' true 123">
    <!-- control content here -->
</div>
```

```js
function argsExample (arg1, arg2, arg3) {
    alert(typeof arg1); // string
    alert(typeof arg2); // boolean
    alert(typeof arg3); // number
}
```


Control Methods
---------------

There are many core convenience methods available to controls, exposed as methods on the control context. See the [control object reference](../reference/control-object.md) for more detail, but we'll run through some of the basic DOM helpers here.


### Role(s)

Snuggle uses `role` elements (defined using the `data-role` attribute) as pointers to specific parts of the DOM which you may need to manipulate. To save having to type `[data-role=x]` in all of your selectors, the `role` and `roles` methods are made available. They simply hide away the complex selector and perform a `find` on the control's DOM element. The return value for both methods is just another jQuery object.

We can simplify the `helloThing` example from earlier by using roles:

```html
<div data-cosy-control="helloThing 'world'">
    hello <span data-role="thing">...</span>
</div>
```

```js
function helloThing (thing) {
    this.role('thing').text(thing);
}
```

### Events

Snuggle also provides a convenience wrapper for events, which can be bound to the control's DOM element. In order to encourage use of role elements, delegated events automatically fill out the `data-role` part for you:

```html
<div data-cosy-control="helloWorld">
    hello <span data-role="world">world</span>
</div>
```

```js
function helloWorld () {
    // Click the control element
    this.onEvent('click', function (event) {
        alert(event.element.text()); // hello world
    });

    // Click the 'world' role element
    this.onEvent('world', 'click', function (event) {
        alert(event.element.text()); // world
    });
}
```

Getting Started With Snuggle: Class Controls
============================================

Todo.
