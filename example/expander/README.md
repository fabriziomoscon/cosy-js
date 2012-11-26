#### [Examples][examples] > Expander ####



# Expander #

This is a simple step-by-step guide to creating a basic expander control.
The completed feature will display a list of cosy-js authors in an open/close box.



## Setup ##

First thing's first, we need to setup our markup.

 > **Note:** You must also include your bundled JavaScript file and jQuery with `<script>` tags

```html
<!-- index.html -->
<div>
    <h4>List authors: <button>Open</button></h4>

    <ul>
        <li>Neel Upadhyaya</li>
        <li>Rowan Manning</li>
        <li>Andrew Lawson</li>
    </ul>
</div>
```



## Bootstrap ##

Now we need to create a bootstrap file for our JavaScript library.
We'll also define the control we're about to make, `expander`, in the `example` namespace.

```js
// script/bootstrap.js
var controls = {
    example: {
        expander: require('./expander.js').expander
    }
};

snuggle.up($('body'), controls, {}, false);
```



## The control ##

Now lets take a look at the control itself. This control will handle the open/close buttons and the open/close state.

Snuggle comes with a simple `state` manager. Given a simple string, `open` in our case, a class of `is-open` or `is-not-open` is applied.

Before we go ahead with the JavaScript side of the control, we first need to update our markup.
> **Note:**
 - `data-cosy-control="example.expander"` calls the `expander` control in the `example` namespace
 - `data-role="toggle"` makes it easy to target the button in our JavaScript
 - We've also added some styling to make the list appear only when the expander is `open`

```html
<!-- index.html -->
<style>.is-not-open .expander-detail {display: none}</style>

<div data-cosy-control="example.expander">
    <h4>List authors: <button data-role="toggle">Open</button></h4>

    <ul class="open-detail">
        <li>Neel Upadhyaya</li>
        <li>Rowan Manning</li>
        <li>Andrew Lawson</li>
    </ul>
</div>
```

Next we need to create the actual control.
All this control needs to do is initialise the state, then toggle on click.

```js
// script/expander.js
var expander = function () {
    var state = this.state('open', false);

    this.onEvent('toggle', 'click', function(event) {
        state.toggle();
    });
};
```


## Template (optional) ##

Our expander is working. What else is left to do?
If you look at the markup or play around with your expander, you might notice the button always says `Open`, even if it is open.

An easy way to fix this would be to simply change the text in your javascript.
The problem with this is you have presentation mixed into your control.
This problem is even worse if you want to update the markup.

The solution to this is templates. Cosy comes bundled with the **Hogan Templating Engine** which allows you to render **Mustache**-like templates.

Lets update our markup to include our template
> **Note:**
 - `type="text/mustache"` tells cosy that the script contains a **Mustache**-like template
 - `data-id="button"` lets us target the template
 - `{{#open}}{{/open}}` will render only the correct part of the template depending if `open` is `true` or `false`

```html
<!-- index.html -->
<style>.is-not-open .expander-detail {display: none}</style>

<div data-cosy-control="example.expander">
    <h4>List authors: <button data-role="toggle">Open</button></h4>

    <ul class="expander-detail">
        <li>Neel Upadhyaya</li>
        <li>Rowan Manning</li>
        <li>Andrew Lawson</li>
    </ul>

    <script type="text/mustache" data-id="button">
        {{#open}}Close{{/open}}{{^open}}Open{{/open}}
    </script>
</div>
```

Now for the Javascript.
All we're going to do is replace the content of the toggle button with our rendered template

> **Note:**
 - `_this.template('button');` compiles our named template
 - `state.get()` returns `true` or `false` depending on the state
 - `_this.render(template, context);` renders the template with the given context

```js
// script/expander.js
var expander = function () {
    var state = this.state('open', false);
    _this = this;

    this.onEvent('toggle', 'click', function(event) {
        state.toggle();

        var template = _this.template('button');
        var context  = {
            open: state.get()
        };
        event.element.html(_this.render(template, context));
    });
};
```



## Fin. ##

To conclude, we've just built an expander that opens/closes a list of cosy authors

**View the example on [jsFiddle][fiddle]**


<!-- Meta -->
[examples]: https://github.com/BraveNewTalent/cosy-js/tree/master/example
[fiddle]: http://jsfiddle.net/adlawson/t6NRS
