(function($, snuggle) {

    // Define the controls
    var controls = {
        example: {
            list: {
                input: require('./input.js').input
            }
        }
    };

    // Snuggle up!
    snuggle.up($('body'), controls, {}, false);

})(jQuery, require('../lib/cosy.js').snuggle);
