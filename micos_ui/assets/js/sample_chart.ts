import Chart from "chart.js";
// import { isArray } from "util";

interface sampleDataValue {
  data: [x: number, y: number] | Array<number> | [];
  line: [[x: number, y: number], [x: number, y: number]];
}

export const sampleAddPoints = (
  chart: Chart,
  data: sampleDataValue // | [sampleDataValue]
) => {
  if (
    chart === undefined ||
    chart.data === undefined ||
    chart.data.datasets === undefined ||
    chart.data.datasets[0] === undefined ||
    chart.data.datasets[0].data === undefined
  ) {
    return;
  }
  if (Array.isArray(data["data"]) && data["data"].length == 0) {
    chart.data.datasets[0].data = [];
  } else if (data["data"].length > 1) {
    chart.data.datasets[0].data = data["data"];
  } else {
    chart.data.datasets[0].data.push(data["data"]);
    chart.data.datasets[1].data = data["line"];
  }
  chart.update();
};

export const sampleChart = (
  ctx: HTMLCanvasElement,
  color: string,
  label: string,
  unit: string
) => {
  return new Chart(ctx, {
    type: "scatter",
    data: {
      datasets: [
        {
          label: label,
          backgroundColor: color,
          data: [],
        },
        {
          label: "flux",
          backgroundColor: color,
          borderColor: color,
          fill: false,
          data: [],
          type: "line",
        },
      ],
    },
    options: {
      tooltips: {
        enabled: false,
      },
      legend: {
        display: true,
        labels: {
          filter: function (item, _data) {
            return item.text != "flux";
          },
        },
      },
      scales: {
        yAxes: [
          {
            scaleLabel: {
              display: true,
              labelString: `${unit} ${label}`,
              fontColor: color,
            },
            position: "left",
            ticks: {
              beginAtZero: false,
            },
          },
        ],
        xAxes: [
          {
            scaleLabel: {
              display: true,
              labelString: "seconds",
            },
          },
        ],
      },
    },
  });
};
