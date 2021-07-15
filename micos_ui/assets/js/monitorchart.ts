import Chart from "chart.js";

interface dataValue {
  co2: [x: number, y: number];
  n2o: [x: number, y: number];
}

export const addToMonitor = (chart: Chart, data: [dataValue]) => {
  if (
    chart === undefined ||
    chart.data === undefined ||
    chart.data.datasets === undefined ||
    chart.data.datasets[0].data === undefined ||
    chart.data.datasets[1].data === undefined
  ) {
    return;
  }
  data.forEach(function (datum) {
    if (
      chart.data.datasets === undefined ||
      chart.data.datasets[0].data === undefined ||
      chart.data.datasets[1].data === undefined
    ) {
      return;
    }
    chart.data.datasets[0].data.push(datum["co2"]);
    chart.data.datasets[1].data.push(datum["n2o"]);
  });

  while (chart.data.datasets[0].data.length > 600) {
    chart.data.datasets[0].data.shift();
  }
  while (chart.data.datasets[1].data.length > 600) {
    chart.data.datasets[1].data.shift();
  }
  chart.update();
};

export const monitorChart = (ctx: HTMLCanvasElement) => {
  return new Chart(ctx, {
    type: "scatter",
    data: {
      datasets: [
        {
          label: "CO2",
          backgroundColor: "blue",
          data: [],
          yAxisID: "co2-axis",
        },
        { label: "N2O", backgroundColor: "red", data: [], yAxisID: "n2o-axis" },
      ],
    },
    options: {
      tooltips: {
        enabled: true,
      },
      scales: {
        yAxes: [
          {
            scaleLabel: {
              display: true,
              labelString: "ppm CO2",
              fontColor: "blue",
            },
            position: "left",
            ticks: {
              beginAtZero: false,
            },
            id: "co2-axis",
          },
          {
            scaleLabel: {
              display: true,
              labelString: "ppm N2O",
              fontColor: "red",
            },
            position: "right",
            ticks: {
              beginAtZero: false,
            },
            id: "n2o-axis",
            gridLines: {
              drawOnChartArea: false,
            },
          },
        ],
        xAxes: [
          {
            type: "time",
            time: {
              unit: "minute",
            },
          },
        ],
      },
      layout: {
        padding: {
          left: 20,
          right: 20,
          top: 0,
          bottom: 20,
        },
      },
    },
  });
};
