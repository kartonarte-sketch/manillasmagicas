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

class Tournament {
  String id;
  String title;
  List<ScoreEntry> scores;

  Tournament({required this.id, required this.title, required this.scores});
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