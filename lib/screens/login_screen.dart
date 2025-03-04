import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) setState(() => loading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      User? user = userCredential.user;
      if (user != null) {
        print("🔹 UID autenticado: ${user.uid}");
        String? rol = await getUserRole(user.uid);

        if (rol == null) {
          print("⚠️ Usuario sin rol en Firestore, asignando como admin...");
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .set({
            'nombre': "Administrador",
            'email': user.email,
            'rol': "admin"
          }, SetOptions(merge: true));

          rol = "admin";
        }

        print("✅ Rol final asignado: $rol");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen(rol: rol!)),
          );
        }
      } else {
        throw Exception("Error al iniciar sesión.");
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        return data?['rol'];
      }
      return null;
    } catch (e) {
      print("❌ Error al obtener el rol del usuario: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar Sesión")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Correo electrónico"),
                validator: (value) => value == null || value.isEmpty
                    ? "El correo es obligatorio"
                    : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: (value) => value == null || value.length < 6
                    ? "Mínimo 6 caracteres"
                    : null,
              ),
              SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
              loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      child: Text("Iniciar Sesión"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
