import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import "TimezoneData.js" as TimezoneData


Item {

    id: root


    property string timezone: ""

    property string name: ""

    property bool format24h: true

    property bool showSeconds: true

    // "offset" (fixed UTC offset) or "iana" (real timezone id, DST
    // handled automatically). Defaults to "offset" so entries saved
    // before this option existed keep working unchanged.
    property string mode: "offset"

    property int itemIndex: 0

    property bool showDragHandle: false

    // Correction from main.qml's network time sync, in ms. 0 means
    // "no correction available yet / sync failed" - falls back to
    // the local system clock, so the widget still works offline.
    property real timeOffsetMillis: 0



    signal move(string direction)

    signal edit()

    signal remove()



    implicitHeight:
        Kirigami.Units.gridUnit * 3


    property var currentTime: new Date()

    readonly property string displayTime: {

        if (!root.timezone || root.timezone.length === 0) {

            return i18n("No timezone")
        }

        // "offset" mode uses plain date-math (no daylight saving,
        // by definition of a fixed offset). "iana" mode resolves a
        // real timezone id via Intl.DateTimeFormat, which applies
        // daylight saving automatically - see TimezoneData.js for
        // why that's only used when explicitly chosen, with a
        // fail-safe fallback if this engine can't resolve it.
        return TimezoneData.formatTime(root.currentTime, root.timezone, root.format24h, root.showSeconds, root.mode)
    }

    // Human-readable label for the subtitle - the picker's display
    // name (e.g. "Japan — Tokyo") rather than the raw id, when known.
    readonly property string zoneLabel:
        TimezoneData.displayForZone(root.timezone, root.mode)


    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered:
            root.currentTime = new Date(Date.now() + root.timeOffsetMillis)
    }





    Rectangle {


        anchors.fill: parent


        radius: Kirigami.Units.smallSpacing


        color:
            Kirigami.Theme.backgroundColor





        RowLayout {


            anchors.fill: parent


            anchors.margins:
                Kirigami.Units.smallSpacing



            spacing:
                Kirigami.Units.smallSpacing




            QQC2.Button {

                visible:
                    root.showDragHandle

                flat: true

                icon.name:
                    "transform-move"

                onClicked:
                    dragMenu.popup()

                QQC2.Menu {

                    id: dragMenu

                    QQC2.MenuItem {
                        text: i18n("Move Up")
                        onTriggered: root.move("up")
                    }

                    QQC2.MenuItem {
                        text: i18n("Move Down")
                        onTriggered: root.move("down")
                    }
                }
            }



            ColumnLayout {


                Layout.fillWidth: true

                clip: true




                PlasmaComponents.Label {

                    Layout.fillWidth: true
                    Layout.minimumWidth: 0

                    text:
                        root.name

                    elide: Text.ElideRight

                    font.bold:
                        true

                }




                PlasmaComponents.Label {

                    Layout.fillWidth: true
                    Layout.minimumWidth: 0

                    text:
                        root.zoneLabel

                    elide: Text.ElideRight

                    opacity:
                        0.7

                }

            }



            PlasmaComponents.Label {

                text:
                    root.displayTime

                font.pointSize:
                    Kirigami.Theme.defaultFont.pointSize * 1.3

                font.family:
                    "monospace"

                Layout.alignment:
                    Qt.AlignVCenter

                Layout.minimumWidth: implicitWidth

            }


            Item {
                Layout.preferredWidth: Kirigami.Units.largeSpacing
            }


            RowLayout {

                spacing: Kirigami.Units.smallSpacing

                Layout.fillWidth: false

                QQC2.Button {

                    Layout.minimumWidth: implicitWidth
                    Layout.minimumHeight: implicitHeight

                    flat: true

                    icon.name:
                        "document-edit"



                    onClicked:
                        root.edit()

                }




                QQC2.Button {

                    Layout.minimumWidth: implicitWidth
                    Layout.minimumHeight: implicitHeight

                    flat: true

                    icon.name:
                        "edit-delete"



                    onClicked:
                        root.remove()

                }

            }


        }

    }

}
