import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener productos desde Firebase Firestore
  Stream<QuerySnapshot> getProducts() {
    return _db.collection('products').snapshots();
  }

  // Guardar un nuevo pedido en Firebase
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add(orderData);
  }

  // Registrar puntaje de juegos / torneos
  Future<void> saveScore(String tournamentId, Map<String, dynamic> scoreData) async {
    await _db.collection('tournaments').doc(tournamentId).collection('scores').add(scoreData);
  }
}
