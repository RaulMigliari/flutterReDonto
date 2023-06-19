import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AvalDetalhes extends StatelessWidget {
  final String idUsuario;

  const AvalDetalhes({Key? key, required this.idUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Avaliações'),
          centerTitle: true,
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

                            if (data != null &&
                                data['avaliacoes'] is List) {
                              final avaliacoes =
                              data['avaliacoes'] as List<dynamic>;

                              return ListView.builder(
                                itemCount: avaliacoes.length,
                                itemBuilder: (context, index) {
                                  final avaliacao = avaliacoes[index];
                                  final nota = avaliacao['nota'];
                                  final comentario =
                                  avaliacao['comentario'];

                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: Color(0x33000000),
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title: RatingBar.builder(
                                        initialRating: nota.toDouble(),
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 20,
                                        itemPadding:
                                        EdgeInsets.symmetric(horizontal: 1.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          // Implement your logic when the rating is updated
                                        },
                                      ),
                                      subtitle: Text('Comentário: $comentario'),
                                    ),
                                  );
                                },
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
