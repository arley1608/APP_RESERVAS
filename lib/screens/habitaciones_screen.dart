import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_habitacion_screen.dart';

class HabitacionesScreen extends StatelessWidget {
  final String rol;

  HabitacionesScreen({required this.rol});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> agregarHabitacion(
      String numero, String tipo, double precio) async {
    await _db.collection('habitaciones').add(
        {'numero': numero, 'tipo': tipo, 'precio': precio, 'disponible': true});
  }

  Future<void> eliminarHabitacion(String id) async {
    await _db.collection('habitaciones').doc(id).delete();
  }

  void _mostrarFormulario(BuildContext context) {
    TextEditingController numeroController = TextEditingController();
    TextEditingController tipoController = TextEditingController();
    TextEditingController precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Agregar Habitación"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: numeroController,
                decoration: InputDecoration(labelText: "Número")),
            TextField(
                controller: tipoController,
                decoration: InputDecoration(labelText: "Tipo")),
            TextField(
                controller: precioController,
                decoration: InputDecoration(labelText: "Precio"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Guardar"),
            onPressed: () {
              double? precio =
                  double.tryParse(precioController.text.replaceAll(',', '.'));
              if (precio == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("⚠️ Ingrese un precio válido")),
                );
                return;
              }
              agregarHabitacion(
                numeroController.text,
                tipoController.text,
                precio,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
                                precio: double.tryParse(
                                        habitacion['precio'].toString()) ??
                                    0.0, // 🔹 Conversión segura
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
      floatingActionButton: rol == "admin"
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _mostrarFormulario(context),
            )
          : null, // 🔹 Solo el admin puede agregar habitaciones
    );
  }
}
