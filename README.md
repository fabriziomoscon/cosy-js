
Cosy
====

A cosy little library.

[![Build Status][travis-status]][travis]


## Installation ##

Just install with `npm install cosy-js` or add it to your
`package.json`.

If you use a bundler like [Browserify][browserify], then Cosy
will work just fine in-browser too.


## Usage ##

Cosy is typically used through our high level abstraction library, Snuggle.
Bootstrapping Snuggle is easy.

```js
(function($, snuggle) {

    var controls = {};
    var library = {};
    var debug = false;

    snuggle.up($('body'), controls, library, debug);

})(jQuery, cosy.snuggle);​
```

If you want to work with Cosy itself, you can bootstrap it just as easily as with Snuggle.

```js
(function($, cosy) {

    var imports = {};

    cosy.up($('body'), imports);

})(jQuery, cosy);​
```
If you're using a package manager such as `Browserify` or `CommonJs` (bundled with Node.js), you can simply require our main file.

```js
var cosy = require('path/to/cosy/lib/cosy.js');
var snuggle = cosy.snuggle;
```



## Development ##

In order to develop Cosy, you'll need to install the following
npm modules globally like so:

    npm install -g coffee-script
    npm install -g jake

And then install development dependencies locally with:

    npm install

Once you have these dependencies, you will be able to run the
following commands:

`jake build`: Build JavaScript from the CoffeeScript source.

`jake lint`: Run CoffeeLint on the CoffeeScript source.

`jake test`: Run all unit tests.

## Documentation ##
Read the documentation [here](./cosy-js/blob/master/docs/index.md)

## License ##

Licensed under the [MIT][mit] license.


[browserify]: https://github.com/substack/node-browserify
[mit]: http://opensource.org/licenses/mit-license.php
[travis]: https://secure.travis-ci.org/BraveNewTalent/cosy-js
[travis-status]: https://secure.travis-ci.org/BraveNewTalent/cosy-js.png?branch=master
