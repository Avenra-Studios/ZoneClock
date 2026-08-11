import QtQuick
import "TimezoneData.js" as TimezoneData

ListModel {
    id: model

    Component.onCompleted: {
        // Built from the single canonical UTC-offset zone list in
        // TimezoneData.js, so the dropdown and the validation used
        // when restoring saved settings can never drift apart.
        for (let i = 0; i < TimezoneData.zones.length; i++) {
            let zone = TimezoneData.zones[i]
            model.append({
                display: zone.display,
                tzdata: zone.tzdata
            })
        }
    }
}
