import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Control {
    id: root
    
    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 12
        
        PlasmaComponents.Label {
            text: i18n("Zone Clock Configuration")
            font.bold: true
            font.pointSize: 14
        }
        
        PlasmaComponents.Label {
            text: i18n("Use the main widget to add, edit, and manage timezones.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            opacity: 0.8
        }
        
        Item { Layout.fillHeight: true }
    }
}
