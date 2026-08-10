import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami


Window {
    id: dialog

    width: Kirigami.Units.gridUnit * 32
    height: Kirigami.Units.gridUnit * 28

    title: isEdit ? i18n("Edit Timezone") : i18n("Add Timezone")

    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    color: "black"

    property string name: ""
    property string timezone: "UTC"
    property bool format24h: true
    property bool showSeconds: true
    property bool isEdit: false

    signal rejected()
    signal accepted()


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        spacing: Kirigami.Units.largeSpacing


        Kirigami.Heading {
            text: isEdit ? i18n("Edit Timezone") : i18n("Add a Timezone")
            level: 2
            color: "white"
            Layout.fillWidth: true
        }

        PlasmaComponents.Label {
            text: i18n("Set up a clock for a UTC offset.")
            color: "#cccccc"
            opacity: 0.8
            Layout.fillWidth: true
        }


        // --- Display name ---

        ColumnLayout {

            Layout.fillWidth: true
            spacing: 2

            PlasmaComponents.Label {
                text: i18n("Display Name")
                color: "white"
                font.bold: true
            }

            QQC2.TextField {
                id: nameInput

                text: dialog.name

                placeholderText: i18n("e.g. Home, Tokyo, Office")

                Layout.fillWidth: true

                onTextChanged: {
                    dialog.name = text
                }
            }

            PlasmaComponents.Label {
                text: i18n("What this clock will be labeled as in your list.")
                color: "#aaaaaa"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }


        // --- Timezone ---

        ColumnLayout {

            Layout.fillWidth: true
            spacing: 2

            PlasmaComponents.Label {
                text: i18n("Timezone")
                color: "white"
                font.bold: true
            }

            QQC2.ComboBox {
                id: tzCombo

                Layout.fillWidth: true

                // Non-editable: the person can only pick from the
                // fixed UTC-offset list below, so there is no way to
                // type something invalid.
                editable: false

                model: TimezoneModel {}

                textRole: "display"
                valueRole: "tzdata"


                onCurrentValueChanged: {
                    dialog.timezone = currentValue
                }


                function syncToDialogTimezone() {

                    for (let i = 0; i < model.rowCount(); i++) {

                        if (model.get(i).tzdata === dialog.timezone) {

                            currentIndex = i
                            return
                        }
                    }

                    // A previously-saved value that isn't one of our
                    // UTC-offset ids (e.g. from an older version of
                    // this widget) - fall back to UTC rather than
                    // leaving the picker on an unknown value.
                    for (let j = 0; j < model.rowCount(); j++) {

                        if (model.get(j).tzdata === "UTC") {

                            currentIndex = j
                            return
                        }
                    }

                    currentIndex = 0
                }


                Component.onCompleted:
                    syncToDialogTimezone()
            }

            PlasmaComponents.Label {
                text: i18n("The UTC offset this clock follows.")
                color: "#aaaaaa"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }


        // --- Time format ---

        ColumnLayout {

            Layout.fillWidth: true
            spacing: 2

            PlasmaComponents.Label {
                text: i18n("Time Format")
                color: "white"
                font.bold: true
            }

            RowLayout {

                spacing: Kirigami.Units.largeSpacing

                QQC2.RadioButton {

                    text: i18n("24-hour")

                    checked: dialog.format24h

                    onCheckedChanged: {

                        if (checked) {

                            dialog.format24h = true

                        }
                    }
                }

                QQC2.RadioButton {

                    text: i18n("12-hour")

                    checked: !dialog.format24h

                    onCheckedChanged: {

                        if (checked) {

                            dialog.format24h = false

                        }
                    }
                }
            }

            PlasmaComponents.Label {
                text: i18n("Whether this clock shows times like \"14:30\" or \"2:30 PM\".")
                color: "#aaaaaa"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }


        // --- Show seconds ---

        ColumnLayout {

            Layout.fillWidth: true
            spacing: 2

            QQC2.CheckBox {
                id: showSecondsCheck

                text: i18n("Show seconds")

                checked: dialog.showSeconds

                onCheckedChanged: {
                    dialog.showSeconds = checked
                }

                contentItem: PlasmaComponents.Label {
                    text: showSecondsCheck.text
                    color: "white"
                    font.bold: true
                    leftPadding: showSecondsCheck.indicator.width + showSecondsCheck.spacing
                    verticalAlignment: Text.AlignVCenter
                }
            }

            PlasmaComponents.Label {
                text: i18n("Whether this clock shows \"14:30:45\" or just \"14:30\".")
                color: "#aaaaaa"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }


        Item {
            Layout.fillHeight: true
        }


        RowLayout {

            Layout.alignment: Qt.AlignRight

            spacing: Kirigami.Units.smallSpacing


            QQC2.Button {
                text: i18n("Cancel")

                onClicked: {

                    dialog.rejected()

                    dialog.close()

                }
            }


            QQC2.Button {
                text: isEdit ? i18n("Save") : i18n("Add")

                enabled: nameInput.text.trim().length > 0

                highlighted: true

                onClicked: {

                    dialog.name = nameInput.text

                    dialog.accepted()

                    dialog.close()

                }
            }
        }
    }



    onVisibleChanged: {

        if (visible) {

            if (!isEdit) {

                name = ""
                timezone = "UTC"
                format24h = true
                showSeconds = true
                nameInput.text = ""

            }

            tzCombo.syncToDialogTimezone()

            nameInput.forceActiveFocus()

            x = Screen.width / 2 - width / 2
            y = Screen.height / 2 - height / 2
        }
    }
}
