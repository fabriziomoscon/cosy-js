(function() {

    /**
     * Incrementer control
     *
     * Increments a number in a given reference
     *
     * @param [Reference] count
     */
    var incrementer = function (count) {

        if (this.isInitialising) {

            var _this = this;

            // Increment the count on [data-role="button"] click
            this.onEvent('button', 'click', function () {
                var value = _this.get(count);
                _this.set(count, ++value);
            });

            // Reset the count on [data-role="reset"] click
            this.onEvent('reset', 'click', function () {
                _this.set(count, 0);
            });

        }

    };

    module.exports = {
        incrementer: incrementer
    };

})();
