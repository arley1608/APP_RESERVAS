import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'usuarios_screen.dart';
import 'habitaciones_screen.dart';
import 'reservas_screen.dart';
import 'agregar_usuario_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String rol;

  DashboardScreen({required this.rol});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String nombreUsuario = "Cargando...";

  @override
  void initState() {
    super.initState();
    _obtenerNombreUsuario();
  }

  Future<void> _obtenerNombreUsuario() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          setState(() {
            nombreUsuario = snapshot['nombre'];
          });
        }
      }
    } catch (e) {
      print("❌ Error obteniendo el nombre del usuario: $e");
    }
  }

  void _cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreUsuario),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _cerrarSesion(context),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bienvenido, $nombreUsuario", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (widget.rol == "admin")
              Column(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.person_add),
                    label: Text("Agregar Usuario"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AgregarUsuarioScreen()),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.supervisor_account),
                    label: Text("Gestionar Usuarios"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UsuariosScreen()),
                      );
                    },
                  ),
                ],
              ),
            ElevatedButton.icon(
              icon: Icon(Icons.hotel),
              label: Text("Gestionar Habitaciones"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HabitacionesScreen(
                          rol: widget.rol)), // 🔹 Pasamos el rol aquí
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.book),
              label: Text("Gestionar Reservas"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservasScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
