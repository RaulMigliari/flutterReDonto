import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationWidget extends StatefulWidget {
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    configureFirebaseMessaging();
  }

  void configureFirebaseMessaging() async {
    // Configurar a função de recebimento de notificações em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida em primeiro plano: ${message.notification?.title}');
    });

    // Configurar a função de recebimento de notificações ao clicar na notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mensagem aberta pelo usuário: ${message.notification?.title}');
    });

    // Solicitar permissão para receber notificações
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Verificar se a permissão foi concedida
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissão concedida!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
      ),
      body: Center(
        child: Text(
          'Widget para receber notificações',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}