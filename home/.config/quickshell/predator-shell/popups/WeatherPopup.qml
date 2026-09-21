import QtQuick
import Quickshell

import qs.theme
import qs.services

PopupWindow {
    id: root

    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8

    implicitWidth: 320
    implicitHeight: 336

    color: "transparent"
    grabFocus: true

    Rectangle {
        anchors.fill: parent

        color: Theme.base
        border.width: 1
        border.color: Theme.surface0
        radius: Theme.radius

        Column {
            anchors {
                fill: parent
                margins: 14
            }

            spacing: 12

            // HEADER ROW
            Item {
                width: parent.width
                height: 28

                Column {
                    anchors {
                        left: parent.left
                        right: refreshBtn.left
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2

                    Text {
                        text: WeatherService.city + ", IN"
                        font.family: Theme.shellFont
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        text: "Updated " + WeatherService.lastUpdated
                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        color: Theme.subtext0
                    }
                }

                // REFRESH BUTTON
                Rectangle {
                    id: refreshBtn
                    width: 28
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    color: refreshMouse.containsMouse ? Theme.surface1 : Theme.surface0
                    radius: Theme.radius

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.family: Theme.shellFont
                        font.pixelSize: 14
                        color: WeatherService.loading ? Theme.lavender : Theme.text
                        rotation: WeatherService.loading ? 180 : 0

                        Behavior on rotation {
                            NumberAnimation { duration: 400 }
                        }
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WeatherService.refresh()
                    }
                }
            }

            // HERO WEATHER ROW
            Row {
                width: parent.width
                spacing: 16

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: WeatherService.conditionIcon
                    font.family: Theme.shellFont
                    font.pixelSize: 38
                    color: Theme.lavender
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: WeatherService.available
                            ? Math.round(WeatherService.temperature) + "°C"
                            : "--°C"
                        font.family: Theme.shellFont
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        color: Theme.text
                    }

                    Text {
                        text: WeatherService.conditionText
                        font.family: Theme.shellFont
                        font.pixelSize: 11
                        color: Theme.subtext0
                    }
                }
            }

            // METRICS STATS CARDS (3 columns)
            Row {
                width: parent.width
                spacing: 6

                // Feels Like
                Rectangle {
                    width: (parent.width - 12) / 3
                    height: 44
                    color: Theme.surface0
                    radius: Theme.radius

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Feels like"
                            font.family: Theme.shellFont
                            font.pixelSize: 9
                            color: Theme.subtext0
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: WeatherService.available
                                ? Math.round(WeatherService.feelsLike) + "°C"
                                : "--"
                            font.family: Theme.shellFont
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }
                    }
                }

                // Humidity
                Rectangle {
                    width: (parent.width - 12) / 3
                    height: 44
                    color: Theme.surface0
                    radius: Theme.radius

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Humidity"
                            font.family: Theme.shellFont
                            font.pixelSize: 9
                            color: Theme.subtext0
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: WeatherService.available
                                ? WeatherService.humidity + "%"
                                : "--"
                            font.family: Theme.shellFont
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }
                    }
                }

                // Wind
                Rectangle {
                    width: (parent.width - 12) / 3
                    height: 44
                    color: Theme.surface0
                    radius: Theme.radius

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Wind"
                            font.family: Theme.shellFont
                            font.pixelSize: 9
                            color: Theme.subtext0
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: WeatherService.available
                                ? WeatherService.windSpeed + " km/h"
                                : "--"
                            font.family: Theme.shellFont
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }
                    }
                }
            }

            // SEPARATOR
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            // FORECAST HEADER
            Text {
                text: "3-DAY FORECAST"
                font.family: Theme.shellFont
                font.pixelSize: 10
                font.weight: Font.DemiBold
                color: Theme.overlay1
            }

            // FORECAST LIST
            Column {
                width: parent.width
                spacing: 6

                Repeater {
                    model: WeatherService.dailyForecast

                    delegate: Rectangle {
                        required property var modelData

                        width: parent.width
                        height: 28
                        color: "transparent"

                        Row {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                width: 68
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.dayName
                                font.family: Theme.shellFont
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: Theme.text
                            }

                            Text {
                                width: 20
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.conditionIcon
                                font.family: Theme.shellFont
                                font.pixelSize: 13
                                color: Theme.lavender
                            }

                            Text {
                                width: parent.width - 200
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.conditionText
                                font.family: Theme.shellFont
                                font.pixelSize: 10
                                color: Theme.subtext0
                                elide: Text.ElideRight
                            }

                            Text {
                                width: 88
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.minTemp + "° / " + modelData.maxTemp + "°C"
                                font.family: Theme.shellFont
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.text
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }
    }
}
