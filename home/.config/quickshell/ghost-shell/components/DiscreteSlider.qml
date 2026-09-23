import QtQuick

import qs.theme

Item {
    id: root

    property int value: 0
    property int minimum: 0
    property int maximum: 2
    property var stepLabels: []
    property color accentColor: Theme.lavender
    property bool interactive: true

    signal userChanged(int step)
    signal userIncreased()
    signal userDecreased()

    implicitWidth: 260
    implicitHeight: 40

    readonly property int totalSteps: Math.max(1, maximum - minimum)
    readonly property real normalized: Math.max(0, Math.min(1, (value - minimum) / totalSteps))

    Column {
        anchors.fill: parent
        spacing: 4

        // Track and thumb container
        Item {
            id: trackContainer
            width: parent.width
            height: 20

            // Track background
            Rectangle {
                id: trackBg
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 3
                color: Theme.surface1

                // Active fill
                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: parent.width * root.normalized
                    color: root.accentColor

                    Behavior on width {
                        enabled: !sliderMouse.pressed
                        NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                    }
                }

                // Tick marks for discrete steps
                Repeater {
                    model: root.totalSteps + 1

                    delegate: Rectangle {
                        required property int index
                        width: 2
                        height: 7
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.round((trackBg.width - width) * (index / root.totalSteps))
                        color: index <= (root.value - root.minimum) ? root.accentColor : Theme.surface2
                    }
                }
            }

            // Boxy thumb (radius: 0)
            Rectangle {
                id: thumb
                anchors.verticalCenter: trackBg.verticalCenter
                width: 10
                height: 10
                radius: 0
                color: root.accentColor

                x: Math.max(0, Math.min(trackBg.width - width, trackBg.width * root.normalized - width / 2))

                Behavior on x {
                    enabled: !sliderMouse.pressed
                    NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                id: sliderMouse
                anchors.fill: parent
                enabled: root.interactive
                cursorShape: Qt.PointingHandCursor

                function updateStep() {
                    const ratio = Math.max(0, Math.min(1, mouseX / width));
                    const step = root.minimum + Math.round(ratio * root.totalSteps);
                    if (step !== root.value) {
                        root.userChanged(step);
                    }
                }

                onPressed: updateStep()
                onPositionChanged: {
                    if (pressed)
                        updateStep();
                }

                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0)
                        root.userIncreased();
                    else if (wheel.angleDelta.y < 0)
                        root.userDecreased();
                    wheel.accepted = true;
                }
            }
        }

        // Discrete step labels
        Item {
            id: labelsContainer
            width: parent.width
            height: 16

            readonly property int labelCount: root.stepLabels.length > 0
                ? root.stepLabels.length
                : (root.totalSteps + 1)

            Repeater {
                model: labelsContainer.labelCount

                delegate: Item {
                    required property int index
                    readonly property int stepVal: root.minimum + index
                    readonly property string labelText: {
                        if (root.stepLabels.length > index)
                            return root.stepLabels[index];
                        if (root.totalSteps === 2) {
                            if (index === 0) return "Off";
                            if (index === 1) return "Low";
                            return "High";
                        }
                        if (index === 0) return "Off";
                        if (index === root.totalSteps) return "Max";
                        return stepVal.toString();
                    }

                    width: labelTextItem.implicitWidth + 8
                    height: parent.height

                    x: {
                        if (index === 0)
                            return 0;
                        if (index === labelsContainer.labelCount - 1)
                            return parent.width - width;
                        return Math.round((parent.width - width) * (index / (labelsContainer.labelCount - 1)));
                    }

                    Text {
                        id: labelTextItem
                        anchors.centerIn: parent
                        text: parent.labelText
                        font.family: Theme.monoFont
                        font.pixelSize: Theme.fontCaption
                        font.weight: root.value === parent.stepVal ? Font.DemiBold : Font.Normal
                        color: root.value === parent.stepVal ? root.accentColor : Theme.overlay1
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.interactive
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.value !== parent.stepVal) {
                                root.userChanged(parent.stepVal);
                            }
                        }
                    }
                }
            }
        }
    }
}
