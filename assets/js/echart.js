import * as echarts from "echarts";

let chart;

export default {
  mounted() {
    chart = echarts.init(this.el);
    chart.setOption({
      xAxis: {
        type: "time",
      },
      yAxis: [
        {
          type: "value",
        },
        {
          type: "value",
        },
      ],
      tooltip: {
        trigger: "axis",
        axisPointer: {
          type: "cross",
          animation: false,
          label: {
            backgroundColor: "#ccc",
            borderColor: "#aaa",
            borderWidth: 1,
            shadowBlur: 0,
            shadowOffsetX: 0,
            shadowOffsetY: 0,
            color: "#222",
          },
        },
      },
      series: [
        {
          name: "Average Sentiment",
          data: [],
          type: "line",
          yAxisIndex: 0,
          smooth: true,
          markLine: {
            show: true,
            data: [
              {
                name: "average line",
                type: "average",
              },
            ],
            lineStyle: {
              color: "red",
            },
          },
        },
        {
          name: "Post Count",
          data: [],
          type: "line",
          yAxisIndex: 1,
          smooth: true,
          markLine: {
            show: true,
            data: [
              {
                name: "average line",
                type: "average",
              },
            ],
            lineStyle: {
              color: "orange",
            },
          },
        },
      ],
    });

    this.handleEvent("datapoints", function (data) {
      const datapoints = data.datapoints.sort(
        (a, b) => new Date(a.inserted_at) - new Date(b.inserted_at),
      );
      const newAverages = datapoints.map((datapoint) => [
        datapoint.inserted_at,
        datapoint.average,
      ]);

      const newCounts = datapoints.map((datapoint) => [
        datapoint.inserted_at,
        datapoint.count,
      ]);

      const currentOption = chart.getOption();
      const currentAverages = currentOption.series[0].data || [];
      const currentCounts = currentOption.series[1].data || [];

      chart.setOption({
        series: [
          {
            name: "Average Sentiment",
            data: [...currentAverages, ...newAverages],
          },
          {
            name: "Post Count",
            data: [...currentCounts, ...newCounts],
          },
        ],
      });
    });
  },
};
