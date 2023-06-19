import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:redontoapp/Emergencias.dart';
import 'package:redontoapp/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Mensagem recebida em segundo plano: ${message.notification?.title}');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      home: EmergenciaWidget(),
    );

  }
}



