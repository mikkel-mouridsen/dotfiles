import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Rectangle {
    id: root

    property var share: null
    property var pluginApi: null
    property var mainInstance: null

    signal mountRequested(string id)
    signal unmountRequested(string id)
    signal openRequested(string mountpoint)
    signal copyPathRequested(string mountpoint)
    signal forgetPasswordRequested(string id)

    readonly property string subtitle: {
        if (!share) return ""
        return "//" + (share.host || "?") + "/" + (share.share || "?")
    }

    color: Color.mSurface
    radius: Style.radiusM
    implicitHeight: cardLayout.implicitHeight + Style.marginM * 2

    ColumnLayout {
        id: cardLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Style.marginM
        }
        spacing: Style.marginS

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIcon {
                icon: "server"
                pointSize: Style.fontSizeL
                color: share?.isMounted ? Color.mPrimary : Color.mOnSurfaceVariant
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.marginXS

                NText {
                    Layout.fillWidth: true
                    text: share?.name || ""
                    pointSize: Style.fontSizeM
                    font.weight: Font.Medium
                    color: Color.mOnSurface
                    elide: Text.ElideRight
                }

                NText {
                    Layout.fillWidth: true
                    text: root.subtitle
                    pointSize: Style.fontSizeXS
                    color: Color.mOnSurfaceVariant
                    elide: Text.ElideRight
                    font.family: "monospace"
                }
            }

            Rectangle {
                visible: share?.isMounted ?? false
                width: statusLabel.implicitWidth + Style.marginS * 2
                height: statusLabel.implicitHeight + 4
                radius: height / 2
                color: Color.mPrimaryContainer

                NText {
                    id: statusLabel
                    anchors.centerIn: parent
                    text: "MOUNTED"
                    pointSize: Style.fontSizeXXS
                    color: Color.mOnPrimaryContainer
                    font.weight: Font.Medium
                }
            }
        }

        // Mountpoint
        NText {
            visible: share?.isMounted ?? false
            Layout.fillWidth: true
            text: share?.mountpoint || ""
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
            elide: Text.ElideMiddle
            font.family: "monospace"
        }

        // Usage bar
        ColumnLayout {
            visible: (share?.isMounted ?? false) && (share?.usedSize ?? "") !== ""
            Layout.fillWidth: true
            spacing: Style.marginXS

            Rectangle {
                Layout.fillWidth: true
                height: Style.marginXS
                radius: height / 2
                color: Color.mOutlineVariant

                Rectangle {
                    width: parent.width * Math.min((share?.usedPercent ?? 0) / 100, 1)
                    height: parent.height
                    radius: parent.radius
                    color: (share?.usedPercent ?? 0) > 90 ? Color.mError
                         : (share?.usedPercent ?? 0) > 75 ? Color.mWarning
                         : Color.mPrimary
                    Behavior on width { NumberAnimation { duration: Style.animationNormal } }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                NText {
                    text: "Used: " + (share?.usedSize ?? "")
                    pointSize: Style.fontSizeXXS
                    color: Color.mOnSurfaceVariant
                }
                Item { Layout.fillWidth: true }
                NText {
                    text: "Free: " + (share?.freeSize ?? "")
                    pointSize: Style.fontSizeXXS
                    color: Color.mOnSurfaceVariant
                }
            }
        }

        // Actions
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginXS

            NButton {
                visible: share?.isMounted ?? false
                Layout.fillWidth: true
                text: "Open"
                icon: "folder-open"
                onClicked: root.openRequested(share.mountpoint)
            }

            NIconButton {
                visible: share?.isMounted ?? false
                icon: "copy"
                tooltipText: "Copy path"
                baseSize: Style.baseWidgetSize * 0.8
                colorBg: Color.mSurfaceVariant
                colorFg: Color.mOnSurfaceVariant
                colorBgHover: Color.mHover
                colorFgHover: Color.mOnHover
                colorBorder: "transparent"
                colorBorderHover: "transparent"
                onClicked: root.copyPathRequested(share.mountpoint)
            }

            NButton {
                visible: !(share?.isMounted ?? false)
                Layout.fillWidth: true
                text: "Mount"
                icon: "plug-connected"
                onClicked: root.mountRequested(share.id)
            }

            NIconButton {
                visible: share?.isMounted ?? false
                icon: "plug-connected-x"
                tooltipText: "Unmount"
                baseSize: Style.baseWidgetSize * 0.8
                colorBg: Color.mSurfaceVariant
                colorFg: Color.mOnSurfaceVariant
                colorBgHover: Color.mError
                colorFgHover: Color.mOnError
                colorBorder: "transparent"
                colorBorderHover: "transparent"
                onClicked: root.unmountRequested(share.id)
            }

            NIconButton {
                icon: "key-off"
                tooltipText: "Forget keyring password"
                baseSize: Style.baseWidgetSize * 0.8
                colorBg: Color.mSurfaceVariant
                colorFg: Color.mOnSurfaceVariant
                colorBgHover: Color.mHover
                colorFgHover: Color.mOnHover
                colorBorder: "transparent"
                colorBorderHover: "transparent"
                onClicked: root.forgetPasswordRequested(share.id)
            }
        }
    }
}
