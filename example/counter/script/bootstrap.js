(function($, snuggle) {

    // Define the controls
    var controls = {
        example: {
            counter: require('./counter.js').counter,
            incrementer: require('./incrementer.js').incrementer
        }
    };

    // Snuggle up!
    snuggle.up($('body'), controls, {}, false);

})(jQuery, require('../lib/cosy.js').snuggle);
