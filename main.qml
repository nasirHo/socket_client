import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Chat Client")

    property bool isConnected: false

    Connections {
            target: client
            function onNewMessage(type, name, msg) {
                var nameColor
                switch (name + ""){
                case "Server":
                case "System":
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
                isConnected = s
                if(!s){
                    textFieldName.clear()
                    listModelMessages.clear()
                    listModelMessages.append({
                                                 textColor: "red",
                                                 name: "System",
                                                 body: "Welcome to chat client This is a loooooong text This is a loooooong textThis is a loooooong text"
                                             })
                    listViewMessages.positionViewAtEnd()
                }
            }

            function onChangeName(s){
                dialogChangeName.originName = s + ""
                dialogChangeName.open()
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

    Dialog{
        id: dialogChangeName
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        title: qsTr("Change your name")
        focus: true

        property string originName

        RowLayout{
            TextField{
                id: textFieldChangeName
                placeholderText: qsTr("User name is in use...")
                validator: RegExpValidator { regExp: /^[\w'\-,.][^0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{2,}$/ }
                focus: true
                Layout.fillWidth: true
                onAccepted: buttonChangeName.clicked()
            }
            Button{
                id:buttonChangeName
                text: qsTr("Change")
                enabled: textFieldChangeName.acceptableInput
                onClicked:{
                    console.log(textFieldChangeName.text)
                    if(textFieldChangeName.text === dialogChangeName.originName){
                        textFieldChangeName.clear()
                        return
                    }
                    textFieldName.text = textFieldChangeName.text
                    client.changeClientName(textFieldChangeName.text)
                    dialogChangeName.accept()
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
                enabled: !isConnected
                placeholderText: qsTr("Server IP")
                text: "127.0.0.1"
                validator: RegExpValidator { regExp: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$/ }
                Layout.fillWidth: true
                onAccepted: buttonConnect.clicked()
            }
            TextField {
                id: textFieldPort
                enabled: !isConnected
                placeholderText: qsTr("Server port")
                text: "8080"
                validator: RegExpValidator { regExp: /^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$/ }
                Layout.fillWidth: true
                onAccepted: buttonConnect.clicked()
            }
            TextField{
                id: textFieldName
                enabled: !isConnected
                placeholderText: qsTr("Name")
                validator: RegExpValidator { regExp: /^[\w'\-,.][^0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{2,}$/ }
                Layout.fillWidth: true
                onAccepted: buttonConnect.clicked()
                focus: !isConnected
            }

            Button {
                id: buttonConnect
                text: qsTr(isConnected?"Disconnect":"Connect")
                enabled: (textFieldIp.acceptableInput && textFieldPort.acceptableInput && textFieldName.acceptableInput) || isConnected
                onClicked:{
                    if (isConnected)
                        client.disconnectFromServer()
                    else
                        client.connectToServer(textFieldIp.text, textFieldPort.text, textFieldName.text)
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
                enabled: isConnected
                placeholderText: qsTr("Type your message ...")
                Layout.fillWidth: true
                onAccepted: buttonSend.clicked()
                focus: isConnected
            }
            Button {
                id: buttonSend
                text: qsTr("Send")
                enabled : isConnected
                onClicked: {
                    client.sendMessage(qsTr("msg"), textFieldMessage.text)
                    textFieldMessage.clear()
                }
            }
            Button {
                text: qsTr("Test")
                onClicked: {
                    dialogChangeName.originName = "Amber"
                    dialogChangeName.open()
                    console.log("here")
                }
            }
        }
    }
}
