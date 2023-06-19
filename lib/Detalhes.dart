import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:redontoapp/AvalDetalhes.dart';
import 'package:redontoapp/Consulta.dart';
import 'package:redontoapp/CurriculoDetalhes.dart';
import 'package:redontoapp/EnderecosDetalhes.dart';

class DetalhesUsuarioWidget extends StatelessWidget {
  final String nome;
  final String telefone;
  final String cep;
  final String idChamado;
  final String idUsuario;
  final String? fotoPerfil;

  const DetalhesUsuarioWidget({
    Key? key,
    required this.nome,
    required this.telefone,
    required this.cep,
    required this.idChamado,
    required this.idUsuario,
    this.fotoPerfil,
  }) : super(key: key);

  void _handleAceitar(BuildContext context) async {
    // Salvar o ID do chamado no campo "paciente" do usuário
    final usuarioId = idUsuario; // Substitua pelo ID do usuário apropriado
    final chamadoId = idChamado;

    try {
      final usuarioRef = FirebaseFirestore.instance.collection('Usuarios').doc(usuarioId);
      await usuarioRef.update({'paciente': chamadoId, 'status': 'emConsulta'});

      // Apagar todos os dados do campo "emergencias"
      final usuarioDoc = await usuarioRef.get();
      if (usuarioDoc.exists) {
        final usuarioData = usuarioDoc.data();
        if (usuarioData != null && usuarioData['emergencias'] is List) {
          await usuarioRef.update({'emergencias': []});
        }
      }

      // Atualizar o status do chamado para "consulta"
      final chamadoRef = FirebaseFirestore.instance.collection('Chamados').doc(chamadoId);
      await chamadoRef.update({'status': 'consulta'});

      // Remover o idUsuario do campo "interesse" em todos os chamados
      final chamadosSnapshot = await FirebaseFirestore.instance.collection('Chamados')
          .where('interesse', arrayContains: usuarioId)
          .get();

      for (final chamadoDoc in chamadosSnapshot.docs) {
        final chamadoRef = FirebaseFirestore.instance.collection('Chamados').doc(chamadoDoc.id);
        await chamadoRef.update({
          'interesse': FieldValue.arrayRemove([usuarioId]),
        });
      }

      // Navegar para a tela de consulta
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultaWidget(
            nome: nome,
            telefone: telefone,
            cep: cep,
            idChamado: idChamado,
            idUsuario: idUsuario,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar o ID do chamado no usuário.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Detalhes do Dentista'),
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
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x33000000),
                            offset: Offset(0, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 24),
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: fotoPerfil != null
                                ? NetworkImage(fotoPerfil!)
                                : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nome: $nome',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Telefone: $telefone',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EnderecosDetalhes(idUsuario: idUsuario),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 110, vertical: 15),
                              backgroundColor: Color(0xFF0062DB), // Nova cor do botão "Endereços"
                            ),
                            child: Text(
                              'Endereços',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AvalDetalhes(idUsuario: idUsuario),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                                  backgroundColor: Colors.white, // Nova cor do botão "Avaliações"
                                  shadowColor: Colors.black.withOpacity(1), // Adicionando sombra ao botão "Avaliações"
                                  elevation: 3, // Aumentando o nível de elevação do botão "Avaliações"
                                ),
                                child: Text(
                                  'Avaliações',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CurriculoDetalhes(idUsuario: idUsuario),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                                  backgroundColor: Colors.white, // Nova cor do botão "Currículo"
                                  shadowColor: Colors.black.withOpacity(1), // Adicionando sombra ao botão "Currículo"
                                  elevation: 3, // Aumentando o nível de elevação do botão "Currículo"
                                ),
                                child: Text(
                                  'Currículo',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              _handleAceitar(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                              backgroundColor: Color(0xFF0062DB),
                            ),
                            child: Text(
                              'Aceitar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                        ],
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

