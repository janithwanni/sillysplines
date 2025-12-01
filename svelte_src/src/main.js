import { mount } from "svelte";
import "./app.css";
import App from "./App.svelte";

export default function sillysplines(target, props) {
  if (target === undefined) {
    target = "app";
  }
  console.log("In main function of sillysplines");
  console.log(target, props);
  console.log(
    `target is ${target} and the element is`,
    document.getElementById(target),
  );
  const app = mount(App, {
    target: document.getElementById(target),
    props: props,
    // TODO: Add an option to pass the initial spline and size as a prop
    // TODO: Future props to add
    // lower region color, opacity
    // upper region color, opacity
    // spline color, stroke-width
    // point color, radius, toAnimate, highlightColor
    // showDownload
  });
  return app;
}

// export default app;
