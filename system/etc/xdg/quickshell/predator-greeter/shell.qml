import QtQuick
import Quickshell
import Quickshell.Services.Greetd

ShellRoot {
    id: root

    property string statusMessage: ""
    property string password: ""

    function authenticate() {
        if (password.length === 0)
            return;

        statusMessage = "Authenticating…";
        Greetd.createSession("ashutosh");
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (error) {
                root.statusMessage = message;
                return;
            }

            if (responseRequired)
                Greetd.respond(root.password);
        }

        function onAuthFailure(message) {
            root.statusMessage =
                message && message.length > 0
                    ? message
                    : "Authentication failed";

            root.password = "";
            passwordInput.text = "";
            passwordInput.forceActiveFocus();
        }

        function onReadyToLaunch() {
            root.statusMessage = "Starting Hyprland…";

            Greetd.launch([
    "/usr/local/libexec/predator-session"
]);
        }

        function onError(error) {
            root.statusMessage = error;
        }
    }

    PanelWindow {
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        focusable: true
        exclusiveZone: 0

        color: "#1e1e2e"

        Column {
            anchors.centerIn: parent

            width: 360
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: Qt.formatDateTime(new Date(), "HH:mm")

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 52
                font.weight: Font.Medium

                color: "#cdd6f4"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "ashutosh"

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                font.weight: Font.DemiBold

                color: "#b4befe"
            }

            Rectangle {
                width: parent.width
                height: 44

                color: "#181825"

                border.width: 1
                border.color: passwordInput.activeFocus
                    ? "#b4befe"
                    : "#45475a"

                TextInput {
                    id: passwordInput

                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }

                    focus: true

                    verticalAlignment: TextInput.AlignVCenter

                    echoMode: TextInput.Password

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13

                    color: "#cdd6f4"

                    selectionColor: "#b4befe"
                    selectedTextColor: "#11111b"

                    onTextChanged:
                        root.password = text

                    Keys.onReturnPressed:
                        root.authenticate()
                }
            }

            Rectangle {
                width: parent.width
                height: 38

                color: "#b4befe"

                Text {
                    anchors.centerIn: parent

                    text: "LOGIN"

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold

                    color: "#11111b"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked:
                        root.authenticate()
                }
            }

            Text {
                width: parent.width

                visible: root.statusMessage.length > 0

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap

                text: root.statusMessage

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10

                color: "#a6adc8"
            }
        }
    }
}
