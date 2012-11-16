(function() {

    // Dependencies
    var mutable = require('../../lib/protocol/mutable.js');
    var get = mutable.get;
    var set = mutable.set;

    /**
     * Incrementer control
     *
     * Increments a number in a given reference
     *
     * @param [Reference] reference
     */
    var incrementer = function (reference) {

        if (this.isInitialising) {

            // Store the initial value
            this.initial = get(reference) || null;

            // Bind click event to submit button
            this.onEvent('button', 'click', function () {
                // Set the reference to val+1
                var value = get(reference);
                set(reference, ++value);
            });

            // Bind click event to reset button
            this.onEvent('reset', 'click', function () {
                // Set the reference to the initial value
                set(reference, 0);
            });

        }

    };

    // Export
    module.exports = {
        incrementer: incrementer
    };

})();
