import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redontoapp/AvalDetalhes.dart';
import 'package:redontoapp/Avaliacao.dart';
import 'package:redontoapp/CurriculoDetalhes.dart';
import 'package:redontoapp/EnderecosDetalhes.dart';

class ConsultaWidget extends StatefulWidget {
  final String nome;
  final String telefone;
  final String cep;
  final String idChamado;
  final String idUsuario;
  final String? fotoPerfil;

  const ConsultaWidget({
    Key? key,
    required this.nome,
    required this.telefone,
    required this.cep,
    required this.idChamado,
    required this.idUsuario,
    this.fotoPerfil,
  }) : super(key: key);

  @override
  ConsultaWidgetState createState() => ConsultaWidgetState();
}

class ConsultaWidgetState extends State<ConsultaWidget> {
  String? fotoPerfil;
  TextEditingController codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    buscarFotoPerfil();
  }

  void buscarFotoPerfil() async {
    final usuarioId = widget.idUsuario;
    final usuarioRef = FirebaseFirestore.instance.collection('Usuarios').doc(usuarioId);
    final usuarioDoc = await usuarioRef.get();

    if (usuarioDoc.exists) {
      final fotoPerfil = usuarioDoc['fotoPerfil'] as String?;
      setState(() {
        this.fotoPerfil = fotoPerfil;
      });
    }
  }

  void _finalizarConsulta(BuildContext context) async {
    final usuarioId = widget.idUsuario;
    final chamadoId = widget.idChamado;

    try {
      final usuarioRef = FirebaseFirestore.instance.collection('Usuarios').doc(usuarioId);
      final usuarioDoc = await usuarioRef.get();
      final senhaFim = usuarioDoc['senhaFim'] as String?;

      if (senhaFim != null && codigoController.text == senhaFim) {
        final paciente = usuarioDoc['paciente'];

        if (paciente == chamadoId) {
          await usuarioRef.update({'paciente': ""});
        }

        await usuarioRef.update({'status': 'online'});

        final chamadoRef = FirebaseFirestore.instance.collection('Chamados').doc(chamadoId);
        await chamadoRef.update({'status': 'atendido'});

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvaliacaoWidget(
              idUsuario: widget.idUsuario,
              idChamado: widget.idChamado,
            ),
          ),
        );
      } else {
        // Display incorrect password message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Senha incorreta.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar o status do chamado.'),
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
          title: Text('Consulta'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/circles.png'),
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
                        height: 650,
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
                              'Nome: ${widget.nome}',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Telefone: ${widget.telefone}',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EnderecosDetalhes(idUsuario: widget.idUsuario),
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
                                        builder: (context) => AvalDetalhes(idUsuario: widget.idUsuario),
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
                                        builder: (context) => CurriculoDetalhes(idUsuario: widget.idUsuario),
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
                            SizedBox(height: 40),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: codigoController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Código de Finalização',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _finalizarConsulta(context);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                                backgroundColor: Colors.red,
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
      ),
    );
  }
}
