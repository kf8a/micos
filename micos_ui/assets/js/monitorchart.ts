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

  while (chart.data.datasets[0].data.length > 90) {
    chart.data.datasets[0].data.shift();
  }
  while (chart.data.datasets[1].data.length > 90) {
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
          label: "CO2", backgroundColor: "blue", data: [], yAxisID: "co2"},
        { label: "N2O", backgroundColor: "red", data: [], yAxisID: "n2o" },
      ],
    },
    options: {
      scales: {
        co2: {
          title: {
            display: true,
            text: "ppm CO2",
            color: "blue",
          },
          position: "left",
          ticks: {
          },
          // id: "co2-axis",
          beginAtZero: false,
        },
        n2o: {
          title: {
            display: true,
            text: "ppb N2O",
            color: "red",
          },
          position: "right",
          beginAtZero: false,
          grid: {
            drawOnChartArea: false,
          },
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
