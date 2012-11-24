#### [Examples][examples] > List ####



# List #

This is a simple step-by-step guide to creating a basic list control.
The completed feature will display an input field which appends or prepends text onto a list.



## Setup ##

First thing's first, as usual, we need to setup our markup.

 > **Note:** You must also include your bundled JavaScript file and jQuery with `<script>` tags

```html
<!-- index.html -->
<form>
    <input type="text"/>
    <button>Append</button>
    <button>Prepend</button>
</form>

<ul>
    <li>Original item</li>
</ul>
```



## Bootstrap ##

Now we need to create a bootstrap file for our JavaScript library.
We'll also define the control we're about to make, `input`, in the `example.list` namespace.

Snuggle comes bundled with it's own list control that can be used as-is or extended.

```js
// script/bootstrap.js
var controls = {
    example: {
        list: {
            input: require('./input.js').input
        }
    }
};

snuggle.up($('body'), controls, {}, false);
```



## List ##

First we'll take a look at Snuggle's list control. This control handles the list and offers a natural API for managing items.

In the **Counter** example, we used a scoped property using `@count`. In this example, we'll use global properties.
Global properties are available to all controls in the DOM.
They are created the first time they are called using `%nyGlobalProperty`

All we need to do in this case is update our markup. The list control is ready to use.
> **Note:**
 - `data-cosy-control="cosy.List &%items"` creates an instance of the `cosy.List` class control with a reference to a new global property `items`
 - `data-item` marks that child node as a list item to be managed by our list control
 - `<script type="text/mustache" data-id="item">` is the template the list control uses to render new items

```html
<!-- index.html -->
<form>
    <input type="text"/>
    <button>Append</button>
    <button>Prepend</button>
</form>

<ul data-cosy-class="cosy.List &%items">
    <li data-item>Original item</li>

    <script type="text/mustache" data-id="item">
        <li>{{ content }}</li>
    </script>
</ul>
```


## Input ##

To complete the feature we need to bind our input field to our list. Again, we need to update the markup.

> **Note:**
 - `data-cosy-control="example.list.input %items"` calls the `example.list.input` control with the value of `list` as it's argument
 - `data-role="[inout|append|prepend]"` makes it easy to target the form elements

```html
<!-- index.html -->
<form data-cosy-control="example.list.input %items">
    <input type="text" data-role="input"/>
    <button data-role="append">Append</button>
    <button data-role="prepend">Prepend</button>
</form>

<ul data-cosy-class="cosy.List &%items">
    <li data-item>Original item</li>

    <script type="text/mustache" data-id="item">
        <li>{{ content }}</li>
    </script>
</ul>
```

Now for the Javascript.
Remember that when you create a control with a reference as an argument, it will be called every time the value is modified.

> **Note:**
 - `_this.list.push` and `_this.list.unshift` are uses of the natural API of the list collection
 - `data = {content: input.val()}` is the context our template will be rendered with

```js
// script/input.js
var input = function (list) {

    this.list = list;
    _this = this;

    if (this.isInitialising) {
        var input = this.role('input');

        var append = function() {
            var data = {
                content: input.val()
            };

            if (data.content.length > 0) {
                _this.list.push(data);
                input.val('');
            }
        };

        var prepend = function() {
            var data = {
                content: input.val()
            };

            if (data.content.length > 0) {
                _this.list.unshift(data);
                input.val('');
            }
        };

        this.onEvent('append', 'click', append);
        this.onEvent('prepend', 'click', prepend);

        this.onEvent('submit', function(event) {
            event.stop();
            append();
        });

    }
};
```



## Fin. ##

To conclude, we've just built a simple input field which either prepends or appends text onto a list.

**jsFiddle** coming soon...


<!-- Meta -->
[examples]: https://github.com/BraveNewTalent/cosy-js/tree/master/example
