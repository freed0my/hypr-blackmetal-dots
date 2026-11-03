// Blackmetal — SDDM styled after the Hyprland rice (waybar islands + rofi window)
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080

    // ── palette (theme.conf, with fallbacks) ──────────────────
    readonly property color cBg:        config.bg        || "#080708"
    readonly property color cSurface:   config.surface   || "#211D21"
    readonly property color cFrame:     config.frame     || "#2D2D2D"
    readonly property color cText:      config.text      || "#C4C0C4"
    readonly property color cTextSec:   config.textSec   || "#8C858C"
    readonly property color cTextDim:   config.textDim   || "#3A353A"
    readonly property color cAccent:    config.accent    || "#E0DCE0"
    readonly property color cHighlight: config.highlight || "#F6F7EB"
    readonly property color cCrit:      config.crit      || "#A8324D"
    readonly property string fontFamily: config.font || "JetBrainsMono Nerd Font"

    readonly property int radius: 4
    readonly property int border: 2
    readonly property int gap: 10          // gaps_out Hyprland

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool failed: false

    color: "black"
    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.failed = true
            password.text = ""
            password.forceActiveFocus()
            shake.restart()
        }
        function onLoginSucceeded() { root.failed = false }
    }

    function doLogin() {
        root.failed = false
        sddm.login(username.text, password.text, root.sessionIndex)
    }

    Image {
        anchors.fill: parent
        source: config.background || ""
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
        asynchronous: false
    }

    // ── components ──────────────────────────────────────────
    // "island" like in waybar
    component Island: Rectangle {
        default property alias content: row.data
        property bool hoverable: false
        property alias hovered: ma.containsMouse
        signal clicked()
        height: 34
        width: row.implicitWidth + 28
        radius: root.radius
        color: hoverable && ma.containsMouse ? root.cSurface : "transparent"
        border.color: root.cFrame
        border.width: root.border
        Behavior on color { ColorAnimation { duration: 200 } }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 12
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            enabled: parent.hoverable
            cursorShape: parent.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: parent.clicked()
        }
    }

    component Label: Text {
        color: root.cText
        font.family: root.fontFamily
        font.pixelSize: 14
        font.weight: Font.Medium
        verticalAlignment: Text.AlignVCenter
    }

    component IconButton: Label {
        id: ib
        signal clicked()
        property color hoverColor: root.cAccent
        color: ibMa.containsMouse ? hoverColor : root.cTextSec
        font.pixelSize: 16
        Behavior on color { ColorAnimation { duration: 200 } }
        MouseArea {
            id: ibMa
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ib.clicked()
        }
    }

    // ── top bar (like waybar) ─────────────────────────────
    Item {
        id: bar
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: root.gap }
        height: 34

        Row {
            anchors.left: parent.left
            spacing: 6
            Island {
                Label { text: ""; color: root.cAccent; font.pixelSize: 17 }
            }
            Island {
                visible: sddm.hostName !== ""
                Label { text: sddm.hostName; color: root.cTextSec }
            }
        }

        Island {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                id: clock
                color: root.cAccent
                font.pixelSize: 15
                font.weight: Font.Bold
                function update() { text = Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm") }
                Component.onCompleted: update()
            }
            Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.update() }
        }

        Row {
            anchors.right: parent.right
            spacing: 6

            Island {
                visible: keyboard.layouts.length > 1
                hoverable: true
                onClicked: keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
                Label {
                    color: root.cTextSec
                    text: keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout].shortName : ""
                }
            }

            Island {
                id: sessionIsland
                hoverable: true
                onClicked: sessionPopup.visible = !sessionPopup.visible
                Label { text: ""; color: root.cTextSec }
                Label { id: sessionName; text: "" }
            }

            Island {
                visible: sddm.canSuspend || sddm.canReboot || sddm.canPowerOff
                IconButton { text: "󰤄"; visible: sddm.canSuspend;  onClicked: sddm.suspend() }   // 󰤄
                IconButton { text: "󰜉"; visible: sddm.canReboot;   onClicked: sddm.reboot() }    // 󰜉
                IconButton { text: "";       visible: sddm.canPowerOff; onClicked: sddm.powerOff(); hoverColor: root.cCrit }
            }
        }
    }

    // hidden ListView just to get the session name by index
    Repeater {
        id: sessionNames
        model: sessionModel
        delegate: Item { property string sname: model.name }
    }
    function updateSessionName() {
        var it = sessionNames.itemAt(root.sessionIndex)
        sessionName.text = it ? it.sname : "session"
    }
    onSessionIndexChanged: updateSessionName()
    Component.onCompleted: {
        updateSessionName()
        if (username.text === "") username.forceActiveFocus()
        else password.forceActiveFocus()
    }

    // session dropdown (rofi style)
    Rectangle {
        id: sessionPopup
        visible: false
        z: 10
        anchors.top: bar.bottom
        anchors.topMargin: 6
        x: bar.x + bar.width - width - 0
        width: 260
        height: sessionList.contentHeight + 16
        color: root.cBg
        radius: root.radius
        border.color: root.cFrame
        border.width: root.border

        ListView {
            id: sessionList
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2
            interactive: false
            model: sessionModel
            delegate: Rectangle {
                width: sessionList.width
                height: 30
                radius: 2
                color: (index === root.sessionIndex || dMa.containsMouse) ? root.cSurface : "transparent"
                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    text: model.name
                    color: index === root.sessionIndex ? root.cAccent : root.cTextSec
                    elide: Text.ElideRight
                }
                MouseArea {
                    id: dMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.sessionIndex = index; sessionPopup.visible = false; password.forceActiveFocus() }
                }
            }
        }
    }

    // ── login window (like rofi menu) ─────────────────────────
    Rectangle {
        id: loginBox
        width: 416                         // 26em
        height: col.implicitHeight + 28
        anchors.centerIn: parent
        color: root.cBg
        radius: root.radius
        border.width: root.border
        // active "window" — light border, like col.active_border
        border.color: root.failed ? root.cCrit
                     : (username.activeFocus || password.activeFocus) ? root.cHighlight
                     : root.cFrame
        Behavior on border.color { ColorAnimation { duration: 200 } }

        SequentialAnimation {
            id: shake
            property real base: 0
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50 }
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: 10;  duration: 70 }
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: -6;  duration: 70 }
            NumberAnimation { target: loginBox; property: "anchors.horizontalCenterOffset"; to: 0;   duration: 50 }
        }

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
            spacing: 6

            // user row
            Rectangle {
                width: parent.width
                height: 36
                radius: 2
                color: username.activeFocus ? root.cSurface : "transparent"
                Label {
                    id: userIcon
                    anchors.left: parent.left; anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    color: username.activeFocus ? root.cAccent : root.cTextDim
                }
                TextInput {
                    id: username
                    anchors { left: userIcon.right; leftMargin: 12; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    text: userModel.lastUser
                    color: root.cAccent
                    selectionColor: root.cSurface
                    font.family: root.fontFamily
                    font.pixelSize: 15
                    clip: true
                    KeyNavigation.tab: password
                    KeyNavigation.down: password
                    Keys.onReturnPressed: password.forceActiveFocus()
                    Keys.onEnterPressed: password.forceActiveFocus()
                    Label {
                        visible: !parent.text
                        text: "user"
                        color: root.cTextDim
                        font.pixelSize: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // password row
            Rectangle {
                width: parent.width
                height: 36
                radius: 2
                color: password.activeFocus ? root.cSurface : "transparent"
                Label {
                    id: lockIcon
                    anchors.left: parent.left; anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    color: root.failed ? root.cCrit : password.activeFocus ? root.cAccent : root.cTextDim
                }
                TextInput {
                    id: password
                    anchors { left: lockIcon.right; leftMargin: 12; right: arrow.left; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    color: root.cAccent
                    selectionColor: root.cSurface
                    font.family: root.fontFamily
                    font.pixelSize: 15
                    font.letterSpacing: 2
                    clip: true
                    KeyNavigation.backtab: username
                    KeyNavigation.up: username
                    Keys.onReturnPressed: root.doLogin()
                    Keys.onEnterPressed: root.doLogin()
                    onTextChanged: if (text.length) root.failed = false
                    Label {
                        visible: !parent.text
                        text: root.failed ? "wrong password" : "password"
                        color: root.failed ? root.cCrit : root.cTextDim
                        font.pixelSize: 15
                        font.letterSpacing: 0
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                IconButton {
                    id: arrow
                    anchors.right: parent.right; anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    onClicked: root.doLogin()
                }
            }
        }
    }

    // caps lock
    Label {
        anchors.top: loginBox.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: loginBox.horizontalCenter
        visible: keyboard.capsLock
        text: "󰈲  caps lock"   // 󰘲
        color: root.cCrit
        font.pixelSize: 13
    }

    // click outside — close popup
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: sessionPopup.visible = false
    }
}
