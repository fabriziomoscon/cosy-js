(function() {

    /**
     * Counter control
     *
     * Displays a given number
     *
     * @param [Number] count
     */
    var counter = function (count) {

        // Populate [data-role="count"] with the count
        this.role('count').text(count || 0);

    };

    // Export
    module.exports = {
        counter: counter
    };

})();
