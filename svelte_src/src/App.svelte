<script>
import {onMount} from "svelte";
import * as d3 from "d3"
let width = 640;
let height = 640;
const svgBounds = {xMin:0, yMin:0, xMax: width, yMax: height}
const targetBounds = {xMin: -10, yMin: -10, xMax: 10, yMax: 10}
const scale = (x, domMin, domMax, ranMin, ranMax) => {
  return ((x - domMin) / (domMax - domMin)) * (ranMax - ranMin) + ranMin
}
const translateCoords = function(points) {
    points = points.map(p => {
        return [
          scale(p[0], svgBounds.xMin, svgBounds.xMax, targetBounds.xMin, targetBounds.xMax),
          scale(p[1], svgBounds.yMin, svgBounds.yMax, targetBounds.yMax, targetBounds.yMin) // switch y axis
        ]  
      })
    return points
}


let container;
// TODO: This is not good to hard code coordinates but I have to for the show
let points = $state([[0, height], 
  [36, 440],
  [185, 440],
  [310, 280],
  [480, 480],
  // [width/4, height / 4],
  // [width*0.75, height*0.75],
  [width, 0]])
const coords = JSON.stringify(translateCoords($state.snapshot(points))) 
console.log(coords)
if (typeof Shiny !== "undefined"){
Shiny.setInputValue("svelte_data", coords, { priority: "event" });
Shiny.setInputValue("app-primary-svelte_data", coords, { priority: "event" });
}
$inspect(points)

let svg;
let selected = $derived(points[0])
let upperPolygon = $derived([
  [0,0],
  ...points,
  [width, 0]
])
let lowerPolygon = $derived([
  [0, height],
  ...points,
  [width, height] //,
])

const svg2Screen = function(x,y) {
// need svgpoint and  inverse mat
  const pt = svg.node().createSVGPoint();
  pt.x = x 
  pt.y = y 
  return pt.matrixTransform(svg.node().getScreenCTM().inverse())
}

const dragSubject = function(e) {
    let subject = e.sourceEvent.target.__data__;
    if(!subject) {
      console.log("adding new point")
      let transP = svg2Screen(e.sourceEvent.x, e.sourceEvent.y)
      subject = [transP.x, transP.y]
        points.push(subject = [transP.x, transP.y]);
      console.log("sorting set of points")
        points.sort((a, b) => b[0] - a[0])
        update()
      }
    return subject;
  }

const dragStarted = function({subject}) {
    selected = subject;
    update();
  }

const dragged = function(e) {
    let transP = svg2Screen(e.sourceEvent.x, e.sourceEvent.y)
    e.subject[0] = Math.max(0, Math.min(width, transP.x));
    e.subject[1] = Math.max(0, Math.min(height, transP.y));
    update()
  }

const updatePolygon = function() {
  console.log("updating polygons")
        // Draw the upper polygon
    d3.select("#upper-poly")
      .attr("points", upperPolygon.sort((a,b) => a[0] - b[0]).map(p => p.join(",")).join(" "))

    // Draw the lower polygon
    d3.select("#lower-poly")
      .attr("points", lowerPolygon.sort((a,b) => a[0] - b[0]).map(p => p.join(",")).join(" "))

}

const update = function(){
    const line = d3.line().curve(d3.curveLinear)
    svg.select("#pathLine").attr("d", line)
    svg.append("g").attr("id", "circles")
    const circle = svg.select("#circles").selectAll("g")
      .data(points, d => d)

    circle.enter().append("g")
      .call(g => g.append("circle")
        .attr("r", 30)
        .attr("fill", "none")
      )
      .call(g => g.append("circle")
        .attr("r", 0)
        .attr("stroke", "black")
        .attr("stroke-width", 1.5)
        .transition()
        .duration(750)
        .attr("r", 5)
      )
      .merge(circle)
      .attr("transform", d => `translate(${d})`)
      .select("circle:last-child")
      .attr("fill", d => d === selected ? "lightblue": "black" )

    circle.exit().remove();
    updatePolygon()
    const coords = JSON.stringify(translateCoords($state.snapshot(points))) 
    console.log($state.snapshot(points))
    console.log(coords)
    if (typeof Shiny !== "undefined") {
    Shiny.setInputValue("svelte_data", coords, { priority: "event" });
    Shiny.setInputValue("app-primary-svelte_data", coords, { priority: "event" });
      }
}


onMount(() => {

  svg = d3.create("svg")
    .attr("viewBox", [0, 0, width, height])
    .attr("tabIndex", 1)
    .attr("pointer-events", "all")
    .attr("style", "display: block; width: 100%; height: 100%")
    .call(d3.drag()
      .subject(dragSubject)
      .on("start", dragStarted)
      .on("drag", dragged)
    )

  const xScale = d3.scaleLinear()
    .domain([0, width])
    .range([0, width])

  const yScale = d3.scaleLinear()
    .domain([0, height])
    .range([0, height])

  svg.append("rect")
    .attr("fill", "none")
    .attr("width", width)
    .attr("height", height)

      // Draw the upper polygon
    svg.append("polygon")
      .attr("id", "upper-poly")
      .attr("pointer-events", "none")
      .attr("points", upperPolygon.map(p => p.join(",")).join(" "))
      .attr("fill", "lightblue")
      .attr("opacity", 0.5);

    // Draw the lower polygon
    svg.append("polygon")
      .attr("id", "lower-poly")
      .attr("pointer-events", "none")
      .attr("points", lowerPolygon.sort((a,b) => a[0] - b[0]).map(p => p.join(",")).join(" "))
      .attr("fill", "lightcoral")
      .attr("opacity", 0.5);

  svg.append("path")
    .attr("id", "pathLine")
    .datum(points)
    .attr("fill", "none")
    .attr("stroke", "black")
    .attr("stroke-width", 1.5)
    .call(update)
    
  container.append(svg.node())
  })

const handleDownload = function(event) {
  const coords = JSON.stringify(translateCoords($state.snapshot(points))) 
  console.log(coords)
  if (typeof Shiny  !== "undefined") {
  Shiny.setInputValue("svelte_data", coords, { priority: "event" });
  Shiny.setInputValue("app-primary-svelte_data", coords, { priority: "event" });
    }
}

</script>

<div bind:this={container} style={`border: 1px solid black; width: 100%; aspect-ratio: ${height}/${width}`}>
</div>
<div style="width: 100%; padding-top: 1em; display: flex; justify-content: center; align-items: center">
<!-- <input style="padding: 1em; color: white; background-color: black; border-radius: 1em"  type="button" value="Load boundary" id = "load_bounds" onclick={handleDownload}/> -->
</div>

<style>
svg[tabindex] {
    display:block;
    margin: 0 -14px;
    border: solid 2px transparent;
}

svg[tabindex]:focus {
    outline: none;
    border: solid 2px lightblue;
}
</style>
