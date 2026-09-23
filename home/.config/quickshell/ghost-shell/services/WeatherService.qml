pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string city: "Lucknow"
    readonly property real latitude: 26.8467
    readonly property real longitude: 80.9462

    readonly property bool available: availableVal
    readonly property bool loading: fetchProcess.running

    readonly property real temperature: tempVal
    readonly property real feelsLike: feelsLikeVal
    readonly property int humidity: humidityVal
    readonly property real windSpeed: windSpeedVal
    readonly property int weatherCode: codeVal
    readonly property bool isDay: isDayVal
    readonly property string conditionText: conditionTextVal
    readonly property string conditionIcon: conditionIconVal
    readonly property var dailyForecast: forecastVal
    readonly property string lastUpdated: lastUpdatedVal

    property bool availableVal: false
    property real tempVal: 0
    property real feelsLikeVal: 0
    property int humidityVal: 0
    property real windSpeedVal: 0
    property int codeVal: 0
    property bool isDayVal: true
    property string conditionTextVal: "Loading..."
    property string conditionIconVal: "󰖐"
    property var forecastVal: []
    property string lastUpdatedVal: "--:--"

    function getWeatherInfo(code: int, day: bool): var {
        switch (code) {
            case 0:
                return { text: "Clear sky", icon: day ? "󰖙" : "󰖔" };
            case 1:
                return { text: "Mainly clear", icon: day ? "󰖕" : "󰼱" };
            case 2:
                return { text: "Partly cloudy", icon: day ? "󰖕" : "󰼱" };
            case 3:
                return { text: "Overcast", icon: "󰖐" };
            case 45:
            case 48:
                return { text: "Fog", icon: "󰖑" };
            case 51:
            case 53:
            case 55:
                return { text: "Drizzle", icon: "󰖗" };
            case 61:
            case 63:
            case 65:
                return { text: "Rain", icon: "󰖖" };
            case 71:
            case 73:
            case 75:
                return { text: "Snow", icon: "󰼶" };
            case 80:
            case 81:
            case 82:
                return { text: "Showers", icon: "󰖖" };
            case 95:
            case 96:
            case 99:
                return { text: "Thunderstorm", icon: "󰙾" };
            default:
                return { text: "Cloudy", icon: "󰖐" };
        }
    }

    function getDayName(dateStr: string, index: int): string {
        if (index === 0)
            return "Today";
        if (index === 1)
            return "Tomorrow";
        const d = new Date(dateStr + "T00:00:00");
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        return days[d.getDay()] || dateStr;
    }

    function refresh(): void {
        if (fetchProcess.running)
            return;

        const url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
            + "&timezone=auto&forecast_days=3";

        fetchProcess.exec(["curl", "-s", "--max-time", "6", url]);
    }

    Process {
        id: fetchProcess

        stdout: StdioCollector {
            id: fetchOut
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                return;
            }

            const raw = fetchOut.text.trim();
            if (!raw)
                return;

            try {
                const data = JSON.parse(raw);
                if (!data.current)
                    return;

                root.tempVal = Math.round(data.current.temperature_2m * 10) / 10;
                root.feelsLikeVal = Math.round(data.current.apparent_temperature * 10) / 10;
                root.humidityVal = Math.round(data.current.relative_humidity_2m);
                root.windSpeedVal = Math.round(data.current.wind_speed_10m * 10) / 10;
                root.codeVal = data.current.weather_code;
                root.isDayVal = data.current.is_day === 1;

                const currentInfo = root.getWeatherInfo(root.codeVal, root.isDayVal);
                root.conditionTextVal = currentInfo.text;
                root.conditionIconVal = currentInfo.icon;

                const days = [];
                if (data.daily && data.daily.time) {
                    for (let i = 0; i < data.daily.time.length; i++) {
                        const code = data.daily.weather_code[i];
                        const dayInfo = root.getWeatherInfo(code, true);
                        days.push({
                            date: data.daily.time[i],
                            dayName: root.getDayName(data.daily.time[i], i),
                            weatherCode: code,
                            conditionText: dayInfo.text,
                            conditionIcon: dayInfo.icon,
                            minTemp: Math.round(data.daily.temperature_2m_min[i]),
                            maxTemp: Math.round(data.daily.temperature_2m_max[i])
                        });
                    }
                }
                root.forecastVal = days;

                const now = new Date();
                const h = now.getHours().toString().padStart(2, '0');
                const m = now.getMinutes().toString().padStart(2, '0');
                root.lastUpdatedVal = h + ":" + m;

                root.availableVal = true;
            } catch (err) {
                console.warn("WeatherService parse error:", err);
            }
        }
    }

    Timer {
        interval: 900000 // 15 minutes
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "weather"

        function refresh(): void {
            root.refresh();
        }
    }

    Component.onCompleted: {
        root.refresh();
    }
}
