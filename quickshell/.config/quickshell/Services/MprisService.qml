pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

QtObject {
    readonly property var players: Mpris.players

    readonly property var activePlayer: {
        // Prefer YouTube Music
        for (let i = 0; i < players.values.length; i++) {
            let p = players.values[i]
            if (p.identity.toLowerCase().includes("youtube")) return p
        }
        // Fall back to any playing player
        for (let i = 0; i < players.values.length; i++) {
            let p = players.values[i]
            if (p.playbackStatus === MprisPlaybackStatus.Playing) return p
        }
        // Fall back to first player
        return players.values.length > 0 ? players.values[0] : null
    }

    readonly property string title: activePlayer?.trackTitle ?? ""
    readonly property string artist: activePlayer?.trackArtists?.join(", ") ?? ""
    readonly property string artUrl: activePlayer?.trackArtUrl ?? ""
    readonly property bool playing: activePlayer?.playbackStatus === MprisPlaybackStatus.Playing

    function playPause() { activePlayer?.togglePlaying() }
    function next() { activePlayer?.next() }
    function previous() { activePlayer?.previous() }
}
