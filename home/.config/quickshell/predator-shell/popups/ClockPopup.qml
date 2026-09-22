import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.theme
import qs.components

PopupWindow {
    id: root
    property Item anchorItem
    property int displayYear: clock.date.getFullYear()
    property int displayMonth: clock.date.getMonth()
    property int pendingMonthOffset: 0

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
    implicitHeight: 392
    color: "transparent"
    grabFocus: true

    SystemClock { id: clock; precision: SystemClock.Seconds }

    function daysInMonth(year: int, month: int): int { return new Date(year, month + 1, 0).getDate(); }
    function firstDayOffset(): int { return (new Date(displayYear, displayMonth, 1).getDay() + 6) % 7; }
    function dayAt(index: int): int {
        const day = index - firstDayOffset() + 1;
        return day < 1 || day > daysInMonth(displayYear, displayMonth) ? 0 : day;
    }
    function isToday(day: int): bool {
        return day > 0 && day === clock.date.getDate()
            && displayMonth === clock.date.getMonth()
            && displayYear === clock.date.getFullYear();
    }
    function shiftMonth(offset: int): void {
        pendingMonthOffset = offset;
        monthTransition.restart();
    }
    function applyMonthShift(): void {
        const next = new Date(displayYear, displayMonth + pendingMonthOffset, 1);
        displayYear = next.getFullYear();
        displayMonth = next.getMonth();
    }
    function returnToToday(): void {
        displayYear = clock.date.getFullYear();
        displayMonth = clock.date.getMonth();
    }

    onVisibleChanged: if (visible) returnToToday()

    SequentialAnimation {
        id: monthTransition
        ParallelAnimation {
            NumberAnimation { target: calendarGrid; property: "opacity"; to: 0; duration: Theme.motionExitFast; easing.type: Easing.InCubic }
            NumberAnimation { target: calendarGrid; property: "x"; to: (Theme.reducedMotion ? 0 : -10) * root.pendingMonthOffset; duration: Theme.motionExitFast; easing.type: Easing.InCubic }
        }
        ScriptAction { script: root.applyMonthShift() }
        PropertyAction { target: calendarGrid; property: "x"; value: (Theme.reducedMotion ? 0 : 10) * root.pendingMonthOffset }
        ParallelAnimation {
            NumberAnimation { target: calendarGrid; property: "opacity"; to: 1; duration: Theme.motionFast; easing.type: Easing.OutCubic }
            NumberAnimation { target: calendarGrid; property: "x"; to: 0; duration: Theme.motionFast; easing.type: Easing.OutCubic }
        }
    }

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.spacingMd

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingMd

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        font.family: Theme.appFont
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }
                    Text {
                        text: Qt.formatDate(clock.date, "dddd, d MMMM")
                        font.family: Theme.appFont
                        font.pixelSize: Theme.textBody
                        color: Theme.subtext0
                    }
                }

            }

            Divider { Layout.fillWidth: true }

            RowLayout {
                Layout.fillWidth: true
                IconButton { icon: "󰅁"; onClicked: root.shiftMonth(-1) }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(new Date(root.displayYear, root.displayMonth, 1), "MMMM yyyy")
                    font.family: Theme.appFont
                    font.pixelSize: Theme.textBodyStrong
                    font.weight: Font.DemiBold
                    color: Theme.text
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.returnToToday()
                    }
                }
                IconButton { icon: "󰅂"; onClicked: root.shiftMonth(1) }
            }

            GridLayout {
                id: calendarGrid
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 0
                rowSpacing: 3

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    Text {
                        required property string modelData
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        font.family: Theme.appFont
                        font.pixelSize: Theme.textSmall
                        font.weight: Font.Medium
                        color: Theme.overlay1
                    }
                }

                Repeater {
                    model: 42
                    Item {
                        required property int index
                        property int day: root.dayAt(index)
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 30

                        Rectangle {
                            anchors.centerIn: parent
                            width: 28
                            height: 28
                            radius: Theme.radius
                            color: root.isToday(parent.day) ? Theme.lavender : "transparent"
                            border.width: parent.day > 0 && !root.isToday(parent.day) && dayMouse.containsMouse ? 1 : 0
                            border.color: Theme.surface2
                        }
                        Text {
                            anchors.centerIn: parent
                            text: parent.day > 0 ? parent.day : ""
                            font.family: Theme.appFont
                            font.pixelSize: Theme.textBody
                            font.weight: root.isToday(parent.day) ? Font.DemiBold : Font.Normal
                            color: root.isToday(parent.day) ? Theme.crust : Theme.subtext1
                        }
                        MouseArea { id: dayMouse; anchors.fill: parent; hoverEnabled: true }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
