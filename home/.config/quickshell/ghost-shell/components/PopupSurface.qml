import QtQuick

import qs.theme

Rectangle {
    id: root

    property bool presented: false

    signal exitFinished()

    color: Theme.mantle
    border.width: Theme.borderWidth
    border.color: Theme.surface1
    radius: Theme.radius

    opacity: 0
    scale: Theme.reducedMotion ? 1 : 0.99
    transformOrigin: Item.TopRight
    y: Theme.reducedMotion ? 0 : -4

    states: State {
        name: "presented"
        when: root.presented

        PropertyChanges {
            target: root
            opacity: 1
            scale: 1
            y: 0
        }
    }

    transitions: [
        Transition {
            to: "presented"

            ParallelAnimation {
                NumberAnimation {
                    properties: "opacity,scale,y"
                    duration: Theme.motionNormal
                    easing.type: Easing.OutCubic
                }
            }
        },
        Transition {
            from: "presented"

            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        properties: "opacity,scale,y"
                        duration: Theme.motionExit
                        easing.type: Easing.InCubic
                    }
                }

                ScriptAction { script: root.exitFinished() }
            }
        }
    ]
}
