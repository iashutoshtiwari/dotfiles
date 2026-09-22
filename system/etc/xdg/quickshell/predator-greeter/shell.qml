import QtQuick
import Quickshell
import Quickshell.Services.Greetd
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property string accountName: "ashutosh"
    readonly property string displayName: "Ashutosh"

    readonly property int stateIdle: 0
    readonly property int stateAuthenticating: 1
    readonly property int stateError: 2
    readonly property int stateStarting: 3

    property int authState: stateIdle
    property string statusMessage: "Ready to sign in"
    property string clockText: ""
    property string dateText: ""
    property var primaryWindow: null

    readonly property bool busy:
        authState === stateAuthenticating || authState === stateStarting

    QtObject {
        id: theme

        readonly property color crust: "#11111b"
        readonly property color mantle: "#181825"
        readonly property color surface0: "#313244"
        readonly property color surface1: "#45475a"
        readonly property color overlay0: "#6c7086"
        readonly property color text: "#cdd6f4"
        readonly property color subtext1: "#bac2de"
        readonly property color subtext0: "#a6adc8"
        readonly property color lavender: "#b4befe"
        readonly property color red: "#f38ba8"
        readonly property color yellow: "#f9e2af"
        readonly property color green: "#a6e3a1"

        readonly property string uiFont: "JetBrainsMono Nerd Font"
        readonly property string iconFont: "JetBrainsMono Nerd Font"

        readonly property int spacingXs: 4
        readonly property int spacingSm: 8
        readonly property int spacingMd: 12
        readonly property int spacingXl: 24

        readonly property int motionFast: 100
        readonly property int motionNormal: 190
        readonly property int motionExit: 100
    }

    function updateClock() {
        const now = new Date();
        clockText = Qt.formatDateTime(now, "HH:mm");
        dateText = Qt.formatDateTime(now, "dddd, d MMMM");
    }

    function setError(message) {
        authState = stateError;
        statusMessage = message;
        errorReset.restart();

        if (primaryWindow) {
            primaryWindow.clearPassword();
            primaryWindow.focusPassword();
        }
    }

    function clearTransientError() {
        if (authState !== stateError)
            return;

        authState = stateIdle;
        statusMessage = "Ready to sign in";
        errorReset.stop();
    }

    function authenticate() {
        if (busy || !primaryWindow)
            return;

        if (!Greetd.available) {
            setError("Authentication service unavailable");
            return;
        }

        if (!primaryWindow.hasPassword()) {
            setError("Enter your password");
            return;
        }

        errorReset.stop();
        authState = stateAuthenticating;
        statusMessage = "Signing in…";
        Greetd.createSession(accountName);
    }

    Component.onCompleted: updateClock()

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.updateClock()
    }

    Timer {
        id: errorReset

        interval: 5000
        onTriggered: root.clearTransientError()
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (error) {
                root.setError("Authentication failed");
                return;
            }

            if (responseRequired && root.primaryWindow) {
                // Keep the password only in the input field until PAM asks for it,
                // then clear the field immediately after handing it to greetd.
                Greetd.respond(root.primaryWindow.takePassword());
            }
        }

        function onAuthFailure(message) {
            // Do not expose raw PAM or greetd implementation details onscreen.
            root.setError("Incorrect password");
        }

        function onReadyToLaunch() {
            root.authState = root.stateStarting;
            root.statusMessage = "Starting session…";

            // greetd expects launch promptly after authentication. UWSM owns the
            // real session, so no decorative delay is inserted here.
            Greetd.launch(["/usr/local/libexec/predator-session"]);
        }

        function onError(error) {
            root.setError("Unable to start the session");
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: greeterWindow

            required property var modelData
            readonly property bool isPrimary: modelData === Quickshell.screens[0]

            function hasPassword() {
                return formLoader.item && formLoader.item.hasPassword();
            }

            function takePassword() {
                return formLoader.item ? formLoader.item.takePassword() : "";
            }

            function clearPassword() {
                if (formLoader.item)
                    formLoader.item.clearPassword();
            }

            function focusPassword() {
                if (formLoader.item)
                    formLoader.item.focusPassword();
            }

            screen: modelData
            focusable: isPrimary
            exclusiveZone: 0
            color: theme.crust

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus:
                isPrimary ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "predator-greeter"

            Component.onCompleted: {
                if (isPrimary)
                    root.primaryWindow = greeterWindow;
            }

            Component.onDestruction: {
                if (root.primaryWindow === greeterWindow)
                    root.primaryWindow = null;
            }

            Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("wallpaper.svg")
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                cache: true
            }

            Rectangle {
                anchors.fill: parent
                color: "#9911111b"
            }

            Loader {
                id: formLoader

                anchors.fill: parent
                active: greeterWindow.isPrimary
                sourceComponent: primaryContent
            }

            Component {
                id: primaryContent

                Item {
                    id: content

                    property bool powerOpen: false
                    property string pendingPowerAction: ""

                    function hasPassword() {
                        return passwordInput.text.length > 0;
                    }

                    function takePassword() {
                        const response = passwordInput.text;
                        passwordInput.clear();
                        return response;
                    }

                    function clearPassword() {
                        passwordInput.clear();
                    }

                    function focusPassword() {
                        Qt.callLater(function() {
                            passwordInput.forceActiveFocus();
                        });
                    }

                    function closePowerMenu() {
                        powerOpen = false;
                        pendingPowerAction = "";
                        focusPassword();
                    }

                    function togglePowerMenu() {
                        if (powerOpen) {
                            closePowerMenu();
                            return;
                        }

                        powerOpen = true;
                        pendingPowerAction = "";
                        Qt.callLater(function() {
                            const firstAction = powerActions.itemAt(0);
                            if (firstAction)
                                firstAction.forceActiveFocus();
                        });
                    }

                    function handlePowerAction(action) {
                        if (action === "Cancel") {
                            closePowerMenu();
                        } else if (pendingPowerAction === action) {
                            const command = action === "Restart" ? "reboot" : "poweroff";
                            Quickshell.execDetached(["systemctl", command]);
                            closePowerMenu();
                        } else {
                            pendingPowerAction = action;
                            Qt.callLater(function() {
                                const confirmation = powerActions.itemAt(0);
                                if (confirmation)
                                    confirmation.forceActiveFocus();
                            });
                        }
                    }

                    anchors.fill: parent
                    opacity: 0
                    transform: Translate { id: entranceOffset; y: 4 }

                    Component.onCompleted: {
                        focusPassword();
                        entrance.start();
                    }

                    ParallelAnimation {
                        id: entrance
                        NumberAnimation {
                            target: content
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: theme.motionNormal
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: entranceOffset
                            property: "y"
                            from: 4
                            to: 0
                            duration: theme.motionNormal
                            easing.type: Easing.OutCubic
                        }
                    }

                    Column {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: Math.max(72, parent.height * 0.12)
                        }
                        spacing: theme.spacingXs

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.clockText
                            color: theme.text
                            font.family: theme.uiFont
                            font.pixelSize: 56
                            font.weight: Font.Medium
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.dateText
                            color: theme.subtext1
                            font.family: theme.uiFont
                            font.pixelSize: 15
                        }
                    }

                    Column {
                        id: loginForm

                        anchors.centerIn: parent
                        width: 360
                        spacing: theme.spacingMd

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.displayName
                            color: theme.text
                            font.family: theme.uiFont
                            font.pixelSize: 22
                            font.weight: Font.DemiBold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Ghost"
                            color: theme.subtext0
                            font.family: theme.uiFont
                            font.pixelSize: 11
                            font.letterSpacing: 0.8
                        }

                        Item {
                            width: 1
                            height: theme.spacingSm
                        }

                        Rectangle {
                            id: passwordFrame

                            width: parent.width
                            height: 48
                            color: theme.mantle
                            border.width: root.authState === root.stateError ? 2 : 1
                            border.color: root.authState === root.stateError
                                ? theme.red
                                : passwordInput.activeFocus
                                    ? theme.lavender
                                    : theme.surface1

                            Behavior on border.color {
                                ColorAnimation { duration: theme.motionFast; easing.type: Easing.OutCubic }
                            }

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: theme.spacingMd
                                    verticalCenter: parent.verticalCenter
                                }
                                visible: passwordInput.text.length === 0
                                text: root.busy ? "" : "Password"
                                color: theme.overlay0
                                font.family: theme.uiFont
                                font.pixelSize: 13
                            }

                            TextInput {
                                id: passwordInput

                                anchors {
                                    fill: parent
                                    leftMargin: theme.spacingMd
                                    rightMargin: submitButton.width + theme.spacingMd
                                }
                                enabled: !root.busy
                                focus: true
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                passwordMaskDelay: 0
                                passwordCharacter: "▪"
                                selectByMouse: false
                                color: enabled ? theme.text : theme.overlay0
                                selectionColor: theme.lavender
                                selectedTextColor: theme.crust
                                font.family: theme.uiFont
                                font.pixelSize: 15
                                font.letterSpacing: 3

                                onTextEdited: root.clearTransientError()

                                Keys.onReturnPressed: root.authenticate()
                                Keys.onEnterPressed: root.authenticate()
                                Keys.onEscapePressed: {
                                    clear();
                                    root.clearTransientError();
                                }
                            }

                            Rectangle {
                                id: submitButton

                                anchors {
                                    top: parent.top
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                width: 52
                                color: root.busy
                                    ? theme.surface1
                                    : submitMouse.pressed
                                        ? theme.subtext1
                                        : submitMouse.containsMouse
                                            ? theme.text
                                            : theme.lavender

                                Behavior on color {
                                    ColorAnimation { duration: theme.motionFast; easing.type: Easing.OutCubic }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.busy ? "···" : "→"
                                    color: root.busy ? theme.overlay0 : theme.crust
                                    font.family: theme.uiFont
                                    font.pixelSize: 20
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: submitMouse

                                    anchors.fill: parent
                                    enabled: !root.busy
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.authenticate()
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: 20

                            Text {
                                anchors.centerIn: parent
                                text: root.statusMessage
                                color: root.authState === root.stateError
                                    ? theme.red
                                    : root.authState === root.stateStarting
                                        ? theme.green
                                        : root.authState === root.stateAuthenticating
                                            ? theme.lavender
                                            : theme.subtext0
                                font.family: theme.uiFont
                                font.pixelSize: 11

                                Behavior on color {
                                    ColorAnimation { duration: theme.motionFast; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }

                    Text {
                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                            margins: theme.spacingXl
                        }
                        text: "GHOST"
                        color: theme.overlay0
                        font.family: theme.iconFont
                        font.pixelSize: 10
                        font.letterSpacing: 1.4
                    }

                    Rectangle {
                        id: powerButton

                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                            margins: theme.spacingXl
                        }
                        width: 40
                        height: 40
                        activeFocusOnTab: true
                        color: powerMouse.containsMouse ? theme.surface0 : theme.mantle
                        border.width: 1
                        border.color: content.powerOpen || activeFocus
                            ? theme.lavender
                            : theme.surface1

                        Keys.onReturnPressed: content.togglePowerMenu()
                        Keys.onEnterPressed: content.togglePowerMenu()
                        Keys.onSpacePressed: content.togglePowerMenu()
                        Keys.onEscapePressed: content.closePowerMenu()

                        Text {
                            anchors.centerIn: parent
                            text: "󰐥"
                            color: content.powerOpen ? theme.lavender : theme.subtext1
                            font.family: theme.iconFont
                            font.pixelSize: 15
                        }

                        MouseArea {
                            id: powerMouse

                            anchors.fill: parent
                            enabled: !root.busy
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: content.togglePowerMenu()
                        }
                    }

                    Rectangle {
                        id: powerMenu

                        anchors {
                            right: powerButton.right
                            bottom: powerButton.top
                            bottomMargin: theme.spacingSm
                        }
                        width: 220
                        height: 112
                        visible: opacity > 0
                        opacity: content.powerOpen ? 1 : 0
                        scale: content.powerOpen ? 1 : 0.99
                        color: theme.mantle
                        border.width: 1
                        border.color: theme.surface1
                        clip: true

                        Behavior on opacity {
                            NumberAnimation {
                                duration: content.powerOpen ? theme.motionFast : theme.motionExit
                                easing.type: content.powerOpen ? Easing.OutCubic : Easing.InCubic
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: content.powerOpen ? theme.motionFast : theme.motionExit
                                easing.type: content.powerOpen ? Easing.OutCubic : Easing.InCubic
                            }
                        }

                        Column {
                            anchors {
                                fill: parent
                                margins: theme.spacingSm
                            }
                            spacing: theme.spacingXs

                            Text {
                                width: parent.width
                                height: 24
                                text: content.pendingPowerAction.length > 0
                                    ? "Confirm " + content.pendingPowerAction.toLowerCase()
                                    : "POWER"
                                color: content.pendingPowerAction.length > 0
                                    ? theme.yellow
                                    : theme.subtext0
                                verticalAlignment: Text.AlignVCenter
                                font.family: theme.uiFont
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                font.letterSpacing: 0.7
                            }

                            Repeater {
                                id: powerActions

                                model: content.pendingPowerAction.length > 0
                                    ? [content.pendingPowerAction, "Cancel"]
                                    : ["Restart", "Shutdown"]

                                Rectangle {
                                    required property string modelData

                                    width: 204
                                    height: 32
                                    activeFocusOnTab: content.powerOpen
                                    color: actionMouse.containsMouse || activeFocus
                                        ? modelData === "Shutdown" || modelData === "Restart"
                                            ? "#33f38ba8"
                                            : theme.surface0
                                        : "transparent"

                                    Keys.onReturnPressed:
                                        content.handlePowerAction(modelData)
                                    Keys.onEnterPressed:
                                        content.handlePowerAction(modelData)
                                    Keys.onSpacePressed:
                                        content.handlePowerAction(modelData)
                                    Keys.onEscapePressed: content.closePowerMenu()

                                    Text {
                                        anchors {
                                            left: parent.left
                                            leftMargin: theme.spacingSm
                                            verticalCenter: parent.verticalCenter
                                        }
                                        text: parent.modelData
                                        color: parent.modelData === "Cancel"
                                            ? theme.subtext1
                                            : content.pendingPowerAction.length > 0
                                                ? theme.red
                                                : theme.text
                                        font.family: theme.uiFont
                                        font.pixelSize: 12
                                    }

                                    MouseArea {
                                        id: actionMouse

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked:
                                            content.handlePowerAction(parent.modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
