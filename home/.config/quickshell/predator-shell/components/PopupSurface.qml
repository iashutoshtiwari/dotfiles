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
    scale: 0.985
    transformOrigin: Item.TopRight
    y: -6

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
                    duration: Theme.animationNormal
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
                        duration: Theme.animationExit
                        easing.type: Easing.InCubic
                    }
                }

                ScriptAction { script: root.exitFinished() }
            }
        }
    ]
}
