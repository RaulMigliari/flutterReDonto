import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EnderecosDetalhes extends StatelessWidget {
  final String idUsuario;

  const EnderecosDetalhes({Key? key, required this.idUsuario}) : super(key: key);

  void _openGoogleMaps(String cep) async {
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$cep';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Não foi possível abrir o Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Endereços'),
          centerTitle: true,
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
                    image: AssetImage('assets/images/background_image.jpg'),
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
                      height: 780,
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
                            final data = snapshot.data!.data() as Map<String, dynamic>?;

                            if (data != null) {
                              final ceps = ['cep1', 'cep2', 'cep3'];
                              final numeros = ['numero1', 'numero2', 'numero3'];
                              final ruas = ['rua1', 'rua2', 'rua3'];
                              final bairros = ['bairro1', 'bairro2', 'bairro3'];
                              final complementos = ['complemento1', 'complemento2', 'complemento3'];

                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: ceps.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final cep = entry.value;
                                    final numero = numeros[index];
                                    final rua = ruas[index];
                                    final bairro = bairros[index];
                                    final complemento = complementos[index];

                                    final cepValue = data.containsKey(cep) &&
                                        data[cep] is String &&
                                        (data[cep] as String).isNotEmpty
                                        ? data[cep]
                                        : 'Nenhum dado disponível';

                                    final numeroValue = data.containsKey(numero) &&
                                        data[numero] is String &&
                                        (data[numero] as String).isNotEmpty
                                        ? data[numero]
                                        : 'Nenhum dado disponível';

                                    final ruaValue = data.containsKey(rua) &&
                                        data[rua] is String &&
                                        (data[rua] as String).isNotEmpty
                                        ? data[rua]
                                        : 'Nenhum dado disponível';

                                    final bairroValue = data.containsKey(bairro) &&
                                        data[bairro] is String &&
                                        (data[bairro] as String).isNotEmpty
                                        ? data[bairro]
                                        : 'Nenhum dado disponível';

                                    final complementoValue = data.containsKey(complemento) &&
                                        data[complemento] is String &&
                                        (data[complemento] as String).isNotEmpty
                                        ? data[complemento]
                                        : 'Nenhum dado disponível';

                                    return GestureDetector(
                                      onTap: () => _openGoogleMaps(cepValue),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        margin: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.location_on),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'CEP',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      cepValue,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(Icons.confirmation_number),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Número',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      numeroValue,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(Icons.home),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Rua',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      ruaValue,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(Icons.location_city),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Bairro',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      bairroValue,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(Icons.details),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Complemento',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      complementoValue,
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
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
      ),
    );
  }
}




