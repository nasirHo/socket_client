#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QHostAddress>

class client : public QObject
{
    Q_OBJECT

public:
    explicit client(QObject *parent = nullptr);

signals:
    void newMessage(const QByteArray &type, const QByteArray &name, const QByteArray &ba);
    void newStatus(bool s);
    void changeName(const QByteArray &originName);

public slots:
    void connectToServer(const QString &ip, const QString &port, const QString &name);
    void sendMessage(const QString &type, const QString &message);
    void changeClientName(const QString& newName);
    void disconnectFromServer();

private slots:
    void onConnected();
    void onReadyRead();
    void onErrorOccurred(QAbstractSocket::SocketError error);
    void onDisconnected();
    //void onStateChanged(QAbstractSocket::SocketState state);

private:
    QTcpSocket* client_socket;
    bool isConnected;
    QString client_name;
};

#endif // CLIENT_H
