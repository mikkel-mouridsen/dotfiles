import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    readonly property var geometryPlaceholder: panelContainer
    property real contentPreferredWidth: 360 * Style.uiScaleRatio
    property real contentPreferredHeight: 500 * Style.uiScaleRatio
    readonly property bool allowAttach: true
    anchors.fill: parent

    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property var shares: mainInstance?.shares ?? []
    readonly property int mountedCount: mainInstance?.mountedCount ?? 0

    Component.onCompleted: mainInstance?.refresh()

    function copyToClipboard(text) {
        Quickshell.execDetached(["sh", "-c", "echo -n " + JSON.stringify(text) + " | wl-copy"])
        ToastService.showNotice("Path copied", text)
    }

    // Password prompt overlay (fills the panel when a mount needs auth)
    PasswordDialog {
        anchors.fill: parent
        pluginApi: root.pluginApi
        mainInstance: root.mainInstance
        z: 10
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
            spacing: Style.marginL

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Color.mSurfaceVariant
                radius: Style.radiusL

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    RowLayout {
                        spacing: Style.marginM

                        NIcon { icon: "server"; pointSize: Style.fontSizeXL }

                        NText {
                            text: "NAS Manager"
                            font.pointSize: Style.fontSizeL
                            font.weight: Font.Medium
                            color: Color.mOnSurface
                            Layout.fillWidth: true
                        }

                        Item { Layout.fillWidth: true }

                        NIconButton {
                            icon: "refresh"
                            baseSize: Style.baseWidgetSize * 0.8
                            tooltipText: "Refresh"
                            onClicked: mainInstance?.refresh()

                            RotationAnimation on rotation {
                                running: mainInstance?.loading ?? false
                                from: 0; to: 360
                                duration: 1000
                                loops: Animation.Infinite
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Style.marginS

                        // Empty state
                        Item {
                            visible: shares.length === 0
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: Style.marginS

                                NIcon {
                                    Layout.alignment: Qt.AlignHCenter
                                    icon: "server-off"
                                    pointSize: Style.fontSizeXXL
                                    color: Color.mOnSurfaceVariant
                                    opacity: 0.4
                                }

                                NText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "No shares configured"
                                    pointSize: Style.fontSizeM
                                    color: Color.mOnSurfaceVariant
                                }

                                NText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Add one in plugin settings"
                                    pointSize: Style.fontSizeS
                                    color: Color.mOnSurfaceVariant
                                    opacity: 0.7
                                }
                            }
                        }

                        ListView {
                            visible: shares.length > 0
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: shares
                            spacing: Style.marginS
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: ShareCard {
                                width: ListView.view.width
                                share: modelData
                                pluginApi: root.pluginApi
                                mainInstance: root.mainInstance

                                onMountRequested: id => mainInstance?.mountShare(id)
                                onUnmountRequested: id => mainInstance?.unmountShare(id)
                                onOpenRequested: mp => mainInstance?.openInFileBrowser(mp)
                                onCopyPathRequested: mp => root.copyToClipboard(mp)
                                onForgetPasswordRequested: id => mainInstance?.forgetPassword(id)
                            }
                        }
                    }

                    ColumnLayout {
                        visible: shares.length > 0
                        Layout.fillWidth: true
                        spacing: Style.marginXS

                        Rectangle {
                            height: Math.max(1, Style.marginXXS)
                            color: Color.mOutline
                            opacity: 0.3
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.marginS

                            NButton {
                                Layout.fillWidth: true
                                text: "Mount all"
                                icon: "plug-connected"
                                enabled: mountedCount < shares.length
                                onClicked: mainInstance?.mountAll()
                            }

                            NButton {
                                Layout.fillWidth: true
                                text: "Unmount all"
                                icon: "plug-connected-x"
                                enabled: mountedCount > 0
                                onClicked: mainInstance?.unmountAll()
                            }
                        }
                    }
                }
            }
        }
    }
}
