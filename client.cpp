#include "client.h"
#include "QJsonObject"
#include "QJsonDocument"
client::client(QObject* parent): QObject(parent){
    isConnected = false;
}


void client::connectToServer(const QString &ip, const QString &port, const QString &name){
    client_socket = new QTcpSocket(this);
    client_socket -> connectToHost(QHostAddress::LocalHost, 8080);
    this->client_name = name;

    connect(client_socket, &QTcpSocket::connected, this, &client::onConnected);
    connect(client_socket, &QTcpSocket::errorOccurred, this, &client::onErrorOccurred);
    connect(client_socket, &QTcpSocket::readyRead, this, &client::onReadyRead);
    connect(client_socket, &QTcpSocket::disconnected, this, &client::onDisconnected);
    //connect(client_socket, &QTcpSocket::stateChanged, this, &client::onStateChanged);
}

void client::sendMessage(const QString &type, const QString &message){
    QJsonObject toSendO;
    toSendO.insert("type", type);
    toSendO.insert("name", this->client_name);
    toSendO.insert("body", message);


    QJsonDocument toSendD;
    toSendD.setObject(toSendO);
    QByteArray toSendB = toSendD.toJson();

    client_socket->write(toSendB);
    client_socket->flush();
}

void client::changeClientName(const QString &newName){
    this->client_name = newName;
    this->sendMessage("join", this->client_name + " has joined.");
}

void client::disconnectFromServer(){
    client_socket->disconnectFromHost();
}

void client::onConnected()
{
    qInfo() << "Connected to host.";
    //emit newMessage("join", "You", "Connect to Server...");
    isConnected = true;
    emit newStatus(isConnected);
    this->sendMessage("join", this->client_name + " has joined.");
}

void client::onReadyRead()
{
    const auto message = client_socket->readAll();
    QJsonParseError jError;
    QJsonDocument recvJD = QJsonDocument::fromJson(message, &jError);
    if(jError.error != QJsonParseError::NoError){
        qWarning() << "Json Error: " << jError.errorString();
    }

    QJsonObject recvJO = recvJD.object();

    if(recvJO.value("type").toString() == "changeName"){
        emit changeName(recvJO.value("body").toString().toUtf8());
    }else{
        emit newMessage(recvJO.value("type").toString().toUtf8(), recvJO.value("name").toString().toUtf8() == this->client_name? "You":recvJO.value("name").toString().toUtf8(), recvJO.value("body").toString().toUtf8());
    }
}

void client::onErrorOccurred(QAbstractSocket::SocketError error)
{
    qWarning() << "Error:" << error;
    emit newMessage("error", "System", client_socket->errorString().toUtf8());
}

void client::onDisconnected(){
    disconnect(client_socket, &QTcpSocket::connected, this, &client::onConnected);
    disconnect(client_socket, &QTcpSocket::errorOccurred, this, &client::onErrorOccurred);
    disconnect(client_socket, &QTcpSocket::readyRead, this, &client::onReadyRead);
    disconnect(client_socket, &QTcpSocket::disconnected, this, &client::onDisconnected);
//    delete client_socket;
    client_socket->deleteLater();
    qInfo() << "Disconnected to host.";
    isConnected = false;
    emit newStatus(isConnected);
}

//void client::onStateChanged(QAbstractSocket::SocketState state){
//    qInfo() << "State: " << state;
//}

//bool client::getConnectedStatus(){
//    return this->isConnected;
//}
