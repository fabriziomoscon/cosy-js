(function($, snuggle) {

    // Define the controls
    var controls = {
        example: {
            expander: require('./expander.js').expander
        }
    };

    // Snuggle up!
    snuggle.up($('body'), controls, {}, false);

})(jQuery, require('../lib/cosy.js').snuggle);
