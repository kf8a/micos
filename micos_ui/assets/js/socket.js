// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

// import d3 stuff
import * as d3 from "d3";

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("data:update", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

let data = []

channel.on('new_data', msg => {
  // console.log("msg : ", msg);

  let localtime = new Date(msg.time)
  data.push({time: new Date(msg.time), co2: msg.co2});
  if (data.length > 500)
    data = data.splice(1, 500);
  render()
  // console.log("time :", localtime);
  // console.log("data :", data);
})

var margin = {top: 50, right: 50, bottom: 50, left: 50}
  , width = window.innerWidth - margin.left - margin.right // Use the window's width
  , height = 300 - margin.top - margin.bottom; // Use the window's height

let my_duration = 5 * 600000;

var xScale = d3.scaleTime()
    .domain([new Date() - my_duration, new Date()]) // input
    .range([0, width]); // output

var yScale = d3.scaleLinear()
    .domain([0, 1]) // input
    .range([height, 0]); // output

var line = d3.line()
    .x(function(d) { return xScale(d.time); }) // set the x values for the line generator
    .y(function(d) { return yScale(d.co2); }) // set the y values for the line generator
    .curve(d3.curveMonotoneX) // apply smoothing to the line

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(xScale)); // Create an axis component with d3.axisBottom

svg.append("g")
    .attr("class", "y axis")
    .call(d3.axisLeft(yScale)); // Create an axis component with d3.axisLeft

let render = function() {
// svg.append("path")
//     .datum(data) // 10. Binds data to the line
//     .attr("class", "line") // Assign a class for styling
//     .attr("d", line); // 11. Calls the line generator

svg.selectAll(".dot")
    .data(data)
  .enter().append("circle") // Uses the enter().append() method
    .attr("class", "dot") // Assign a class for styling
    .attr("cx", function(d) { return xScale(d.time) })
    .attr("cy", function(d) { return yScale(d.co2) })
    .attr("r", 5)
      .on("mouseover", function(a, b, c) {
  			console.log(a)
        this.attr('class', 'focus')
		})
      .on("mouseout", function() {  })

  svg.selectAll(".dot").exit().remove();
}

function realTimeLineChart() {
  var margin = {top: 20, right: 20, bottom: 20, left: 20},
      width = 600,
      height = 400,
      duration = 500,
      color = d3.schemeCategory10;

  function chart(selection) {
    // Based on https://bl.ocks.org/mbostock/3884955
    selection.each(function(data) {
      data = ["x", "y", "z"].map(function(c) {
        return {
          label: c,
          values: data.map(function(d) {
            return {time: +d.time, value: d[c]};
          })
        };
      });

      var t = d3.transition().duration(duration).ease(d3.easeLinear),
          x = d3.scaleTime().rangeRound([0, width-margin.left-margin.right]),
          y = d3.scaleLinear().rangeRound([height-margin.top-margin.bottom, 0]),
          z = d3.scaleOrdinal(color);

      var xMin = d3.min(data, function(c) { return d3.min(c.values, function(d) { return d.time; })});
      var xMax = new Date(new Date(d3.max(data, function(c) {
        return d3.max(c.values, function(d) { return d.time; })
      })).getTime() - (duration*2));

      x.domain([xMin, xMax]);
      y.domain([
        d3.min(data, function(c) { return d3.min(c.values, function(d) { return d.value; })}),
        d3.max(data, function(c) { return d3.max(c.values, function(d) { return d.value; })})
      ]);
      z.domain(data.map(function(c) { return c.label; }));

      var line = d3.line()
        .curve(d3.curveBasis)
        .x(function(d) { return x(d.time); })
        .y(function(d) { return y(d.value); });

      var svg = d3.select(this).selectAll("svg").data([data]);
      var gEnter = svg.enter().append("svg").append("g");
      gEnter.append("g").attr("class", "axis x");
      gEnter.append("g").attr("class", "axis y");
      gEnter.append("defs").append("clipPath")
          .attr("id", "clip")
        .append("rect")
          .attr("width", width-margin.left-margin.right)
          .attr("height", height-margin.top-margin.bottom);
      gEnter.append("g")
          .attr("class", "lines")
          .attr("clip-path", "url(#clip)")
        .selectAll(".data").data(data).enter()
          .append("path")
            .attr("class", "data");

      var legendEnter = gEnter.append("g")
        .attr("class", "legend")
        .attr("transform", "translate(" + (width-margin.right-margin.left-75) + ",25)");
      legendEnter.append("rect")
        .attr("width", 50)
        .attr("height", 75)
        .attr("fill", "#ffffff")
        .attr("fill-opacity", 0.7);
      legendEnter.selectAll("text")
        .data(data).enter()
        .append("text")
          .attr("y", function(d, i) { return (i*20) + 25; })
          .attr("x", 5)
          .attr("fill", function(d) { return z(d.label); });

      var svg = selection.select("svg");
      svg.attr('width', width).attr('height', height);
      var g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      g.select("g.axis.x")
        .attr("transform", "translate(0," + (height-margin.bottom-margin.top) + ")")
        .transition(t)
        .call(d3.axisBottom(x).ticks(5));
      g.select("g.axis.y")
        .transition(t)
        .attr("class", "axis y")
        .call(d3.axisLeft(y));

      g.select("defs clipPath rect")
        .transition(t)
        .attr("width", width-margin.left-margin.right)
        .attr("height", height-margin.top-margin.right);

      g.selectAll("g path.data")
        .data(data)
        .style("stroke", function(d) { return z(d.label); })
        .style("stroke-width", 1)
        .style("fill", "none")
        .transition()
        .duration(duration)
        .ease(d3.easeLinear)
        .on("start", tick);

      g.selectAll("g .legend text")
        .data(data)
        .text(function(d) {
          return d.label.toUpperCase() + ": " + d.values[d.values.length-1].value;
        });

      // For transitions https://bl.ocks.org/mbostock/1642874
      function tick() {
        d3.select(this)
          .attr("d", function(d) { return line(d.values); })
          .attr("transform", null);

        var xMinLess = new Date(new Date(xMin).getTime() - duration);
        d3.active(this)
            .attr("transform", "translate(" + x(xMinLess) + ",0)")
          .transition()
            .on("start", tick);
      }
    });
  }

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  chart.color = function(_) {
    if (!arguments.length) return color;
    color = _;
    return chart;
  };

  chart.duration = function(_) {
    if (!arguments.length) return duration;
    duration = _;
    return chart;
  };

  return chart;
}

 var lineArr = [];
    var MAX_LENGTH = 100;
    var duration = 500;
    var chart = realTimeLineChart();

    function randomNumberBounds(min, max) {
      return Math.floor(Math.random() * max) + min;
    }

    function seedData() {
      var now = new Date();
      for (var i = 0; i < MAX_LENGTH; ++i) {
        lineArr.push({
          time: new Date(now.getTime() - ((MAX_LENGTH - i) * duration)),
          x: randomNumberBounds(0, 5),
          y: randomNumberBounds(0, 2.5),
          z: randomNumberBounds(0, 10)
        });
      }
    }

    function updateData() {
      var now = new Date();

      var lineData = {
        time: now,
        x: randomNumberBounds(0, 5),
        y: randomNumberBounds(0, 2.5),
        z: randomNumberBounds(0, 10)
      };
      lineArr.push(lineData);

      if (lineArr.length > 30) {
        lineArr.shift();
      }
      d3.select("#chart").datum(lineArr).call(chart);
    }

    function resize() {
      if (d3.select("#chart svg").empty()) {
        return;
      }
      chart.width(+d3.select("#chart").style("width").replace(/(px)/g, ""));
      d3.select("#chart").call(chart);
    }

    document.addEventListener("DOMContentLoaded", function() {
      seedData();
      window.setInterval(updateData, 500);
      d3.select("#chart").datum(lineArr).call(chart);
      d3.select(window).on('resize', resize);
    });
export default socket
