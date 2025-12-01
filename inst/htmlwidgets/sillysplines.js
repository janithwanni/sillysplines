HTMLWidgets.widget({
  name: "sillysplines",

  type: "output",

  factory: function (el, width, height) {
    // TODO: define shared variables for this instance

    return {
      renderValue: function (x) {
        console.log("About to render widget");
        console.log(x);
        // TODO: code to render the widget, e.g.
        sillysplines(x.target, x.props);
      },

      resize: function (width, height) {
        // TODO: code to re-render the widget with a new size
      },
    };
  },
});
