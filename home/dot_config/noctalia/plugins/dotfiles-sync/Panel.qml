import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    readonly property var geometryPlaceholder: panelContainer
    property real contentPreferredWidth: 380 * Style.uiScaleRatio
    property real contentPreferredHeight: 520 * Style.uiScaleRatio
    readonly property bool allowAttach: true
    anchors.fill: parent

    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property string syncState: mainInstance?.syncState ?? "clean"
    readonly property var changedFiles: mainInstance?.changedFiles ?? []
    property bool showDiff: false

    Component.onCompleted: {
        mainInstance?.refreshStatus()
        mainInstance?.fetch()
    }

    function stateColor() {
        switch (syncState) {
        case "error": return Color.mError
        case "clean": return Color.mPrimary
        case "syncing": return Color.mOnSurfaceVariant
        default: return Color.mPrimary
        }
    }

    function stateIcon() {
        switch (syncState) {
        case "syncing": return "refresh"
        case "error": return "alert-triangle"
        case "behind": return "cloud-download"
        case "ahead": return "cloud-upload"
        case "diverged": return "arrows-exchange"
        default: return "cloud-check"
        }
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors {
                fill: parent
                margins: Style.marginM
            }
            spacing: Style.marginM

            // ───────── Header ─────────
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                NIcon { icon: "git-fork"; pointSize: Style.fontSizeXL }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    NText {
                        text: "Dotfiles"
                        font.pointSize: Style.fontSizeL
                        font.weight: Font.Medium
                        color: Color.mOnSurface
                    }
                    NText {
                        text: "last sync " + (mainInstance?.lastSyncText() ?? "never")
                        pointSize: Style.fontSizeXS
                        color: Color.mOnSurfaceVariant
                    }
                }

                NIconButton {
                    icon: "refresh"
                    baseSize: Style.baseWidgetSize * 0.8
                    tooltipText: "Refresh"
                    onClicked: { mainInstance?.refreshStatus(); mainInstance?.fetch() }
                    RotationAnimation on rotation {
                        running: root.syncState === "syncing"
                        from: 0; to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        onRunningChanged: if (!running) parent.rotation = 0
                    }
                }
            }

            // ───────── Status card ─────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: statusRow.implicitHeight + Style.marginM * 2
                color: Color.mSurfaceVariant
                radius: Style.radiusM

                RowLayout {
                    id: statusRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    NIcon {
                        icon: root.stateIcon()
                        pointSize: Style.fontSizeXL
                        color: root.stateColor()
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        NText {
                            text: mainInstance?.stateLabel() ?? ""
                            pointSize: Style.fontSizeM
                            font.weight: Font.Bold
                            color: Color.mOnSurface
                        }
                        NText {
                            visible: (mainInstance?.lastError ?? "") !== ""
                            text: mainInstance?.lastError ?? ""
                            pointSize: Style.fontSizeXS
                            color: Color.mError
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        NText {
                            visible: (mainInstance?.lastError ?? "") === ""
                            text: (mainInstance?.localChanges ?? 0) + " local change"
                                  + ((mainInstance?.localChanges ?? 0) === 1 ? "" : "s")
                            pointSize: Style.fontSizeXS
                            color: Color.mOnSurfaceVariant
                        }
                    }
                }
            }

            // ───────── Changed files / diff ─────────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Color.mSurfaceVariant
                radius: Style.radiusM

                // Empty (clean) state
                ColumnLayout {
                    visible: changedFiles.length === 0 && !root.showDiff
                    anchors.centerIn: parent
                    spacing: Style.marginS
                    NIcon {
                        Layout.alignment: Qt.AlignHCenter
                        icon: "check"
                        pointSize: Style.fontSizeXXL
                        color: Color.mOnSurfaceVariant
                        opacity: 0.4
                    }
                    NText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No local changes"
                        pointSize: Style.fontSizeM
                        color: Color.mOnSurfaceVariant
                    }
                }

                // Changed-files list
                NScrollView {
                    visible: changedFiles.length > 0 && !root.showDiff
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    showScrollbarWhenScrollable: true
                    gradientColor: "transparent"

                    ColumnLayout {
                        width: parent.width
                        spacing: Style.marginXXS
                        Repeater {
                            model: root.changedFiles
                            delegate: RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                spacing: Style.marginS
                                NText {
                                    text: modelData.code || "M"
                                    pointSize: Style.fontSizeXS
                                    font.family: "monospace"
                                    color: Color.mPrimary
                                    Layout.preferredWidth: 24
                                }
                                NText {
                                    text: modelData.path
                                    pointSize: Style.fontSizeXS
                                    color: Color.mOnSurface
                                    Layout.fillWidth: true
                                    elide: Text.ElideMiddle
                                }
                            }
                        }
                    }
                }

                // Inline diff view
                NScrollView {
                    visible: root.showDiff
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    showScrollbarWhenScrollable: true
                    gradientColor: "transparent"
                    NText {
                        width: parent.width
                        text: (mainInstance?.lastDiff ?? "").length > 0
                              ? mainInstance.lastDiff
                              : "No differences."
                        pointSize: Style.fontSizeXS
                        font.family: "monospace"
                        color: Color.mOnSurface
                        wrapMode: Text.NoWrap
                        textFormat: Text.PlainText
                    }
                }
            }

            // ───────── Actions ─────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    NButton {
                        Layout.fillWidth: true
                        text: "Pull"
                        icon: "cloud-download"
                        enabled: root.syncState !== "syncing"
                        onClicked: mainInstance?.pull()
                    }
                    NButton {
                        Layout.fillWidth: true
                        text: "Push"
                        icon: "cloud-upload"
                        enabled: root.syncState !== "syncing"
                                 && ((mainInstance?.localChanges ?? 0) > 0 || (mainInstance?.ahead ?? 0) > 0)
                        onClicked: mainInstance?.push()
                    }
                }

                NButton {
                    Layout.fillWidth: true
                    text: root.showDiff ? "Hide diff" : "View diff"
                    icon: root.showDiff ? "eye-off" : "eye"
                    onClicked: {
                        root.showDiff = !root.showDiff
                        if (root.showDiff) mainInstance?.loadDiff()
                    }
                }
            }
        }
    }
}
