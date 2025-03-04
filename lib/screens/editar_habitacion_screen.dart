import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarHabitacionScreen extends StatefulWidget {
  final String habitacionId;
  final String numero;
  final String tipo;
  final dynamic precio; // Puede venir como String o número

  EditarHabitacionScreen({
    required this.habitacionId,
    required this.numero,
    required this.tipo,
    required this.precio,
  });

  @override
  _EditarHabitacionScreenState createState() => _EditarHabitacionScreenState();
}

class _EditarHabitacionScreenState extends State<EditarHabitacionScreen> {
  late TextEditingController numeroController;
  late TextEditingController tipoController;
  late TextEditingController precioController;

  @override
  void initState() {
    super.initState();
    numeroController = TextEditingController(text: widget.numero);
    tipoController = TextEditingController(text: widget.tipo);

    // 🔹 Convertimos cualquier valor numérico a String asegurando que sea un número válido
    precioController = TextEditingController(text: widget.precio.toString());
  }

  Future<void> actualizarHabitacion() async {
    // 🔹 Convertimos el texto a double, manejando errores y reemplazando comas con puntos
    String precioTexto = precioController.text
        .replaceAll(',', '.'); // Manejo de formatos con coma
    double? nuevoPrecio =
        double.tryParse(precioTexto); // Intentamos convertirlo a double

    if (nuevoPrecio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Ingrese un precio válido")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('habitaciones')
        .doc(widget.habitacionId)
        .update({
      'numero': numeroController.text,
      'tipo': tipoController.text,
      'precio': nuevoPrecio, // 🔹 Guardamos el precio correctamente convertido
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Habitación")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
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
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: actualizarHabitacion,
              child: Text("Actualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
