import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root
    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.margins.top: 0
    anchor.adjustment: PopupAdjustment.Slide
    implicitWidth: Theme.popupCompact
    // Three forecast rows plus the metrics block need stable room at 1.25x
    // scaling; the previous height clipped the final forecast description.
    implicitHeight: 384
    color: "transparent"
    grabFocus: true

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.spacingMd

            PopupHeader {
                Layout.fillWidth: true
                icon: WeatherService.conditionIcon
                title: WeatherService.city
                subtitle: WeatherService.available
                    ? WeatherService.conditionText + " · Updated " + WeatherService.lastUpdated
                    : WeatherService.loading ? "Updating weather…" : "Weather unavailable"
                actionIcon: "󰑐"
                actionEnabled: !WeatherService.loading
                onActionClicked: WeatherService.refresh()
            }
            Divider { Layout.fillWidth: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingLg
                Text {
                    text: WeatherService.conditionIcon
                    font.family: Theme.iconFont
                    font.pixelSize: 38
                    color: Theme.lavender
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: WeatherService.available ? Math.round(WeatherService.temperature) + "°" : "--°"
                        font.family: Theme.monoFont
                        font.pixelSize: Theme.fontDisplay
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }
                    Text {
                        text: "Feels like " + (WeatherService.available ? Math.round(WeatherService.feelsLike) + "°" : "--")
                        font.family: Theme.appFont
                        font.pixelSize: Theme.fontCaption
                        color: Theme.subtext0
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm
                Repeater {
                    model: [
                        { icon: "󰖎", label: "Humidity", value: WeatherService.available ? WeatherService.humidity + "%" : "--" },
                        { icon: "󰖝", label: "Wind", value: WeatherService.available ? WeatherService.windSpeed + " km/h" : "--" }
                    ]
                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 48
                        color: Theme.base
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingSm
                            anchors.rightMargin: Theme.spacingSm
                            Text { text: parent.parent.modelData.icon; font.family: Theme.iconFont; font.pixelSize: 14; color: Theme.sapphire }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text { text: parent.parent.parent.modelData.label; font.family: Theme.appFont; font.pixelSize: Theme.fontCaption; color: Theme.subtext0 }
                                Text { text: parent.parent.parent.modelData.value; font.family: Theme.monoFont; font.pixelSize: Theme.fontBody; font.weight: Font.Medium; color: Theme.text }
                            }
                        }
                    }
                }
            }

            SectionLabel { text: "3-day forecast" }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Repeater {
                    model: WeatherService.dailyForecast
                    PopupRow {
                        required property var modelData
                        Layout.fillWidth: true
                        icon: modelData.conditionIcon
                        label: modelData.dayName
                        description: modelData.conditionText
                        value: modelData.minTemp + "°  /  " + modelData.maxTemp + "°"
                        valueFont: Theme.monoFont
                        interactive: false
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
}
