import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/habitaciones_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/agregar_usuario_screen.dart';
import 'screens/editar_habitacion_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); // 🔹 Asegura que Firebase esté inicializado antes de cargar la app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Reservas - AgroFinca San Felipe',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: AuthWrapper(),
      routes: {
        '/dashboard': (context) =>
            AuthWrapper(), // Verifica autenticación antes de ir al dashboard
        '/login': (context) => LoginScreen(),
        '/habitaciones': (context) =>
            HabitacionesScreen(rol: 'admin'), // Se cambiará dinámicamente
        '/usuarios': (context) => UsuariosScreen(),
        '/reservas': (context) => ReservasScreen(),
        '/agregar_usuario': (context) => AgregarUsuarioScreen(),
      },
    );
  }
}

// 🔹 Clase que verifica si el usuario está autenticado y obtiene su rol
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator())); // Pantalla de carga
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String?>(
            future: obtenerRolUsuario(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                    body: Center(
                        child: CircularProgressIndicator())); // Cargando rol
              }

              if (roleSnapshot.hasData && roleSnapshot.data != null) {
                return DashboardScreen(rol: roleSnapshot.data!);
              } else {
                return LoginScreen();
              }
            },
          );
        } else {
          return LoginScreen(); // Si no está autenticado, lo enviamos a la pantalla de login
        }
      },
    );
  }

  Future<String?> obtenerRolUsuario(String uid) async {
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
}
