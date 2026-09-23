import QtQuick

import qs.theme

Item {
    id: root

    property real value: 0
    property color accentColor: Theme.accent
    property color trackColor: Theme.surface1

    signal userChanged(real value)

    implicitWidth: 260
    implicitHeight: 22
    opacity: enabled ? 1 : Theme.disabledOpacity

    function clamp(value) {
        return Math.max(0, Math.min(1, value));
    }

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter

        width: parent.width
        height: 3

        color: root.trackColor
    }

    Rectangle {
        id: fill
        anchors {
            left: track.left
            verticalCenter: track.verticalCenter
        }

        width: track.width * root.clamp(root.value)
        height: track.height

        color: root.accentColor

        Behavior on width {
            enabled: !mouseArea.pressed
            NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        anchors.verticalCenter: track.verticalCenter

        x: Math.max(
            0,
            Math.min(
                track.width - width,
                track.width * root.clamp(root.value)
                    - width / 2
            )
        )

        width: 10
        height: 10

        radius: 0

        color: root.accentColor

        Behavior on x {
            enabled: !mouseArea.pressed
            NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        function updateValue() {
            root.userChanged(
                root.clamp(mouseX / width)
            );
        }

        onPressed: updateValue()

        onPositionChanged: {
            if (pressed)
                updateValue();
        }

        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 0.04 : -0.04;
            root.userChanged(root.clamp(root.value + delta));
            wheel.accepted = true;
        }
    }
}
