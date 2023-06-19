import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurriculoDetalhes extends StatelessWidget {
  final String idUsuario;

  const CurriculoDetalhes({Key? key, required this.idUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Currículo'),
          centerTitle: true, // Centraliza o título da AppBar
        ),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Usuarios')
                            .doc(idUsuario)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data =
                            snapshot.data!.data() as Map<String, dynamic>?;

                            if (data != null && data['curriculo'] is String) {
                              final curriculo = data['curriculo'] as String;

                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(curriculo),
                              );
                            }
                          }

                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
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

