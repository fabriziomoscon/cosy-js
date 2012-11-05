
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
    var todo = this.container('todo'); // the containing div
}
```


`Control.copy`
--------------

Alias of `cosy.core.reference.copy`.


`Control.form`
--------------

Todo.


`Control.get`
-------------

Alias of `cosy.core.reference.get`.


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

The role method is used to select a (single) child element with a `data-role` attribute. The `name` argument specifies the name of the role we wish to select, and the `element` argument allows us to specify an element to query the children of (defaulting to the control element).

```html
<div data-cosy-control="todo">
    Buy some milk and eggs
    <input type="checkbox" data-role="complete"/>
</div>
```

```js
function todo () {
    var checkbox = this.role('checkbox'); // the checkbox element
}
```


`Control.roles`
---------------

The roles method is exactly the same as `role` except that it selects multiple elements.

```html
<ul data-cosy-control="todos">
    <li data-role="todo"> ... </li>
    <li data-role="todo"> ... </li>
    <li data-role="todo"> ... </li>
</ul>
```

```js
function todos () {
    var todo = this.roles('todo'); // the three list items
}
```


`Control.set`
-------------

Alias of `cosy.core.reference.set`.


`Control.state`
---------------

Todo.


`Control.template`
------------------

Todo.


`Control.watch`
---------------

Alias of `cosy.core.reference.watch`.


`Control.watchRef`
------------------

Alias of `cosy.core.reference.watchRef`.
