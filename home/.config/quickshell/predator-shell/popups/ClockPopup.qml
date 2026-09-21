import QtQuick
import Quickshell

import qs.theme

PopupWindow {
    id: root

    property Item anchorItem

    property int displayYear: clock.date.getFullYear()
    property int displayMonth: clock.date.getMonth()

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 8

    implicitWidth: 312
    implicitHeight: content.implicitHeight + 32

    color: "transparent"

    grabFocus: true

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function daysInMonth(year: int, month: int): int {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOffset(): int {
        // JavaScript: Sunday = 0.
        // Convert to Monday = 0.
        return (new Date(displayYear, displayMonth, 1).getDay() + 6) % 7;
    }

    function dayAt(index: int): int {
        const day = index - firstDayOffset() + 1;

        if (day < 1 || day > daysInMonth(displayYear, displayMonth))
            return 0;

        return day;
    }

    function isToday(day: int): bool {
        return day > 0
            && day === clock.date.getDate()
            && displayMonth === clock.date.getMonth()
            && displayYear === clock.date.getFullYear();
    }

    function shiftMonth(offset: int): void {
        const next =
            new Date(displayYear, displayMonth + offset, 1);

        displayYear = next.getFullYear();
        displayMonth = next.getMonth();
    }

    onVisibleChanged: {
        if (visible) {
            displayYear = clock.date.getFullYear();
            displayMonth = clock.date.getMonth();
        }
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.base

        border.width: 1
        border.color: Theme.surface0

        radius: Theme.radius

        Column {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 16
            }

            spacing: 14

            Row {
                width: parent.width
                height: 28

                Text {
                    width: 36

                    text: "‹"

                    font.family: Theme.shellFont
                    font.pixelSize: 22

                    color: Theme.subtext1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shiftMonth(-1)
                    }
                }

                Text {
                    width: parent.width - 72

                    horizontalAlignment: Text.AlignHCenter

                    text: Qt.formatDate(
                        new Date(
                            root.displayYear,
                            root.displayMonth,
                            1
                        ),
                        "MMMM yyyy"
                    )

                    font.family: Theme.shellFont
                    font.pixelSize: 14
                    font.weight: Font.DemiBold

                    color: Theme.text
                }

                Text {
                    width: 36

                    horizontalAlignment: Text.AlignRight

                    text: "›"

                    font.family: Theme.shellFont
                    font.pixelSize: 22

                    color: Theme.subtext1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shiftMonth(1)
                    }
                }
            }

            Grid {
                width: parent.width

                columns: 7
                columnSpacing: 2
                rowSpacing: 5

                Repeater {
                    model: [
                        "Mon", "Tue", "Wed",
                        "Thu", "Fri", "Sat", "Sun"
                    ]

                    delegate: Text {
                        required property string modelData

                        width: 38
                        height: 22

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        text: modelData

                        font.family: Theme.shellFont
                        font.pixelSize: 10
                        font.weight: Font.DemiBold

                        color: Theme.overlay1
                    }
                }

                Repeater {
                    model: 42

                    delegate: Item {
                        required property int index

                        property int day: root.dayAt(index)

                        width: 38
                        height: 29

                        Rectangle {
                            anchors.centerIn: parent

                            width: 27
                            height: 27

                            radius: 0

                            color: root.isToday(parent.day)
                                ? Theme.accent
                                : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent

                            text: parent.day > 0
                                ? parent.day
                                : ""

                            font.family: Theme.shellFont
                            font.pixelSize: 11
                            font.weight: root.isToday(parent.day)
                                ? Font.DemiBold
                                : Font.Normal

                            color: root.isToday(parent.day)
                                ? Theme.crust
                                : Theme.text
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface0
            }

            Text {
                text: Qt.formatDateTime(
                    clock.date,
                    "dddd, d MMMM yyyy"
                )

                font.family: Theme.shellFont
                font.pixelSize: 12

                color: Theme.subtext0
            }
        }
    }
}
