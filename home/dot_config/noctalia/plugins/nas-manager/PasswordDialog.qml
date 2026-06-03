import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Rectangle {
    id: root

    property var pluginApi: null
    property var mainInstance: null

    readonly property string shareId: mainInstance?.pendingShareId || ""
    readonly property string shareName: mainInstance?.pendingShareName || ""
    readonly property string username: mainInstance?.pendingShareUsername || ""

    visible: shareId !== ""
    color: Qt.rgba(0, 0, 0, 0.55)
    radius: Style.radiusL
    z: 100

    onShareIdChanged: {
        if (shareId !== "") {
            passwordInput.text = ""
            passwordInput.inputItem.forceActiveFocus()
        }
    }

    // Click outside the card → cancel
    MouseArea {
        anchors.fill: parent
        onClicked: mainInstance?.cancelPasswordPrompt()
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - Style.marginL * 2, 320 * Style.uiScaleRatio)
        height: cardCol.implicitHeight + Style.marginL * 2
        color: Color.mSurface
        radius: Style.radiusL
        border.color: Color.mOutlineVariant
        border.width: 1

        // Don't propagate clicks through the card to the dim layer
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: cardCol
            anchors {
                left: parent.left; right: parent.right; top: parent.top
                margins: Style.marginL
            }
            spacing: Style.marginM

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS
                NIcon {
                    icon: "lock"
                    pointSize: Style.fontSizeL
                    color: Color.mPrimary
                }
                NText {
                    text: "Password for " + (root.shareName || "share")
                    pointSize: Style.fontSizeM
                    font.weight: Font.Medium
                    color: Color.mOnSurface
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            NText {
                text: "Stored in your keyring (gnome-keyring). It will be reused for future mounts."
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            NText {
                visible: root.username !== ""
                text: "Username: " + root.username
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                font.family: "monospace"
                Layout.fillWidth: true
            }

            NTextInput {
                id: passwordInput
                Layout.fillWidth: true
                placeholderText: "Password"
                inputItem.echoMode: TextInput.Password
                onAccepted: submitButton.clicked()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

                NButton {
                    Layout.fillWidth: true
                    text: "Cancel"
                    onClicked: mainInstance?.cancelPasswordPrompt()
                }

                NButton {
                    id: submitButton
                    Layout.fillWidth: true
                    text: "Save & mount"
                    icon: "key"
                    enabled: passwordInput.text.length > 0
                    onClicked: {
                        const pw = passwordInput.text
                        const id = root.shareId
                        passwordInput.text = ""
                        mainInstance?.savePasswordAndMount(id, pw)
                    }
                }
            }
        }
    }
}
