import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'models.dart';

// --- Utilidades de Formato y Multimedia ---

String formatCOP(num amount) {
  final formatter = NumberFormat('#,##0', 'es_CO');
  return '\$ ${formatter.format(amount)}';
}

String formatTitleCase(String text) {
  if (text.isEmpty) return '';
  List<String> words = text.trim().toLowerCase().split(RegExp(r'\s+'));
  return words.map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

void playMagicChime() {
  try {
    js.context.callMethod('eval', [
      '''
      try {
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        if (AudioContext) {
          const ctx = new AudioContext();
          const now = ctx.currentTime;
          const freqs = [523.25, 659.25, 783.99, 1046.50, 1318.51];
          freqs.forEach((f, i) => {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(f, now + (i * 0.07));
            gain.gain.setValueAtTime(0.0, now + (i * 0.07));
            gain.gain.linearRampToValueAtTime(0.15, now + (i * 0.07) + 0.02);
            gain.gain.exponentialRampToValueAtTime(0.001, now + (i * 0.07) + 0.4);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(now + (i * 0.07));
            osc.stop(now + (i * 0.07) + 0.4);
          });
        }
      } catch(e) {}
      '''
    ]);
  } catch (_) {}
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    num value = num.parse(cleanText);
    final formatter = NumberFormat('#,##0', 'es_CO');
    String formatted = '\$ ${formatter.format(value)}';
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// --- Variables Globales y Notifiers ---

ValueNotifier<List<Tournament>> globalTournamentsNotifier = ValueNotifier([
  Tournament(
    id: '1',
    title: '🌟 Gran Torneo de Concentración Mágica 🌟',
    scores: [
      ScoreEntry(playerName: 'Valentina', timeInSeconds: 24.532, date: '02/09/2026'),
      ScoreEntry(playerName: 'Lucía', timeInSeconds: 31.021, date: '02/09/2026'),
    ],
  ),
  Tournament(
    id: '2',
    title: '🎨 Reto del Diseñador Mágico (Velocidad) 🎨',
    scores: [
      ScoreEntry(playerName: 'Valentina', timeInSeconds: 12.104, date: '02/09/2026'),
      ScoreEntry(playerName: 'Camila', timeInSeconds: 15.892, date: '02/09/2026'),
    ],
  ),
]);

ValueNotifier<List<ClientUser>> globalClientsDBNotifier = ValueNotifier([
  ClientUser(name: 'Valentina', whatsapp: '3001234567'),
]);

ValueNotifier<ClientUser?> globalActiveUserNotifier = ValueNotifier(null);

ValueNotifier<List<ProductItem>> globalProductsNotifier = ValueNotifier([
  ProductItem(id: 'manilla_unicornio', name: 'Manilla Unicornio', price: 3500, desc: 'Colores mágicos de unicornio', category: 'Manillas', color: Colors.purple[200]!),
  ProductItem(id: 'manilla_oceano', name: 'Manilla Océano', price: 3500, desc: 'Tonos azules del mar', category: 'Manillas', color: Colors.blue[300]!),
  ProductItem(id: 'manilla_candy', name: 'Manilla Candy', price: 3000, desc: 'Colores dulces de caramelo', category: 'Manillas', color: Colors.pink[200]!),
  ProductItem(id: 'anillo_estrella', name: 'Anillo Estrella', price: 2500, desc: 'Con brillo de estrella', category: 'Anillos', color: Colors.teal[200]!),
  ProductItem(id: 'manilla_princesa', name: 'Manilla Princesa', price: 4000, desc: 'Con dijes dorados', category: 'Manillas', color: Colors.amber[200]!),
  ProductItem(id: 'manilla_corazon', name: 'Manilla Corazón', price: 3500, desc: 'Diseño romántico', category: 'Manillas', color: Colors.red[200]!),
  ProductItem(id: 'anillo_diamante', name: 'Anillo Diamante', price: 3000, desc: 'Brillo deslumbrante', category: 'Anillos', color: Colors.indigo[200]!),
  ProductItem(id: 'manilla_arcoiris', name: 'Manilla Arcoíris', price: 4500, desc: 'Todos los colores', category: 'Manillas', color: Colors.orange[200]!),
  ProductItem(id: 'manilla_luna', name: 'Manilla Luna', price: 3500, desc: 'Estilo nocturno mágico', category: 'Manillas', color: Colors.blueGrey[200]!),
  ProductItem(id: 'anillo_corona', name: 'Anillo Corona', price: 3000, desc: 'Para pequeñas reinas', category: 'Anillos', color: Colors.deepPurple[200]!),
]);

ValueNotifier<List<PromoSlide>> globalPromosListNotifier = ValueNotifier([
  PromoSlide(title: '✨ ¡Super Promociones Mágicas! ✨', subtitle: '¡Lleva 2 manillas o accesorios y obtén un descuento especial!', color1: const Color(0xFFFF6B9D), color2: const Color(0xFFFFD93D), icon: Icons.local_offer),
  PromoSlide(title: '👑 ¡Combo Amigas por Siempre! 👑', subtitle: 'Compra 3 manillas a juego y llévate un brillo labial de regalo.', color1: const Color(0xFF4ECDC4), color2: const Color(0xFFFF6B9D), icon: Icons.card_giftcard),
  PromoSlide(title: '🌟 ¡Envío Mágico Gratis! 🌟', subtitle: 'En compras superiores a \$ 15.000 COP recibe entrega a domicilio.', color1: const Color(0xFF9D65C9), color2: const Color(0xFFFF6B9D), icon: Icons.local_shipping),
]);

ValueNotifier<List<SuggestionItem>> globalSuggestionsNotifier = ValueNotifier([
  SuggestionItem(
    id: '1',
    authorName: 'Camila',
    authorWhatsapp: '3109876543',
    date: '02/09/2026',
    message: '¡Me encantaría que hicieran una manilla con temática de Mariposas tornasol!',
    reply: '¡Hola Cami! Me encanta esa idea. Ya estoy buscando mostacillas con alas de mariposa para lanzarla pronto. ✨🦋',
    replyDate: '02/09/2026',
  ),
]);

ValueNotifier<String> globalLuzGreetingNotifier = ValueNotifier(
  'Hola. Soy Luz, asistente virtual de Manillas Mágicas. Estoy aquí para informarte sobre precios, disponibilidad de productos, métodos de compra y resolver tus dudas. ¿En qué te puedo ayudar hoy?',
);

ValueNotifier<List<CartItem>> globalCartNotifier = ValueNotifier([]);
ValueNotifier<List<OrderItem>> globalOrdersNotifier = ValueNotifier([]);
final GlobalKey cartIconKey = GlobalKey();

// --- Sincronización con Firebase Firestore (Resiliente y Web Compatible) ---

void initFirestoreSync() {
  try {
    FirebaseFirestore.instance.collection('products').snapshots().listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        for (var product in globalProductsNotifier.value) {
          await FirebaseFirestore.instance.collection('products').doc(product.id).set({
            'name': product.name,
            'price': product.price,
            'desc': product.desc,
            'category': product.category,
            'imageBase64': '',
          });
        }
      } else {
        List<ProductItem> cloudProducts = snapshot.docs.map((doc) {
          final data = doc.data();
          Uint8List? imgBytes;
          
          String rawBase64 = data['imageBase64'] ?? '';
          if (rawBase64.isNotEmpty) {
            try {
              String cleanBase64 = rawBase64.contains(',') ? rawBase64.split(',').last : rawBase64;
              imgBytes = base64Decode(cleanBase64);
            } catch (_) {}
          }

          if (imgBytes == null) {
            try {
              final existingProduct = globalProductsNotifier.value.firstWhere((p) => p.id == doc.id);
              imgBytes = existingProduct.imageBytes;
              if (imgBytes != null && rawBase64.isEmpty) {
                doc.reference.set({'imageBase64': base64Encode(imgBytes)}, SetOptions(merge: true));
              }
            } catch (_) {}
          }

          return ProductItem(
            id: doc.id,
            name: data['name'] ?? '',
            price: (data['price'] ?? 0).toDouble(),
            desc: data['desc'] ?? '',
            category: data['category'] ?? 'Accesorios',
            imageBytes: imgBytes,
            color: Colors.pink[200]!,
          );
        }).toList();
        
        globalProductsNotifier.value = cloudProducts;
      }
    });
  } catch (_) {
    // Captura segura genérica para evitar errores de tipo en JS
  }
}

// --- Diálogo Global de Identificación de Usuario ---

void showLoginOrRegisterDialog(BuildContext context, VoidCallback onSuccess) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController wppController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Identificación 🔑', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa tu nombre y WhatsApp para continuar:'),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Tu Nombre', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: wppController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'WhatsApp', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
          onPressed: () {
            final name = formatTitleCase(nameController.text);
            final wpp = wppController.text.trim();

            if (name.isEmpty || wpp.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor completa ambos campos')),
              );
              return;
            }

            final existingClientIndex = globalClientsDBNotifier.value.indexWhere(
              (c) => c.name.toLowerCase() == name.toLowerCase() && c.whatsapp == wpp,
            );

            if (existingClientIndex >= 0) {
              globalActiveUserNotifier.value = globalClientsDBNotifier.value[existingClientIndex];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Bienvenido(a), $name!')),
              );
            } else {
              final newClient = ClientUser(name: name, whatsapp: wpp);
              globalClientsDBNotifier.value = [...globalClientsDBNotifier.value, newClient];
              globalActiveUserNotifier.value = newClient;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Cuenta registrada con éxito, $name!')),
              );
            }

            playMagicChime();
            Navigator.pop(context);
            onSuccess();
          },
          child: const Text('Continuar 🚀', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}