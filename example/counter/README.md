#### [Examples][examples] > Counter ####



# Counter #

This is a simple step-by-step guide to creating a basic counter control.
The completed feature will display the count with a button to increment and a button to reset.



## Setup ##

First thing's first, we need to setup our desired markup.
It's always easier to start with the markup and then create your controls.

 > **Note:** You must also include your bundled JavaScript file and jQuery with `<script>` tags

```html
<!-- index.html -->
<div>

    <p>
        You&#39;ve clicked <span>0</span> times
    </p>

    <div>
        <button>Click me</button>
        <button>Reset</button>
    </div>

</div>
```



## Bootstrap ##

Now we need to create a bootstrap file for our JavaScript library.
We'll also define the controls we're about to make, `counter` and `incrementer`, in the `example` namespace.

```js
// script/bootstrap.js
var controls = {
    example: {
        counter: require('./counter.js').counter
        incrementer: require('./incrementer.js').incrementer
    }
};

snuggle.up($('body'), controls, {}, false);
```



## Incrementer ##

First we'll take a look at the incrementer. This control will handle the buttons that increment and reset the count.

Before we go ahead with the JavaScript side of the control, we first need to update our markup.
> **Note:**
 - `data-cosy-import="example"` imports the controls from the `example` namespace
 - `data-cosy-props="count"` defines the property we're going to increment and reset
 - `data-cosy-control="incrementer &@count"` calls the `incrementer` control with the reference to `count` as it's argument
 - `data-role="[button|reset]"` makes it easy to target the buttons in our JavaScript

```html
<!-- index.html -->
<div data-cosy-import="example" data-cosy-props="count">

    <p>
        You&#39;ve clicked <span>0</span> times
    </p>

    <div data-cosy-control="incrementer &@count">
        <button data-role="button">Click me</button>
        <button data-role="reset">Reset</button>
    </div>

</div>
```

Next we need to create the actual control.
All it needs to do is bind click handlers to the buttons which modify the count.

To make sure the events aren't bound to more than once, we use `this.isInitialising` to check it's the first time the control is called.

```js
// script/incrementer.js
var incrementer = function (count) {
    if (this.isInitialising) {

        var _this = this;
        this.onEvent('button', 'click', function () {
            var value = _this.get(count);
            _this.set(count, ++value);
        });

        this.onEvent('reset', 'click', function () {
            _this.set(count, 0);
        });

    }
};
```


## Counter ##

To complete the feature we need to display the count. Again, we need to update the markup.

Before we go ahead with the JavaScript side of the control, we first need to update our markup.
> **Note:**
 - `data-cosy-control="counter @count"` calls the `counter` control with the value of `count` as it's argument
 - `data-role="[count]"` makes it easy to target the count container

```html
<!-- index.html -->
<div data-cosy-import="example" data-cosy-props="count">

    <p data-cosy-control="counter @count">
        You&#39;ve clicked <span data-role="count">0</span> times
    </p>

    <div data-cosy-control="incrementer &@count">
        <button data-role="button">Click me</button>
        <button data-role="reset">Reset</button>
    </div>

</div>
```

Now for the Javascript.
Remember that when you create a control with a reference as an argument, it will be called every time the value is modified.

> **Note:** We set the text to `0` if `count` is falsey

```js
// script/counter.js
var counter = function (count) {

    this.role('count').text(count || 0);

};
```



## Fin. ##

To conclude, we've just built a simple counter which displays the count with buttons to increment and reset the count

**jsFiddle** coming soon...


<!-- Meta -->
[examples]: https://github.com/BraveNewTalent/cosy-js/tree/master/example
