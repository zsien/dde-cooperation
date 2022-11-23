import QtQuick 2.12
import QtQuick.Window 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.15
import QtMultimedia 5.8

Rectangle {
    // property bool maximized: window.isMaximized || mainWindow.isFullScreen

    anchors.fill: parent
    color: 'black'

    focus: true

    Keys.onPressed: function(event) {
        console.debug("key pressed: " + event.key)
        device.onKeyPressed(event.key, event.modifiers, event.text, event.isAutoRepeat, event.count)
    }

    Keys.onReleased: function(event) {
        console.debug("key released: " + event.key)
        device.onKeyReleased(event.key, event.modifiers, event.text, event.isAutoRepeat, event.count)
    }

    VideoOutput {
        id: videoOutput

        property double aimedRatio: sourceRect.width / sourceRect.height
        property double marginBottom: window.maximized ? 0 : buttons.height

        property double availableWidth: parent.width
        property double availableHeight: parent.height - marginBottom

        property double parentRatio: availableWidth / availableHeight
        property bool parentIsLarge: parentRatio > aimedRatio

        width: parentIsLarge ? availableHeight * aimedRatio : availableWidth 
        height: parentIsLarge ? availableHeight : availableWidth / aimedRatio

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: maximized ? parent.verticalCenter : undefined

        source: videoFrameProvider

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onPressed: function (mouse) {
                console.log("pressed")
                device.onMouseButtonPressed(mouse.x,
                                 mouse.y,
                                 mouse.button,
                                 mouse.buttons,
                                 mouse.modifiers,
                                 Qt.size(videoOutput.sourceRect.width, videoOutput.sourceRect.height),
                                 Qt.size(videoOutput.contentRect.width, videoOutput.contentRect.height))
            }

            onReleased: function (mouse) {
                console.log("released")
                device.onMouseButtonReleased(mouse.x,
                                  mouse.y,
                                  mouse.button,
                                  mouse.buttons,
                                  mouse.modifiers,
                                  Qt.size(videoOutput.sourceRect.width, videoOutput.sourceRect.height),
                                  Qt.size(videoOutput.contentRect.width, videoOutput.contentRect.height))
            }

            onPositionChanged: {
                console.log("[video content rect]", videoOutput.contentRect)
                console.log("[source rect]", videoOutput.sourceRect)
                console.log("moved!", mouse.x, mouse.y)

                device.onMouseMove(mouse.x,
                                   mouse.y,
                                   mouse.button,
                                   mouse.buttons,
                                   mouse.modifiers,
                                   Qt.size(videoOutput.sourceRect.width, videoOutput.sourceRect.height),
                                   Qt.size(videoOutput.contentRect.width, videoOutput.contentRect.height))
            }
        }
    }

    Rectangle {
        id: buttons

        width: window.maximized ? 56 : parent.width
        height: window.maximized ? parent.height : 56
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        GridLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            flow:  window.maximized ? GridLayout.TopToBottom : GridLayout.LeftToRight

            // spacing: 10

            RoundButton {
                width: 36
                height: 36
                radius: 8
                activeFocusOnTab: false
                icon.source: "qrc:///icons/back.svg"
                icon.width: 16
                icon.height: 16
                onClicked: device.onBackButtonClicked()
            }

            RoundButton {
                width: 36
                height: 36
                radius: 8
                activeFocusOnTab: false
                icon.source: "qrc:///icons/overview.svg"
                icon.width: 16
                icon.height: 16
                onClicked: device.onOverviewButtonClicked()
            }

            RoundButton {
                width: 36
                height: 36
                radius: 8
                activeFocusOnTab: false
                icon.source: "qrc:///icons/home.svg"
                icon.width: 16
                icon.height: 16
                onClicked: device.onHomeButtonClicked()
            }

            RoundButton {
                width: 36
                height: 36
                radius: 8
                activeFocusOnTab: false
                icon.source: "qrc:///icons/switch_screen.svg"
                icon.width: 16
                icon.height: 16
                onClicked: device.onSwitchScreenButtonClicked()
            }
        }
    }

    Shortcut {
        sequences: [StandardKey.Paste]

        onActivated: device.setClipboard();
    }

    Shortcut {
        sequences: [StandardKey.Copy, StandardKey.Cut]

        onActivated: device.getClipboard()
    }

    DropArea {
        id: dropArea;
        anchors.fill: parent

        onDropped: {
            console.log(drop.urls)
            backend.sendFiles(drop.urls)
        }
    }
}
