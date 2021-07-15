// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// import d3 stuff
// import * as d3 from "d3";

//// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import { Socket } from "phoenix";
import NProgress from "nprogress";
import topbar from "topbar"
import {LiveSocket} from "phoenix_live_view"
import { monitorChart, addToMonitor } from "./monitorchart";

let monitor_element = document.getElementById("monitor");
let monChart = monitorChart(monitor_element);

let Hooks = {};
Hooks.monitor = {
  mounted() {
    this.handleEvent("monitor", ({ monitor }) =>
      addToMonitor(monChart, monitor)
    );
  },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
// let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())
liveSocket.connect()

window.liveSocket = liveSocket
