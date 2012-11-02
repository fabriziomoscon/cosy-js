
Control Object
==============

The control object in snuggle is the object that gets passed into controls and control classes as a context. It exposes lots of methods, documented below, to reduce the code required to perform common tasks.

The control object also has an `element` property, which is a jQuery object representing the DOM element the control is bound to. Most methods also allow you to pass in your own element to act on.


`Control.container( name [, element] )`
-------------------

The container method is used to select a parent element with a `data-container` attribute. The `name` argument specifies the name of the container we wish to select, and the `element` argument allows us to specify an element to query the parents of (defaulting to the control element).

```html
<div data-container="todo">
    Buy some milk and eggs
    <input type="checkbox" data-cosy-control="complete"/>
</div>
```

```js
function complete () {
    var control = this;
    control.element.on('change', function () {
        if (control.element.is(':checked')) {
            this.container('todo').addClass('done');
        } else {
            this.container('todo').removeClass('done');
        }
    })
}
```


`Control.copy`
--------------

Todo.


`Control.form`
--------------

Todo.


`Control.get`
-------------

Todo.


`Control.global`
----------------

Todo.


`Control.html`
--------------

Todo.


`Control.list`
--------------

Todo.


`Control.notify`
----------------

Todo.


`Control.onEvent`
-----------------

Todo.


`Control.query`
---------------

Todo.


`Control.render`
----------------

Todo.


`Control.renderRaw`
-------------------

Todo.


`Control.role`
--------------

Todo.


`Control.roles`
---------------

Todo.


`Control.set`
-------------

Todo.


`Control.state`
---------------

Todo.


`Control.template`
------------------

Todo.


`Control.watch`
---------------

Todo.


`Control.watchRef`
------------------

Todo.
