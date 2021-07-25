// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

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
import { monitorChart, addToChart, clearChart} from "./monitorchart";
import { RSQChart, addToRSQChart, clearRSQChart } from "./rsquarechart";

let monitor_element = document.getElementById("monitor")
let monChart = monitorChart(monitor_element, "ppm CO2/ppb N2O", "ppm CH4");

let slope_element = document.getElementById("slope");
let sChart = monitorChart(slope_element, "slope CO2/N2O", "slope CH4");

let r_element = document.getElementById("r2");
let rChart = RSQChart(r_element, "r2");

let Hooks = {};
Hooks.monitor = {
  mounted() {
    this.handleEvent("monitor", ({ monitor }) => addToChart(monChart, monitor));
  }
};
Hooks.slope = {
  mounted() {
    this.handleEvent("slope", ({ monitor }) => addToChart(sChart, monitor));
    this.handleEvent("reset", () => clearChart(sChart));
  }
}
Hooks.r2 = {
  mounted() {
    this.handleEvent("r2", ({ monitor }) => addToRSQChart(rChart, monitor));
    this.handleEvent("reset", () => clearRSQChart(rChart));
  }
}


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
