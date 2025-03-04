import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarUsuarioScreen extends StatefulWidget {
  @override
  _AgregarUsuarioScreenState createState() => _AgregarUsuarioScreenState();
}

class _AgregarUsuarioScreenState extends State<AgregarUsuarioScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  String rolSeleccionado = "operador";
  bool loading = false;
  String mensajeError = '';

  Future<void> agregarUsuario() async {
    setState(() => loading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': nombreController.text.trim(),
        'email': emailController.text.trim(),
        'rol': rolSeleccionado,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario agregado correctamente")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => mensajeError = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agregar Usuario")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: "Nombre")),
            TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Correo electrónico")),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Contraseña"),
                obscureText: true),
            DropdownButton<String>(
              value: rolSeleccionado,
              onChanged: (value) {
                setState(() {
                  rolSeleccionado = value!;
                });
              },
              items: ["admin", "operador", "recepcionista"]
                  .map((rol) => DropdownMenuItem(value: rol, child: Text(rol)))
                  .toList(),
            ),
            SizedBox(height: 10),
            if (mensajeError.isNotEmpty)
              Text(mensajeError, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: agregarUsuario,
                    child: Text("Registrar Usuario"),
                  ),
          ],
        ),
      ),
    );
  }
}
