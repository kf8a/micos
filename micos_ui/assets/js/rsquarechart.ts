import {
  Chart,
  ArcElement,
  LineElement,
  PointElement,
  LineController,
  ScatterController,
  LinearScale,
  TimeScale,
  TimeSeriesScale,
  Decimation,
  Filler,
  Legend,
  Title,
} from 'chart.js';
import 'chartjs-adapter-date-fns';

Chart.register(
  ArcElement,
  LineElement,
  PointElement,
  LineController,
  ScatterController,
  LinearScale,
  TimeScale,
  TimeSeriesScale,
  Decimation,
  Filler,
  Legend,
  Title,
);

interface dataValue {
  co2: {x: number, y: number};
  n2o: {x: number, y: number};
  ch4: {x: number, y: number};
}

export const clearRSQChart = (chart: Chart) => {
  chart.data.datasets[0].data = [];
  chart.data.datasets[1].data = [];
  chart.data.datasets[2].data = [];
  chart.update();
}

export const addToRSQChart = (chart: Chart, data: [dataValue]) => {
  if (
    chart === undefined ||
    chart.data === undefined ||
    chart.data.datasets === undefined ||
    chart.data.datasets[0].data === undefined ||
    chart.data.datasets[1].data === undefined ||
    chart.data.datasets[2].data === undefined
  ) {
    return;
  }
  data.forEach(function (datum) {
    if (
      chart.data.datasets === undefined ||
      chart.data.datasets[0].data === undefined ||
      chart.data.datasets[1].data === undefined ||
      chart.data.datasets[2].data === undefined
    ) {
      return;
    }
    chart.data.datasets[0].data.push(datum["co2"]);
    chart.data.datasets[1].data.push(datum["n2o"]);
    chart.data.datasets[2].data.push(datum["ch4"]);
  });

  let max_points = 90;
  while (chart.data.datasets[0].data.length > max_points) {
    chart.data.datasets[0].data.shift();
  }
  while (chart.data.datasets[1].data.length > max_points) {
    chart.data.datasets[1].data.shift();
  }
  while (chart.data.datasets[2].data.length > max_points) {
    chart.data.datasets[2].data.shift();
  }
  chart.update();
};

export const RSQChart = (ctx: HTMLCanvasElement, y1_title: string) => {
  return new Chart(ctx, {
    type: "scatter",
    data: {
      datasets: [
        { label: "CO2", backgroundColor: "blue", data: [], yAxisID: "co2"},
        { label: "N2O", backgroundColor: "red", data: [], yAxisID: "co2" },
        { label: "CH4", backgroundColor: "green", data: [], yAxisID: "co2" },
      ],
    },
    options: {
      scales: {
        co2: {
          title: {
            display: true,
            text: y1_title,
          },
          position: "left",
          max: 1,
          min: 0,
          ticks: {
          },
          beginAtZero: false,
        },
        x: {
          type: "time",
          time: {
            unit: "minute",
          },
        },
      },
      layout: {
        padding: {
          left: 20,
          right: 20,
          top: 0,
          bottom: 20,
        },
      },
      plugins: {
        tooltip: { enabled: false}
      }
    },
  });
};
