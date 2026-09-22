import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

import qs.theme
import qs.services
import qs.components

PopupWindow {
    id: root

    property Item anchorItem
    readonly property var player: MprisService.activePlayer
    readonly property bool hasTrack: player !== null && MprisService.title.length > 0
    readonly property bool progressAvailable: player !== null
        && player.positionSupported && player.lengthSupported && player.length > 0
        && player.length < 86400
    readonly property bool canSeek: player !== null && player.canSeek
    readonly property real progressRatio: progressAvailable
        ? Math.max(0, Math.min(1, player.position / player.length))
        : 0

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.rect.x: 0
    anchor.rect.y: Theme.spacingLg
    anchor.rect.width: anchorItem?.width ?? 1
    anchor.rect.height: anchorItem?.height ?? 1
    anchor.adjustment: PopupAdjustment.Slide

    implicitWidth: Theme.popupWide
    implicitHeight: Math.ceil((!root.hasTrack ? 152
        : 168
            + (root.progressAvailable ? 36 : 0)
            + (MprisService.players.length > 1 ? 40 : 0)) / 4) * 4
    color: "transparent"
    grabFocus: true

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && root.player?.isPlaying && root.progressAvailable
        onTriggered: root.player.positionChanged()
    }

    function formatTime(seconds: real): string {
        if (!Number.isFinite(seconds) || seconds < 0)
            return "--:--";
        const total = Math.floor(seconds);
        return Math.floor(total / 60) + ":" + (total % 60).toString().padStart(2, "0");
    }

    Connections {
        target: root.player
        function onPostTrackChanged(): void { trackChange.restart(); }
    }

    SequentialAnimation {
        id: trackChange
        NumberAnimation { target: trackInfo; property: "opacity"; to: 0.35; duration: Theme.animationExit }
        NumberAnimation { target: trackInfo; property: "opacity"; to: 1; duration: Theme.animationNormal; easing.type: Easing.OutCubic }
    }

    PopupSurface {
        anchors.fill: parent
        presented: root.visible

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.spacingMd

            RowLayout {
                id: trackInfo
                Layout.fillWidth: true
                visible: root.hasTrack
                spacing: Theme.spacingMd

                Rectangle {
                    readonly property bool wideArtwork: artwork.status === Image.Ready
                        && artwork.sourceSize.height > 0
                        && artwork.sourceSize.width / artwork.sourceSize.height >= 1.35

                    Layout.preferredWidth: wideArtwork ? 144 : 88
                    Layout.preferredHeight: wideArtwork ? 81 : 88
                    color: Theme.base
                    clip: true

                    Image {
                        id: artwork
                        anchors.fill: parent
                        source: MprisService.artwork
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !artwork.visible
                        text: "󰝚"
                        font.family: Theme.shellFont
                        font.pixelSize: 28
                        color: Theme.overlay1
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingXs

                    Text {
                        Layout.fillWidth: true
                        text: MprisService.title
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                        font.family: "Inter"
                        font.pixelSize: Theme.textHeading
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }
                    Text {
                        Layout.fillWidth: true
                        text: MprisService.artist || "Unknown artist"
                        elide: Text.ElideRight
                        font.family: "Inter"
                        font.pixelSize: Theme.textBody
                        color: Theme.subtext1
                    }
                    Text {
                        Layout.fillWidth: true
                        text: MprisService.album || MprisService.playerName
                        elide: Text.ElideRight
                        font.family: "Inter"
                        font.pixelSize: Theme.textSmall
                        color: Theme.subtext0
                    }
                }
            }

            EmptyState {
                Layout.alignment: Qt.AlignCenter
                visible: !root.hasTrack
                icon: "󰝛"
                message: "Nothing playing"
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: root.hasTrack && root.progressAvailable
                spacing: Theme.spacingXs

                Rectangle {
                    id: progressTrack
                    Layout.fillWidth: true
                    height: 3
                    color: Theme.surface1

                    Rectangle {
                        width: parent.width * root.progressRatio
                        height: parent.height
                        color: Theme.lavender
                    }

                    Rectangle {
                        width: 8
                        height: 8
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(parent.width - width,
                            parent.width * root.progressRatio - width / 2))
                        color: Theme.lavender
                        visible: root.canSeek
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.topMargin: -8
                        anchors.bottomMargin: -8
                        enabled: root.canSeek
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        function seekToMouse(): void {
                            if (!root.player || !root.canSeek)
                                return;
                            root.player.position = Math.max(0, Math.min(1, mouseX / width)) * root.player.length;
                        }
                        onPressed: seekToMouse()
                        onPositionChanged: if (pressed) seekToMouse()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: root.formatTime(root.player?.position ?? 0); font.family: "Inter"; font.pixelSize: Theme.textSmall; color: Theme.subtext0 }
                    Item { Layout.fillWidth: true }
                    Text { text: root.formatTime(root.player?.length ?? 0); font.family: "Inter"; font.pixelSize: Theme.textSmall; color: Theme.subtext0 }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                visible: root.hasTrack
                spacing: Theme.spacingLg

                IconButton {
                    icon: "󰒮"
                    enabled: root.player?.canGoPrevious ?? false
                    onClicked: MprisService.previous()
                }
                IconButton {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 34
                    icon: MprisService.playing ? "󰏤" : "󰐊"
                    active: true
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: MprisService.toggle()
                }
                IconButton {
                    icon: "󰒭"
                    enabled: root.player?.canGoNext ?? false
                    onClicked: MprisService.next()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.hasTrack && MprisService.players.length > 1
                spacing: Theme.spacingSm
                SectionLabel { text: "Player" }
                Repeater {
                    model: MprisService.players
                    Rectangle {
                        required property var modelData
                        implicitWidth: playerLabel.implicitWidth + Theme.spacingMd
                        implicitHeight: 24
                        color: modelData === root.player ? Theme.surface1 : "transparent"
                        border.width: modelData === root.player ? 1 : 0
                        border.color: Theme.lavender
                        Text {
                            id: playerLabel
                            anchors.centerIn: parent
                            text: parent.modelData.identity
                            font.family: "Inter"
                            font.pixelSize: Theme.textSmall
                            color: parent.modelData === root.player ? Theme.lavender : Theme.subtext0
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MprisService.selectPlayer(parent.modelData)
                        }
                    }
                }
            }

        }
    }
}
