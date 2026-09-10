import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'models.dart';
import 'services.dart';

class CommunityHubTab extends StatefulWidget {
  const CommunityHubTab({super.key});

  @override
  State<CommunityHubTab> createState() => _CommunityHubTabState();
}

class _CommunityHubTabState extends State<CommunityHubTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFD85A7F),
            labelColor: const Color(0xFFD85A7F),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(icon: Icon(Icons.auto_awesome), text: 'Asistente Virtual'),
              Tab(icon: Icon(Icons.mark_email_unread_outlined), text: 'Buzón de Deseos'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              LuzChatSubView(),
              SuggestionsSubView(),
            ],
          ),
        ),
      ],
    );
  }
}

class SuggestionsSubView extends StatefulWidget {
  const SuggestionsSubView({super.key});

  @override
  State<SuggestionsSubView> createState() => _SuggestionsSubViewState();
}

class _SuggestionsSubViewState extends State<SuggestionsSubView> {
  final TextEditingController _msgController = TextEditingController();

  void _sendSuggestion() {
    final user = globalActiveUserNotifier.value;
    if (user == null) {
      showLoginOrRegisterDialog(context, _sendSuggestion);
      return;
    }

    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final newSug = SuggestionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: user.name,
      authorWhatsapp: user.whatsapp,
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      message: text,
    );

    globalSuggestionsNotifier.value = [newSug, ...globalSuggestionsNotifier.value];
    _msgController.clear();
    playMagicChime();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Su sugerencia ha sido enviada correctamente')),
    );
  }

  void _openReplyDialog(SuggestionItem sug) {
    final replyController = TextEditingController(text: sug.reply ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Responder a ${sug.authorName}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sugerencia: "${sug.message}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: replyController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Respuesta oficial', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                sug.reply = replyController.text.trim();
                sug.replyDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
                globalSuggestionsNotifier.value = List.from(globalSuggestionsNotifier.value);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFF5F7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note, color: Color(0xFFD85A7F)),
                  SizedBox(width: 8),
                  Text('¿Tiene alguna sugerencia o idea de diseño?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Escriba su sugerencia aquí...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD85A7F),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _sendSuggestion,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ValueListenableBuilder<List<SuggestionItem>>(
            valueListenable: globalSuggestionsNotifier,
            builder: (context, suggestions, child) {
              if (suggestions.isEmpty) {
                return const Center(child: Text('No hay sugerencias registradas.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final s = suggestions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFFD85A7F).withOpacity(0.2),
                                    child: Text(s.authorName.isNotEmpty ? s.authorName[0] : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F), fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(s.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              Text(s.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(s.message, style: const TextStyle(fontSize: 13, color: Color(0xFF2D1B33))),
                          if (s.reply != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEF3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFCCD9)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.verified, color: Color(0xFFD85A7F), size: 16),
                                      const SizedBox(width: 6),
                                      const Text('Respuesta oficial:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFD85A7F))),
                                      const Spacer(),
                                      if (s.replyDate != null) Text(s.replyDate!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(s.reply!, style: const TextStyle(fontSize: 12.5, color: Color(0xFF333333))),
                                ],
                              ),
                            ),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _openReplyDialog(s),
                              icon: const Icon(Icons.reply, size: 16, color: Color(0xFF8B6B9E)),
                              label: Text(s.reply == null ? 'Responder' : 'Editar respuesta', style: const TextStyle(fontSize: 11, color: Color(0xFF8B6B9E))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class LuzChatSubView extends StatefulWidget {
  const LuzChatSubView({super.key});

  @override
  State<LuzChatSubView> createState() => _LuzChatSubViewState();
}

class _LuzChatSubViewState extends State<LuzChatSubView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      sender: 'luz',
      text: globalLuzGreetingNotifier.value,
      time: DateFormat('HH:mm').format(DateTime.now()),
    ));
  }

  void _sendMessage() {
    final query = _inputController.text.trim();
    if (query.isEmpty) return;

    final time = DateFormat('HH:mm').format(DateTime.now());
    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: query, time: time));
      _inputController.clear();
    });

    _scrollToBottom();

    Timer(const Duration(milliseconds: 600), () {
      final responseText = _generateLuzResponse(query.toLowerCase());
      playMagicChime();
      setState(() {
        _messages.add(ChatMessage(sender: 'luz', text: responseText, time: DateFormat('HH:mm').format(DateTime.now())));
      });
      _scrollToBottom();
    });
  }

  String _generateLuzResponse(String text) {
    final products = globalProductsNotifier.value;
    final promos = globalPromosListNotifier.value;

    for (var p in products) {
      if (text.contains(p.name.toLowerCase())) {
        return 'El producto "${p.name}" tiene un precio de ${formatCOP(p.price)}. Descripción: ${p.desc}. Categoría: ${p.category}.';
      }
    }

    if (text.contains('valentina') || text.contains('edad') || text.contains('cuantos años') || text.contains('creadora')) {
      return 'Valentina es la creadora y diseñadora principal de Manillas Mágicas. Tiene 10 años y elabora cada accesorio de manera artesanal.';
    }

    if (text.contains('precio') || text.contains('cuesta') || text.contains('vale')) {
      String sample = products.take(4).map((p) => '• ${p.name}: ${formatCOP(p.price)}').join('\n');
      return 'Tenemos precios desde \$ 2.500 COP. Algunos de nuestros productos disponibles:\n$sample';
    }

    if (text.contains('promo') || text.contains('descuento') || text.contains('combo') || text.contains('oferta')) {
      if (promos.isNotEmpty) {
        return 'Promoción vigente:\n\n"${promos.first.title}"\n${promos.first.subtitle}';
      }
      return 'Por compras de 2 o más manillas obtienes un beneficio especial.';
    }

    if (text.contains('comprar') || text.contains('pedido') || text.contains('pagar') || text.contains('como pido')) {
      return 'Para realizar un pedido, ingrese a la pestaña "Tienda", seleccione sus accesorios agregándolos al carrito y presione el botón de finalizar pedido.';
    }

    if (text.contains('manilla') || text.contains('anillo') || text.contains('pulsera')) {
      return 'Disponemos de una amplia variedad de manillas y anillos artesanales. Puede consultar todo el catálogo directamente en la sección "Tienda".';
    }

    if (text.contains('hola') || text.contains('buenas') || text.contains('luz')) {
      return 'Hola. ¿En qué le puedo colaborar hoy respecto a nuestros productos o pedidos?';
    }

    return 'Entendido. Puede consultarme sobre precios específicos de productos, promociones vigentes o el proceso de compra.';
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.amber[50],
          child: const Row(
            children: [
              Icon(Icons.support_agent, color: Color(0xFFD85A7F), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text('Asistente Virtual • Manillas Mágicas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A3E5C))),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(14),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              bool isLuz = msg.sender == 'luz';

              return Align(
                alignment: isLuz ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isLuz ? Colors.white : const Color(0xFFD85A7F),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isLuz ? const Radius.circular(0) : const Radius.circular(16),
                      bottomRight: !isLuz ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLuz) ...[
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Asistente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFD85A7F))),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(msg.text, style: TextStyle(color: isLuz ? const Color(0xFF2D1B33) : Colors.white, fontSize: 13)),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(msg.time, style: TextStyle(fontSize: 9, color: isLuz ? Colors.grey : Colors.white70)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Escriba su consulta aquí...',
                    hintStyle: const TextStyle(fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFFFFF5F7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFFD85A7F),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}