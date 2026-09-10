import 'package:flutter/material.dart';
import 'dart:typed_data';

class ProductItem {
  String id;
  String name;
  double price;
  String desc;
  String category;
  Uint8List? imageBytes;
  Color color;

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.category,
    this.imageBytes,
    required this.color,
  });
}

class CartItem {
  ProductItem product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class OrderItem {
  String orderCode;
  String clientName;
  String clientWhatsapp;
  List<CartItem> items;
  double total;
  DateTime dateTimeObj;
  String date;
  String status;

  OrderItem({
    required this.orderCode,
    required this.clientName,
    required this.clientWhatsapp,
    required this.items,
    required this.total,
    required this.dateTimeObj,
    required this.date,
    this.status = 'Pendiente',
  });
}

class ClientUser {
  String name;
  String whatsapp;

  ClientUser({required this.name, required this.whatsapp});
}

class PromoSlide {
  String title;
  String subtitle;
  Color color1;
  Color color2;
  IconData icon;

  PromoSlide({
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.icon,
  });
}

class ScoreEntry {
  String playerName;
  double timeInSeconds;
  String date;

  ScoreEntry({required this.playerName, required this.timeInSeconds, required this.date});
}

class TournamentItem {
  String id;
  String gameName; // Nombre del juego seleccionado por Valentina
  String prize;    // Premio ofrecido por la administración
  String rules;    // Reglas del torneo
  DateTime startDate; // Fecha y hora de inicio
  DateTime endDate;   // Fecha y hora de finalización
  List<ScoreEntry> scores;

  TournamentItem({
    required this.id,
    required this.gameName,
    required this.prize,
    required this.rules,
    required this.startDate,
    required this.endDate,
    required this.scores,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameName': gameName,
    'prize': prize,
    'rules': rules,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'scores': scores.map((s) => {'playerName': s.playerName, 'timeInSeconds': s.timeInSeconds, 'date': s.date}).toList(),
  };

  factory TournamentItem.fromJson(Map<String, dynamic> json) => TournamentItem(
    id: json['id'] ?? '',
    gameName: json['gameName'] ?? '',
    prize: json['prize'] ?? '',
    rules: json['rules'] ?? '',
    startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now().add(const Duration(days: 1)),
    scores: (json['scores'] as List<dynamic>? ?? [])
        .map((s) => ScoreEntry(
              playerName: s['playerName'] ?? '',
              timeInSeconds: (s['timeInSeconds'] ?? 0.0).toDouble(),
              date: s['date'] ?? '',
            ))
        .toList(),
  );
}

// --- NUEVO MODELO PARA LA PALETA DE COLORES Y MANILLAS PERSONALIZADAS ---
class CustomPaletteColor {
  String id;
  String name;
  Color color;

  CustomPaletteColor({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': color.value,
  };

  factory CustomPaletteColor.fromJson(Map<String, dynamic> json) => CustomPaletteColor(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    color: Color(json['colorValue'] ?? 0xFF000000),
  );
}

class SuggestionItem {
  String id;
  String authorName;
  String authorWhatsapp;
  String date;
  String message;
  String? reply;
  String? replyDate;

  SuggestionItem({
    required this.id,
    required this.authorName,
    required this.authorWhatsapp,
    required this.date,
    required this.message,
    this.reply,
    this.replyDate,
  });
}

class ChatMessage {
  String sender;
  String text;
  String time;

  ChatMessage({required this.sender, required this.text, required this.time});
}