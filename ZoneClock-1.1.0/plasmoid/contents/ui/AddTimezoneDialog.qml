import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

import "TimezoneData.js" as TimezoneData


Window {
    id: dialog

    // Responsive sizing: adapt dialog to screen resolution
    // Prevents content cutoff on different displays
    property int screenWidth: Screen.width
    property int screenHeight: Screen.height
    
    width: Math.max(
        Kirigami.Units.gridUnit * 28,
        Math.min(Kirigami.Units.gridUnit * 42, Math.round(screenWidth * 0.6))
    )
    height: Math.max(
        Kirigami.Units.gridUnit * 28,
        Math.min(Kirigami.Units.gridUnit * 55, Math.round(screenHeight * 0.8))
    )

    title: isEdit ? i18n("Edit Timezone") : i18n("Add Timezone")

    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    color: "black"

    property string name: ""
    property string timezone: "UTC"
    property bool format24h: true
    property bool showSeconds: true

    // "offset" (fixed UTC offset, no daylight saving) or "iana" (real
    // country/city timezone, daylight saving applied automatically).
    property string mode: "offset"

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
            text: i18n("Set up a clock for a UTC offset or a real country/city timezone.")
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


        // --- Timezone kind ---

        ColumnLayout {

            Layout.fillWidth: true
            spacing: 2

            PlasmaComponents.Label {
                text: i18n("Timezone Type")
                color: "white"
                font.bold: true
            }

            RowLayout {

                spacing: Kirigami.Units.largeSpacing

                QQC2.RadioButton {
                    id: offsetModeRadio

                    text: i18n("UTC Offset")

                    checked: dialog.mode === "offset"

                    onCheckedChanged: {

                        if (checked) {

                            dialog.mode = "offset"

                            // A country/city id isn't valid here -
                            // fall back to plain UTC rather than
                            // leaving an unusable value selected.
                            if (!TimezoneData.isKnownZone(dialog.timezone)) {
                                dialog.timezone = "UTC"
                            }

                            offsetCombo.syncToDialogTimezone()
                        }
                    }
                }

                QQC2.RadioButton {
                    id: ianaModeRadio

                    text: i18n("Country / City")

                    checked: dialog.mode === "iana"

                    onCheckedChanged: {

                        if (checked) {

                            dialog.mode = "iana"

                            if (!TimezoneData.isKnownIanaZone(dialog.timezone)) {
                                dialog.timezone = "Etc/UTC"
                            }

                            countryCombo.syncToDialogTimezone()
                        }
                    }
                }
            }

            PlasmaComponents.Label {
                text: i18n("A UTC offset never changes for daylight saving. A country/city clock follows the local calendar and adjusts automatically.")
                color: "#aaaaaa"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }


        // --- Timezone value ---

        ColumnLayout {

            Layout.fillWidth: true
            spacing: 2

            PlasmaComponents.Label {
                text: dialog.mode === "iana" ? i18n("Country / City") : i18n("Timezone")
                color: "white"
                font.bold: true
            }

            QQC2.ComboBox {
                id: offsetCombo

                visible: dialog.mode === "offset"
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? implicitHeight : 0

                // Non-editable: the person can only pick from the
                // fixed UTC-offset list below, so there is no way to
                // type something invalid.
                editable: false

                model: TimezoneModel {}

                textRole: "display"
                valueRole: "tzdata"


                onCurrentValueChanged: {
                    if (dialog.mode === "offset") {
                        dialog.timezone = currentValue
                    }
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

            QQC2.ComboBox {
                id: countryCombo

                visible: dialog.mode === "iana"
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? implicitHeight : 0

                // Non-editable, same reasoning as offsetCombo above -
                // only the curated list is selectable.
                editable: false

                model: CountryTimezoneModel {}

                textRole: "display"
                valueRole: "tzdata"


                onCurrentValueChanged: {
                    if (dialog.mode === "iana") {
                        dialog.timezone = currentValue
                    }
                }


                function syncToDialogTimezone() {

                    for (let i = 0; i < model.rowCount(); i++) {

                        if (model.get(i).tzdata === dialog.timezone) {

                            currentIndex = i
                            return
                        }
                    }

                    // A previously-saved value that isn't in our
                    // country/city list - fall back to UTC rather
                    // than leaving the picker on an unknown value.
                    for (let j = 0; j < model.rowCount(); j++) {

                        if (model.get(j).tzdata === "Etc/UTC") {

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
                visible: dialog.mode === "offset"
                text: i18n("The UTC offset this clock follows.")
                color: "#aaaaaa"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                visible: dialog.mode === "iana"
                text: i18n("The local time for this city, including daylight saving.")
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
                    id: format24Radio

                    text: i18n("24-hour")

                    checked: dialog.format24h

                    onCheckedChanged: {

                        if (checked) {

                            dialog.format24h = true

                        }
                    }
                }

                QQC2.RadioButton {
                    id: format12Radio

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
                mode = "offset"

            }

            // nameInput.text (and the radios/checkbox below) start out
            // bound to the matching dialog.* property, but QML permanently
            // severs a control's binding the moment the user interacts
            // with that control - after that, setting dialog.name (or
            // .mode / .format24h / .showSeconds) no longer updates it.
            // Since this dialog instance is reused across multiple
            // add/edit operations, re-apply every value explicitly (and
            // restore the bindings with Qt.binding()) each time the
            // dialog opens, rather than relying on bindings that may
            // already be broken.
            nameInput.text = name

            offsetCombo.syncToDialogTimezone()
            countryCombo.syncToDialogTimezone()

            offsetModeRadio.checked = Qt.binding(function() { return dialog.mode === "offset" })
            ianaModeRadio.checked = Qt.binding(function() { return dialog.mode === "iana" })

            format24Radio.checked = Qt.binding(function() { return dialog.format24h })
            format12Radio.checked = Qt.binding(function() { return !dialog.format24h })

            showSecondsCheck.checked = Qt.binding(function() { return dialog.showSeconds })

            nameInput.forceActiveFocus()

            x = Screen.width / 2 - width / 2
            y = Screen.height / 2 - height / 2
        }
    }
}
