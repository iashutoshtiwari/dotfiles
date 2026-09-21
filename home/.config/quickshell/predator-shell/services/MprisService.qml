pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var selectedPlayer: null

    readonly property var activePlayer: {
        if (selectedPlayer && players.includes(selectedPlayer))
            return selectedPlayer;

        for (let player of players) {
            if (player.isPlaying)
                return player;
        }

        return players.length > 0 ? players[0] : null;
    }

    readonly property bool available: activePlayer !== null

    readonly property string title:
        activePlayer?.trackTitle ?? ""

    readonly property string artist:
        activePlayer?.trackArtist ?? ""

    readonly property string album:
        activePlayer?.trackAlbum ?? ""

    readonly property string playerName:
        activePlayer?.identity ?? ""

    readonly property string artwork:
        activePlayer?.trackArtUrl ?? ""

    readonly property bool playing:
        activePlayer?.isPlaying ?? false

    function selectPlayer(player): void {
        if (player && players.includes(player))
            selectedPlayer = player;
    }

    function toggle(): void {
        if (activePlayer?.canTogglePlaying)
            activePlayer.togglePlaying();
    }

    function next(): void {
        if (activePlayer?.canGoNext)
            activePlayer.next();
    }

    function previous(): void {
        if (activePlayer?.canGoPrevious)
            activePlayer.previous();
    }
}
