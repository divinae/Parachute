import QtQuick 2.14
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: screenItem
    visible: false
    clip: true // Fixes the glitches? Caused by desktopsBar going out of screen?

    property alias desktopsBarRepeater: desktopsBarRepeater
    property alias bigDesktopsRepeater: bigDesktopsRepeater
    property alias desktopThumbnail: desktopThumbnail
    // property alias activitiesBackgrounds: activitiesBackgrounds

    property int screenIndex: model.index

    // Repeater {
    //     id: activitiesBackgrounds
    //     model: workspace.activities.length
    PlasmaCore.WindowThumbnail {
        id: desktopThumbnail
        anchors.fill: parent
        visible: winId !== 0
        opacity: mainWindow.configBlurBackground ? 0 : 1
    }
    // }

    FastBlur {
        id: blurBackground
        anchors.fill: parent
        source: desktopThumbnail
        radius: 48
        visible: desktopThumbnail.winId !== 0 && mainWindow.configBlurBackground
        // cached: true
    }

    Item {
        id: desktopsBar
        height: parent.height / 6
        anchors.bottom: bigDesktops.top
        anchors.right: parent.right
        anchors.left: parent.left

        Rectangle { // To apply some transparency without interfere with children transparency
            id: desktopsBarBackground
            anchors.fill: parent
            color: "black"
            opacity: 0.1
        }

        Item { // To centralize children
            id: desktopsWrapper
            width: childrenRect.width
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                id: desktopsBarRepeater
                model: mainWindow.workWithActivities ? workspace.activities.length : workspace.desktops

                DesktopComponent {
                    x: 15 + index * (width + 15)
                    y: 15
                    width: (height / screenItem.height) * screenItem.width
                    height: desktopsBar.height - 30
                    activity: mainWindow.workWithActivities ? workspace.activities[index] : ""
                }
            }
        }
    }

    SwipeView {
        id: bigDesktops
        anchors.fill: parent
        anchors.topMargin: parent.height / 6
        clip: true
        currentIndex: mainWindow.currentActivityOrDesktop
        //vertical: true

        Behavior on anchors.topMargin {
            enabled: mainWindow.easingType !== mainWindow.noAnimation
            NumberAnimation { duration: animationsDuration; easing.type: mainWindow.easingType; }
        }

        Repeater {
            id: bigDesktopsRepeater
            model: mainWindow.workWithActivities ? workspace.activities.length : workspace.desktops

            Item { // Cannot set geometry of SwipeView's root item
                property alias bigDesktop: bigDesktop

                DesktopComponent {
                    id: bigDesktop
                    big: true
                    activity: mainWindow.workWithActivities ? workspace.activities[index] : ""
                    anchors.centerIn: parent
                    width: desktopRatio < screenRatio ? parent.width - bigDesktopMargin
                            : parent.height / screenItem.height * screenItem.width - bigDesktopMargin
                    height: desktopRatio > screenRatio ? parent.height - bigDesktopMargin
                            : parent.width / screenItem.width * screenItem.height - bigDesktopMargin

                    property real desktopRatio: parent.width / parent.height
                    property real screenRatio: screenItem.width / screenItem.height
                }
            }
        }

        onCurrentIndexChanged: {
            mainWindow.workWithActivities ? workspace.currentActivity = workspace.activities[currentIndex]
                    : workspace.currentDesktop = currentIndex + 1;
        }
    }
}