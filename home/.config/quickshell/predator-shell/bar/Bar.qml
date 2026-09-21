import QtQuick
import Quickshell

import qs.theme
import qs.popups

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: Theme.barMargin
                left: Theme.barMargin
                right: Theme.barMargin
            }

            implicitHeight: Theme.barHeight

            exclusiveZone:
                Theme.barHeight + Theme.barMargin

            color: "transparent"

            Rectangle {
                anchors.fill: parent

                color: Theme.base

                border.width: 1
                border.color: Theme.surface0

                radius: Theme.radius

                Workspaces {
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                }

                MediaWidget {
                    anchors.centerIn: parent
                }

                Row {
    anchors {
        right: parent.right
        rightMargin: 10
        verticalCenter: parent.verticalCenter
    }

    spacing: 4

	NetworkButton {
        id: networkButton

        onClicked:
            networkPopup.visible = !networkPopup.visible
    }
	BluetoothButton {
    id: bluetoothButton

    onClicked:
        bluetoothPopup.visible = !bluetoothPopup.visible
}

    DisplayButton {
        id: displayButton

        onClicked:
            displayPopup.visible = !displayPopup.visible
    }

    AudioButton {
        id: audioButton

        onClicked:
            audioPopup.visible = !audioPopup.visible
    }
	
    BatteryButton {
    id: batteryButton

    onClicked:
        powerPopup.visible = !powerPopup.visible
    }

    ClockButton {
        id: clockButton

        onClicked:
            clockPopup.visible = !clockPopup.visible
    }
}
            }
NetworkPopup {
    id: networkPopup
    anchorItem: networkButton
}
BluetoothPopup {
    id: bluetoothPopup
    anchorItem: bluetoothButton
}
DisplayPopup {
    id: displayPopup
    anchorItem: displayButton
}
AudioPopup {
    id: audioPopup
    anchorItem: audioButton
}
PowerPopup {
    id: powerPopup
    anchorItem: batteryButton
}

            ClockPopup {
                id: clockPopup
                anchorItem: clockButton
            }
        }
    }
}
