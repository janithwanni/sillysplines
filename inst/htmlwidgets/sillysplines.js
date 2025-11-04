HTMLWidgets.widget({
  name: "sillysplines",

  type: "output",

  factory: function (el, width, height) {
    // TODO: define shared variables for this instance

    return {
      renderValue: function (x) {
        // TODO: code to render the widget, e.g.
        console.log(x);
        el.innerHTML = x;
      },

      resize: function (width, height) {
        // TODO: code to re-render the widget with a new size
      },
    };
  },
});
