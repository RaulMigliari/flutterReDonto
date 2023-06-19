import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:redontoapp/Detalhes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EscolhaDentistaWidget extends StatefulWidget {
  final String chamadoId;

  const EscolhaDentistaWidget({Key? key, required this.chamadoId})
      : super(key: key);

  @override
  _EscolhaDentistaWidgetState createState() => _EscolhaDentistaWidgetState();
}

class _EscolhaDentistaWidgetState extends State<EscolhaDentistaWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _buscarNomesUsuarios() {
    return _firestore
        .collection('Chamados')
        .where(FieldPath.documentId, isEqualTo: widget.chamadoId)
        .snapshots()
        .asyncMap((snapshot) async {
      final nomes = <Map<String, dynamic>>[];
      final userIds = <String>{};

      for (final doc in snapshot.docs) {
        final interesse = doc.get('interesse') as List<dynamic>;

        if (interesse.isEmpty) {
          // Mostrar a circular progress bar e a mensagem quando o campo "interesse" estiver vazio
          return Future.delayed(Duration(seconds: 2), () => []);
        }

        for (final interesseRef in interesse) {
          final usuarioRef = interesseRef as DocumentReference;
          final usuarioSnapshot = await usuarioRef.get();
          final usuarioData = usuarioSnapshot.data() as Map<String, dynamic>;
          final nome = usuarioData['nome'] as String?;
          final telefone = usuarioData['telefone'] as String?;
          final cep = usuarioData['cep1'] as String?;
          final fotoCadastro = usuarioData['fotoPerfil'] as String?;
          final userId = usuarioRef.id;
          final idChamado = doc.id;
          print('Dados do usuário: $nome, $telefone, $cep, $fotoCadastro');

          // Verificar se o ID do usuário já foi processado
          if (nome != null &&
              telefone != null &&
              cep != null &&
              !userIds.contains(userId)) {
            // Calcular a média das notas
            final avaliacoes = usuarioData['avaliacoes'] as List<dynamic>;
            double mediaNotas = 0;

            if (avaliacoes.isNotEmpty) {
              final notas = avaliacoes
                  .map((avaliacao) => avaliacao['nota'] as int)
                  .toList();
              mediaNotas = notas.reduce((a, b) => a + b) / notas.length;
            }

            nomes.add({
              'nome': nome,
              'telefone': telefone,
              'cep': cep,
              'idChamado': idChamado,
              'idUsuario': userId,
              'fotoPerfil': fotoCadastro,
              'mediaNotas': mediaNotas,
            });
            userIds.add(userId);
          }
        }
      }
      return nomes;
    });
  }

  void _selecionarUsuario(String nome, String telefone, String cep,
      String idChamado, String idUsuario, String fotoPerfil) {
    // Navegar para a tela de detalhes
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesUsuarioWidget(
          nome: nome,
          telefone: telefone,
          cep: cep,
          idChamado: idChamado,
          idUsuario: idUsuario,
          fotoPerfil: fotoPerfil,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional(0, 0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/circles.png',
                  ),
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
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Dentistas Disponíveis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 125, 25, 40),
                child: Material(
                  color: Colors.transparent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: 340,
                    height: 700,
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
                    alignment: AlignmentDirectional(0, 0),
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _buscarNomesUsuarios(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 20),
                                Text(
                                  'Estamos procurando um dentista...',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        } else {
                          final nomes = snapshot.data ?? [];

                          if (nomes.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 20),
                                  Text(
                                    'Estamos procurando um dentista...',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            itemCount: nomes.length,
                            itemBuilder: (context, index) {
                              final nome = nomes[index]['nome'] as String;
                              final telefone =
                              nomes[index]['telefone'] as String;
                              final cep = nomes[index]['cep'] as String;
                              final idChamado =
                              nomes[index]['idChamado'] as String;
                              final idUsuario =
                              nomes[index]['idUsuario'] as String;
                              final fotoCadastro =
                              nomes[index]['fotoPerfil'] as String?;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Material(
                                  color: Colors.transparent,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      _selecionarUsuario(
                                          nome,
                                          telefone,
                                          cep,
                                          idChamado,
                                          idUsuario,
                                          fotoCadastro ?? '');
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: fotoCadastro != null
                                                ? CircleAvatar(
                                              radius: 30,
                                              backgroundImage:
                                              CachedNetworkImageProvider(
                                                  fotoCadastro),
                                            )
                                                : CircleAvatar(
                                              radius: 30,
                                              backgroundColor:
                                              Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nome,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Telefone: $telefone',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              RatingBarIndicator(
                                                rating: nomes[index]['mediaNotas'] ?? 0.0,
                                                itemBuilder: (context, _) => Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                itemCount: 5,
                                                itemSize: 20.0,
                                                direction: Axis.horizontal,
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
