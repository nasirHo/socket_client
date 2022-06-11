import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Chat Client")

    property string nameColor

    Connections {
            target: client
            function onNewMessage(type, name, msg) {
                switch (name + ""){
                case "Server":
                    nameColor = "red"
                    break
                case "You":
                    nameColor = "blue"
                    break;
                default:
                    nameColor = "green"
                }

                listModelMessages.append({
                                             textColor : nameColor,
                                             name: name + "",
                                             body: msg + ""
                                         })
                listViewMessages.positionViewAtEnd()
            }

            function onNewStatus(s){
                textFieldIp.enabled = !s;
                textFieldPort.enabled = !s;
                textFieldName.enabled = !s;
                buttonSend.enabled = s;
                if(s){
                    buttonConnect.text = "Disconnect"
                    textFieldName.focus = false
                    textFieldMessage.focus = true
                }else{
                    buttonConnect.text = "Connect"
                    textFieldName.clear()
                    textFieldName.focus = true
                    textFieldMessage.focus = false
                    listModelMessages.clear()
                    listModelMessages.append({
                                                 textColor: "red",
                                                 name: "System",
                                                 body: "Welcome to chat client This is a loooooong text This is a loooooong textThis is a loooooong text"
                                             })
                    listViewMessages.positionViewAtEnd()
                }
            }
    }

    Component{
        id: msgDelegate
        Item{
            id: msgWrapper
            width: root.width
            height: 80

            ColumnLayout{
                anchors.left: parent.left
                Text{
                    id: msgName
                    text: name
                    color: textColor
                    Layout.preferredHeight: 20
                    Layout.fillWidth: true
                }
                Text{
                    id: msgBody
                    text: body
                    wrapMode: Text.WordWrap
                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.width
                    Layout.alignment: Qt.AlignTop
                }
            }
        }

    }

    ColumnLayout {
        id: root
        anchors.fill: parent
        anchors.margins: 10
        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: textFieldIp
                placeholderText: qsTr("Server IP")
                text: "127.0.0.1"
                Layout.fillWidth: true
                onAccepted: buttonConnect.clicked()
            }
            TextField {
                id: textFieldPort
                placeholderText: qsTr("Server port")
                text: "8080"
                Layout.fillWidth: true
                onAccepted: buttonConnect.clicked()
            }
            TextField{
                id: textFieldName
                placeholderText: qsTr("Name")
                Layout.fillWidth: true
                onAccepted: buttonConnect.clicked()
                focus: true
            }

            Button {
                id: buttonConnect
                text: qsTr("Connect")
                onClicked:{
                    if (textFieldIp.enabled)
                        client.connectToServer(textFieldIp.text, textFieldPort.text, textFieldName.text)
                    else
                        client.disconnectFromServer()
                }
            }
        }
        ListView {
            id: listViewMessages
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            model: ListModel {
                id: listModelMessages
                ListElement {
                    textColor: "red"
                    name: "System"
                    body: "Welcome to chat client This is a loooooong text This is a loooooong textThis is a loooooong text"
                }
            }
            delegate: msgDelegate
            ScrollBar.vertical: ScrollBar {
                active: true
            }
        }
        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: textFieldMessage
                placeholderText: qsTr("Type your message ...")
                Layout.fillWidth: true
                onAccepted: buttonSend.clicked()
            }
            Button {
                id: buttonSend
                text: qsTr("Send")
                enabled : false
                onClicked: {
                    client.sendMessage(qsTr("msg"), textFieldMessage.text)
                    textFieldMessage.clear()
                }
            }
        }
    }
}
