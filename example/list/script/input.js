(function() {

    /**
     * Expander control
     *
     * Displays a given number
     */
    var input = function (list) {

        this.list = list;
        _this = this;

        if (this.isInitialising) {

            var input = this.role('input');

            var append = function() {
                var data = {
                    content: input.val()
                };

                if (data.content.length > 0) {
                    _this.list.push(data);
                    input.val('');
                }
            };

            var prepend = function() {
                var data = {
                    content: input.val()
                };

                if (data.content.length > 0) {
                    _this.list.unshift(data);
                    input.val('');
                }
            };

            this.onEvent('append', 'click', append);
            this.onEvent('prepend', 'click', prepend);

            this.onEvent('submit', function(event) {
                event.stop();
                append();
            });

        }

    };

    module.exports = {
        input: input
    };

})();
