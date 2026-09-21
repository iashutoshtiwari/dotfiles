pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string wallpapersDir: "/home/ashutosh/Pictures/Wallpapers"
    readonly property string setWallpaperBin: "/home/ashutosh/.local/bin/set-wallpaper"

    readonly property bool ready: readyVal
    readonly property string currentWallpaperPath: currentPathVal
    readonly property string currentWallpaperName: currentNameVal
    readonly property var wallpapers: wallpapersVal
    readonly property int wallpaperCount: wallpapersVal.length

    property bool readyVal: false
    property string currentPathVal: ""
    property string currentNameVal: ""
    property var wallpapersVal: []

    signal wallpaperChanged(string path)

    function refresh(): void {
        if (!readCurrent.running)
            readCurrent.exec([setWallpaperBin, "--current"]);
    }

    function selectWallpaper(path: string): void {
        if (!path || applyProcess.running)
            return;

        currentPathVal = path;
        currentNameVal = path.split("/").pop() || path;
        updateListCurrent();

        applyProcess.exec([setWallpaperBin, path]);
    }

    function openFolder(): void {
        openFolderProcess.exec(["xdg-open", wallpapersDir]);
    }

    function updateListCurrent(): void {
        const list = [];
        for (let i = 0; i < wallpapersVal.length; i++) {
            const item = wallpapersVal[i];
            list.push({
                name: item.name,
                path: item.path,
                isCurrent: item.path === currentPathVal
            });
        }
        wallpapersVal = list;
    }

    Process {
        id: readCurrent

        stdout: StdioCollector {
            id: currentOut
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                const path = currentOut.text.trim();
                if (path) {
                    root.currentPathVal = path;
                    root.currentNameVal = path.split("/").pop() || path;
                }
            }

            if (!scanDir.running) {
                scanDir.exec([
                    "find",
                    root.wallpapersDir,
                    "-maxdepth", "1",
                    "-type", "f",
                    "(",
                    "-iname", "*.jpg",
                    "-o", "-iname", "*.jpeg",
                    "-o", "-iname", "*.png",
                    "-o", "-iname", "*.webp",
                    "-o", "-iname", "*.jxl",
                    ")",
                    "-printf", "%f\t%p\n"
                ]);
            }
        }
    }

    Process {
        id: scanDir

        stdout: StdioCollector {
            id: scanOut
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                const lines = scanOut.text.trim().split("\n");
                const list = [];
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim();
                    if (!line)
                        continue;
                    const parts = line.split("\t");
                    if (parts.length >= 2) {
                        const name = parts[0];
                        const path = parts[1];
                        list.push({
                            name: name,
                            path: path,
                            isCurrent: path === root.currentPathVal
                        });
                    }
                }
                // Sort alphabetically by name
                list.sort((a, b) => a.name.localeCompare(b.name));
                root.wallpapersVal = list;
                root.readyVal = true;
            }
        }
    }

    Process {
        id: applyProcess

        onExited: exitCode => {
            root.wallpaperChanged(root.currentPathVal);
            root.refresh();
        }
    }

    Process {
        id: openFolderProcess
    }

    Component.onCompleted: {
        root.refresh();
    }
}
