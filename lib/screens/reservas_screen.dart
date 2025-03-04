import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservasScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> cancelarReserva(String reservaId) async {
    await _db.collection('reservas').doc(reservaId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestión de Reservas")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('reservas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var reservas = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              var reserva = reservas[index];
              return ListTile(
                title: Text("Reserva ${reserva.id}"),
                subtitle: Text("Habitación: ${reserva['habitacion']}"),
                trailing: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => cancelarReserva(reserva.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
