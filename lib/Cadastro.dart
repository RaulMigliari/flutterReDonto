import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redontoapp/EscolhaDentista.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Chamados {
  String? nome;
  String? telefone;
  List<String>? imagens;

  Chamados({this.nome, this.telefone, this.imagens});
}

class MyFormScreen extends StatefulWidget {
  @override
  _MyFormScreenState createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  List<String> _imagePaths = [];
  bool _uploadingImages = false;

  // Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');
  }

  Future<void> openCamera() async {
    final pickedFile = await _picker.getImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  Future<void> openGallery() async {
    final pickedFile = await _picker.getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  Future<List<String>> uploadImagesToFirebaseStorage(
      List<String> imagePaths, String chamadoId) async {
    List<String> downloadUrls = [];
    try {
      for (String imagePath in imagePaths) {
        final file = File(imagePath);
        final fileName = file.path.split('/').last;
        final storageRef =
        FirebaseStorage.instance.ref().child('$chamadoId/$fileName');
        final uploadTask = storageRef.putFile(file);

        setState(() {
          _uploadingImages = true;
        });

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: $progress');
        });

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
      return downloadUrls;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer upload das imagens.'),
        ),
      );
      return [];
    } finally {
      setState(() {
        _uploadingImages = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final nome = _nameController.text;
      final telefone = _phoneController.text;

      // Save the data to Firestore
      try {
        final collection = FirebaseFirestore.instance.collection('Chamados');
        final docRef = await collection.add({
          'nome': nome,
          'telefone': telefone,
          'status': 'espera',
          'fcmToken': _fcmToken, // Salva o token FCM no Firestore junto com os outros dados
        });

        final chamadoId = docRef.id;

        // Upload images to Firebase Storage and get the download URLs
        final downloadUrls =
        await uploadImagesToFirebaseStorage(_imagePaths, chamadoId);

        await docRef.update({'imagens': downloadUrls});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dados salvos no Firestore.'),
          ),
        );

        _formKey.currentState!.reset();
        setState(() {
          _imagePaths.clear();
        });

        // Navigate to the next screen and pass the chamadoId as a parameter
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EscolhaDentistaWidget(chamadoId: chamadoId),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar os dados no Firestore.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/circles.png',
                    ).image,
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFF0062DB), Color(0xFF162676)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(0.87, 1),
                    end: AlignmentDirectional(-0.87, -1),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Material(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: 340,
                      height: 600,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x33000000),
                            offset: Offset(0, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nome',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, insira um nome.';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Telefone',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, insira um telefone.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: _imagePaths.length < 3
                                        ? openCamera
                                        : null,
                                    child: Text('Câmera'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _imagePaths.length < 3
                                        ? openGallery
                                        : null,
                                    child: Text('Galeria'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),
                              _imagePaths.isNotEmpty
                                  ? SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _imagePaths.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                      EdgeInsets.only(right: 8.0),
                                      child: Image.file(
                                          File(_imagePaths[index])),
                                    );
                                  },
                                ),
                              )
                                  : Placeholder(),
                              SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: _submitForm,
                                child: Text('Salvar'),
                              ),
                              SizedBox(height: 16.0),
                              if (_uploadingImages)
                                LinearProgressIndicator(), // Show progress bar while uploading images
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
