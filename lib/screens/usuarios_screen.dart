import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuariosScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> eliminarUsuario(String userId) async {
    try {
      await _db.collection('usuarios').doc(userId).delete();
      print("Usuario eliminado correctamente");
    } catch (e) {
      print("Error al eliminar usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestión de Usuarios")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var usuarios = snapshot.data!.docs;
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              var usuario = usuarios[index];
              return ListTile(
                title: Text(usuario['nombre']),
                subtitle: Text("${usuario['email']} - Rol: ${usuario['rol']}"),
                trailing: usuario['rol'] != "admin"
                    ? IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => eliminarUsuario(usuario.id),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
