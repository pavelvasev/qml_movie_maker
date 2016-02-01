Item {
    property var text: ""
    id: it
    width: 30
    height: 20

    Rectangle {
        border.color: "grey"
        width: 20
        height: 19

        Text {
            text: it.text
            //color: "white"
            anchors.centerIn: parent
        }
    }
}
