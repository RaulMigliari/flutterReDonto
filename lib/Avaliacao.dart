import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:redontoapp/Emergencias.dart';

class AvaliacaoWidget extends StatefulWidget {
  final String? idUsuario;
  final String? idChamado;

  const AvaliacaoWidget({
    Key? key,
    this.idUsuario,
    this.idChamado,
  }) : super(key: key);

  @override
  _AvaliacaoWidgetState createState() => _AvaliacaoWidgetState();
}

class _AvaliacaoWidgetState extends State<AvaliacaoWidget> {
  double atendimentoRating = 0;
  double aplicativoRating = 0;
  TextEditingController atendimentoController = TextEditingController();
  TextEditingController aplicativoController = TextEditingController();

  void _avaliar(BuildContext context) async {
    final usuarioId = widget.idUsuario;
    final chamadoId = widget.idChamado;

    final atendimentoRatingValue = atendimentoRating;
    final aplicativoRatingValue = aplicativoRating;
    final atendimentoComentario = atendimentoController.text;
    final aplicativoComentario = aplicativoController.text;

    if (atendimentoRatingValue == 0 ||
        aplicativoRatingValue == 0 ||
        atendimentoComentario.isEmpty ||
        aplicativoComentario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos antes de avaliar.'),
        ),
      );
      return;
    }

    try {
      final usuarioRef = FirebaseFirestore.instance.collection('Usuarios').doc(usuarioId);
      final usuarioDoc = await usuarioRef.get();
      final paciente = usuarioDoc['paciente'];

      if (paciente == chamadoId) {
        await usuarioRef.update({'paciente': ""});
      }

      await usuarioRef.update({'status': 'online'});

      final chamadoRef = FirebaseFirestore.instance.collection('Chamados').doc(chamadoId);
      await chamadoRef.update({'status': 'atendido'});

      final avaliacoesRef = FirebaseFirestore.instance.collection('Usuarios').doc(usuarioId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final avaliacoesDoc = await transaction.get(avaliacoesRef);

        List<Map<String, dynamic>> avaliacoes = [];

        if (avaliacoesDoc.exists) {
          avaliacoes = List<Map<String, dynamic>>.from(avaliacoesDoc['avaliacoes']);
        }

        avaliacoes.add({
          'nota': atendimentoRatingValue.toInt(),
          'comentario': atendimentoComentario,
        });

        transaction.update(avaliacoesRef, {'avaliacoes': avaliacoes});
      });

      final avaliacoesAppRef = FirebaseFirestore.instance.collection('AvaliacoesApp').doc(chamadoId);
      await avaliacoesAppRef.set({
        'nota': aplicativoRatingValue.toInt(),
        'comentario': aplicativoComentario,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmergenciaWidget()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar o status do chamado.'),
        ),
      );
    }
  }


  void _naoAvaliar(BuildContext context) async {
    final usuarioId = widget.idUsuario;
    final chamadoId = widget.idChamado;

    try {
      final usuarioRef = FirebaseFirestore.instance.collection('Usuarios').doc(usuarioId);
      final usuarioDoc = await usuarioRef.get();
      final paciente = usuarioDoc['paciente'];

      if (paciente == chamadoId) {
        await usuarioRef.update({'paciente': ""});
      }

      await usuarioRef.update({'status': 'online'});

      final chamadoRef = FirebaseFirestore.instance.collection('Chamados').doc(chamadoId);
      await chamadoRef.update({'status': 'atendido'});

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmergenciaWidget()),
      );
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
          title: Text(
            'Avaliação',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Avalie o Profissional e o Aplicativo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Avaliação do Atendimento:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            RatingBar.builder(
                              initialRating: atendimentoRating,
                              minRating: 0,
                              maxRating: 5,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 40,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  atendimentoRating = rating;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Comentário sobre o Atendimento:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 300,
                              child: TextField(
                                controller: atendimentoController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Avaliação do TeethKids aplicativo:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            RatingBar.builder(
                              initialRating: aplicativoRating,
                              minRating: 0,
                              maxRating: 5,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 40,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  aplicativoRating = rating;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Comentário sobre o TeethKids aplicativo:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              width: 300,
                              child: TextField(
                                controller: aplicativoController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _avaliar(context);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 105, vertical: 15),
                                backgroundColor: Colors.blue,
                              ),
                              child: Text(
                                'Avaliar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _naoAvaliar(context);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                                backgroundColor: Colors.red,
                              ),
                              child: Text(
                                'Não Avaliar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
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
