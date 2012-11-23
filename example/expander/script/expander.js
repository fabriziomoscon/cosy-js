(function() {

    /**
     * Expander control
     *
     * Displays a given number
     */
    var expander = function () {

        var state = this.state('open', false);

        _this = this;

        this.onEvent('toggle', 'click', function(event) {
            state.toggle();

            var template = _this.template('template');
            var context  = {
                open: state.get()
            };

            event.element.html(_this.render(template, context));
        });

    };

    module.exports = {
        expander: expander
    };

})();
