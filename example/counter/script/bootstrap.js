// Application bootstrap
(function($, snuggle) {

    // Define our controls
    controls = {
        example: {
            counter: require('./counter.js').counter,
            incrementer: require('./incrementer.js').incrementer
        }
    };

    // Useful application lib/utils
    lib = {};

    // Debug level
    debug = false;

    // Bind snuggle to the root node
    snuggle.up($('html'), controls, lib, debug);

})(jQuery, require('../lib/cosy.js').snuggle);
