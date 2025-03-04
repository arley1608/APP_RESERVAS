import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_habitacion_screen.dart';

class HabitacionesScreen extends StatelessWidget {
  final String rol; // 🔹 Recibimos el rol del usuario

  HabitacionesScreen({required this.rol});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> eliminarHabitacion(String id) async {
    await _db.collection('habitaciones').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestión de Habitaciones")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('habitaciones').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var habitaciones = snapshot.data!.docs;
          return ListView.builder(
            itemCount: habitaciones.length,
            itemBuilder: (context, index) {
              var habitacion = habitaciones[index];
              return ListTile(
                title: Text("Habitación ${habitacion['numero']}"),
                subtitle:
                    Text("${habitacion['tipo']} - \$${habitacion['precio']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rol == "admin")
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarHabitacionScreen(
                                habitacionId: habitacion.id,
                                numero: habitacion['numero'],
                                tipo: habitacion['tipo'],
                                precio: habitacion['precio'].toDouble(),
                              ),
                            ),
                          );
                        },
                      ),
                    if (rol == "admin")
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => eliminarHabitacion(habitacion.id),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
