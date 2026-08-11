import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami


PlasmoidItem {

    id: root


    preferredRepresentation: compactRepresentation


    toolTipSubText:
        i18n("Click to manage world timezones")


    property var timezoneData: {

        try {

            if (plasmoid.configuration.timezones) {
                return JSON.parse(
                    plasmoid.configuration.timezones
                )
            }

        } catch(error) {

            console.log(error)

        }

        return []

    }


    // Correction (in ms) applied to the local system clock so every
    // clock in the list is based on real, network-verified time
    // rather than whatever the device's own clock happens to read.
    // Read from the "Date" response header of a plain HTTPS request
    // rather than a specific time API, so this doesn't depend on any
    // one third-party service staying up. Defaults to 0 (falls back
    // to the local system clock) until/unless a sync succeeds.
    property real timeOffsetMillis: 0

    function syncTimeFromNetwork() {

        let xhr = new XMLHttpRequest()

        xhr.open("HEAD", "https://www.google.com", true)

        xhr.onreadystatechange = function() {

            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return
            }

            if (xhr.status < 200 || xhr.status >= 400) {
                return
            }

            let dateHeader = xhr.getResponseHeader("Date")

            if (!dateHeader) {
                return
            }

            let serverMillis = Date.parse(dateHeader)

            if (isNaN(serverMillis)) {
                return
            }

            root.timeOffsetMillis = serverMillis - Date.now()
        }

        xhr.send()
    }

    Component.onCompleted:
        syncTimeFromNetwork()

    Timer {
        // Re-sync periodically in case the widget stays open a long
        // time - keeps drift from creeping back in.
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered:
            root.syncTimeFromNetwork()
    }



    compactRepresentation: Item {


        implicitWidth:
            Kirigami.Units.iconSizes.small

        implicitHeight:
            Kirigami.Units.iconSizes.small



        Kirigami.Icon {

            anchors.fill: parent

            source: "globe"

            active:
                mouseArea.containsMouse

        }



        MouseArea {

            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true


            onClicked: {
                root.expanded = !root.expanded
            }

        }

    }



    fullRepresentation: Item {


        id: popup


        readonly property int popupWidth: Kirigami.Units.gridUnit * 38
        readonly property int popupHeight: Kirigami.Units.gridUnit * 48

        width: popupWidth
        height: popupHeight

        implicitWidth: popupWidth
        implicitHeight: popupHeight

        Layout.preferredWidth: popupWidth
        Layout.preferredHeight: popupHeight

        Layout.minimumWidth: popupWidth
        Layout.minimumHeight: popupHeight


        Rectangle {

            anchors.fill: parent

            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.smallSpacing
        }

        ColumnLayout {

            id: contentColumn

            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing

            spacing: Kirigami.Units.smallSpacing


            RowLayout {

                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "globe"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                }

                Kirigami.Heading {
                    text: i18n("Zone Clock")
                    level: 2
                    Layout.fillWidth: true
                }

                PlasmaComponents.Label {
                    text: root.timezoneData.length
                    opacity: 0.6
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            QQC2.ScrollView {

                Layout.fillWidth: true

                Layout.fillHeight: true

                clip: true

                QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
                QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AsNeeded


                ColumnLayout {


                    id: timezoneList


                    width:
                        parent.width


                    spacing:
                        Kirigami.Units.smallSpacing


                    Repeater {


                        model:
                            root.timezoneData.length


                        delegate:
                            TimezoneDelegateItem {


                                Layout.fillWidth: true


                                timezone:
                                    root.timezoneData[index].timezone


                                name:
                                    root.timezoneData[index].name


                                format24h:
                                    root.timezoneData[index].format24h


                                // Older saved entries (from before this
                                // option existed) have no showSeconds
                                // field at all - treat that as "on",
                                // matching the previous always-on behavior.
                                showSeconds:
                                    root.timezoneData[index].showSeconds !== false


                                // Older saved entries have no mode field
                                // at all - treat that as "offset",
                                // matching the previous UTC-offset-only
                                // behavior.
                                mode:
                                    root.timezoneData[index].mode === "iana" ? "iana" : "offset"


                                timeOffsetMillis:
                                    root.timeOffsetMillis


                                itemIndex:
                                    index


                                showDragHandle:
                                    root.timezoneData.length > 1


                                onMove: {

                                    let zones =
                                        root.timezoneData.slice()

                                    if(direction === "up"
                                    && index > 0) {

                                        let temp =
                                            zones[index]

                                        zones[index] =
                                            zones[index-1]

                                        zones[index-1] =
                                            temp

                                    }

                                    else if(direction === "down"
                                    && index <
                                    zones.length-1) {

                                        let temp =
                                            zones[index]

                                        zones[index] =
                                            zones[index+1]

                                        zones[index+1] =
                                            temp

                                    }

                                    plasmoid.configuration.timezones =
                                        JSON.stringify(zones)

                                    root.timezoneData =
                                        zones

                                }


                                onRemove: {

                                    let zones =
                                        root.timezoneData.slice()

                                    zones.splice(index,1)

                                    plasmoid.configuration.timezones =
                                        JSON.stringify(zones)

                                    root.timezoneData =
                                        zones

                                }


                                onEdit: {

                                    editDialog.currentIndex =
                                        index

                                    editDialog.name =
                                        root.timezoneData[index].name

                                    editDialog.timezone =
                                        root.timezoneData[index].timezone

                                    editDialog.format24h =
                                        root.timezoneData[index].format24h

                                    editDialog.showSeconds =
                                        root.timezoneData[index].showSeconds !== false

                                    editDialog.mode =
                                        root.timezoneData[index].mode === "iana" ? "iana" : "offset"


                                    editDialog.show()
                                    editDialog.raise()
                                    editDialog.requestActivate()

                                }


                            }

                    }


                    PlasmaComponents.Label {


                        visible:
                            root.timezoneData.length === 0


                        text:
                            i18n("No timezones added yet")


                        opacity: 0.6


                        Layout.alignment:
                            Qt.AlignHCenter


                    }


                }

            }


            PlasmaComponents.Button {
                icon.name: "list-add-symbolic"
                text: i18n("Add Timezone")
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2.2

                highlighted: true

                onClicked: {
                    addDialog.show()
                    addDialog.raise()
                    addDialog.requestActivate()
                }
            }

        }
    }

    // Add timezone dialog
    AddTimezoneDialog {
        id: addDialog

        onAccepted: {

            let zones = root.timezoneData.slice()

            zones.push({
                name: name,
                timezone: timezone,
                format24h: format24h,
                showSeconds: showSeconds,
                mode: mode
            })

            plasmoid.configuration.timezones =
                JSON.stringify(zones)

            root.timezoneData = zones
        }
    }


    AddTimezoneDialog {
        id: editDialog

        property int currentIndex: -1

        isEdit: true


        onAccepted: {

            if (currentIndex >= 0) {

                let zones = root.timezoneData.slice()

                zones[currentIndex] = {
                    name: name,
                    timezone: timezone,
                    format24h: format24h,
                    showSeconds: showSeconds,
                    mode: mode
                }

                plasmoid.configuration.timezones =
                    JSON.stringify(zones)

                root.timezoneData = zones
            }
        }
    }
}
