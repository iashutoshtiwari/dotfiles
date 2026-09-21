pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool ready: Pipewire.ready

    readonly property real outputVolume:
        sink?.audio?.volume ?? 0

    readonly property bool outputMuted:
        sink?.audio?.muted ?? false

    readonly property real inputVolume:
        source?.audio?.volume ?? 0

    readonly property bool inputMuted:
        source?.audio?.muted ?? false

    readonly property string outputName:
        sink?.description
        || sink?.nickname
        || sink?.name
        || "No output device"

    readonly property string inputName:
        source?.description
        || source?.nickname
        || source?.name
        || "No input device"

    readonly property var outputDevices:
        Pipewire.nodes.values.filter(node =>
            node.audio !== null
            && !node.isStream
            && node.isSink
        )

    readonly property var inputDevices:
        Pipewire.nodes.values.filter(node =>
            node.audio !== null
            && !node.isStream
            && !node.isSink
        )

    PwObjectTracker {
        objects: [
            root.sink,
            root.source
        ].filter(node => node !== null && node !== undefined)
    }

    function setOutputVolume(value) {
        if (!sink?.audio)
            return;

        sink.audio.volume =
            Math.max(0, Math.min(1, value));
    }

    function setInputVolume(value) {
        if (!source?.audio)
            return;

        source.audio.volume =
            Math.max(0, Math.min(1, value));
    }

    function toggleOutputMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function toggleInputMute() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    function selectOutput(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function selectInput(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }
}
