import {
  Chart,
  ArcElement,
  LineElement,
  BarElement,
  PointElement,
  BarController,
  BubbleController,
  DoughnutController,
  LineController,
  PieController,
  PolarAreaController,
  RadarController,
  ScatterController,
  CategoryScale,
  LinearScale,
  LogarithmicScale,
  RadialLinearScale,
  TimeScale,
  TimeSeriesScale,
  Decimation,
  Filler,
  Legend,
  Title,
  Tooltip
} from 'chart.js';

Chart.register(
  ArcElement,
  LineElement,
  BarElement,
  PointElement,
  BarController,
  BubbleController,
  DoughnutController,
  LineController,
  PieController,
  PolarAreaController,
  RadarController,
  ScatterController,
  CategoryScale,
  LinearScale,
  LogarithmicScale,
  RadialLinearScale,
  TimeScale,
  TimeSeriesScale,
  Decimation,
  Filler,
  Legend,
  Title,
  Tooltip
);

interface dataValue {
  co2: {x: number, y: number, r: number};
  n2o: {x: number, y: number, r: number};
  ch4: {x: number, y: number, r: number};
}

export const addToChart = (chart: Chart, data: dataValue) => {
  if (
    chart === undefined ||
    chart.data === undefined ||
    chart.data.datasets === undefined ||
    chart.data.datasets[0].data === undefined ||
    chart.data.datasets[1].data === undefined ||
    chart.data.datasets[2].data === undefined
  ) {
    return;
  };
  chart.data.datasets[0].data.push(data.co2);
  chart.data.datasets[1].data.push(data.n2o);
  chart.data.datasets[2].data.push(data.ch4);

  while (chart.data.datasets[0].data.length > 60) {
    chart.data.datasets[0].data.shift();
  }
  while (chart.data.datasets[1].data.length > 60) {
    chart.data.datasets[1].data.shift();
  }
  chart.update();
};

export const slopeChart = (ctx: HTMLCanvasElement) => {
  return new Chart(ctx, {
    type: "bubble",
    data: {
      datasets: [
        {
          label: "co2", backgroundColor: "blue", data: [] },
        { label: "n2o", backgroundColor: "red", data: []},
        { label: "ch4", backgroundColor: "green", data: []},
      ],
    },
    options: {
      scales: {
        y: {
            title: {
              display: true,
              text: "slope",
              color: "blue",
            },
            position: "left",
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
