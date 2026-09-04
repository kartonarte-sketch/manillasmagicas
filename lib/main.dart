import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_preview/device_preview.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const ManillasMagicasApp(),
    ),
  );
}

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
  String sender; // 'user' o 'luz'
  String text;
  String time;

  ChatMessage({required this.sender, required this.text, required this.time});
}

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
  ProductItem(id: '1', name: 'Manilla Unicornio', price: 3500, desc: 'Colores mágicos de unicornio', category: 'Manillas', color: Colors.purple[200]!),
  ProductItem(id: '2', name: 'Manilla Océano', price: 3500, desc: 'Tonos azules del mar', category: 'Manillas', color: Colors.blue[300]!),
  ProductItem(id: '3', name: 'Manilla Candy', price: 3000, desc: 'Colores dulces de caramelo', category: 'Manillas', color: Colors.pink[200]!),
  ProductItem(id: '4', name: 'Anillo Estrella', price: 2500, desc: 'Con brillo de estrella', category: 'Anillos', color: Colors.teal[200]!),
  ProductItem(id: '5', name: 'Manilla Princesa', price: 4000, desc: 'Con dijes dorados', category: 'Manillas', color: Colors.amber[200]!),
  ProductItem(id: '6', name: 'Manilla Corazón', price: 3500, desc: 'Diseño romántico', category: 'Manillas', color: Colors.red[200]!),
  ProductItem(id: '7', name: 'Anillo Diamante', price: 3000, desc: 'Brillo deslumbrante', category: 'Anillos', color: Colors.indigo[200]!),
  ProductItem(id: '8', name: 'Manilla Arcoíris', price: 4500, desc: 'Todos los colores', category: 'Manillas', color: Colors.orange[200]!),
  ProductItem(id: '9', name: 'Manilla Luna', price: 3500, desc: 'Estilo nocturno mágico', category: 'Manillas', color: Colors.blueGrey[200]!),
  ProductItem(id: '10', name: 'Anillo Corona', price: 3000, desc: 'Para pequeñas reinas', category: 'Anillos', color: Colors.deepPurple[200]!),
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
  '¡Hola princesa! 🌸 Soy Luz, la mejor amiga y asistente de Valentina en Manillas Mágicas. Estoy aquí para contarte de precios, ayudarte a elegir tu accesorio favorito o explicarte cómo pedir. ¿En qué te puedo asesorar hoy? ✨',
);

ValueNotifier<List<CartItem>> globalCartNotifier = ValueNotifier([]);
ValueNotifier<List<OrderItem>> globalOrdersNotifier = ValueNotifier([]);
final GlobalKey cartIconKey = GlobalKey();

class ManillasMagicasApp extends StatelessWidget {
  const ManillasMagicasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manillas Mágicas - Valentina',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CO'),
        Locale('es', 'ES'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF5F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD85A7F),
          primary: const Color(0xFFD85A7F),
          secondary: const Color(0xFF4ECDC4),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _wandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _wandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));
    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(CurvedAnimation(parent: _wandController, curve: Curves.easeInOut));
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => playMagicChime());
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainShopScreen()));
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _wandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D1B33), Color(0xFF5B3D6B), Color(0xFFFF6B9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) => Transform.rotate(angle: _rotationAnimation.value, child: child),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            boxShadow: [BoxShadow(color: const Color(0xFFFFD93D).withOpacity(0.7), blurRadius: 45, spreadRadius: 15)],
                          ),
                        ),
                        const Icon(Icons.auto_fix_high, size: 95, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text('Manillas Mágicas', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  const Text('by Valentina', style: TextStyle(color: Color(0xFFFFD93D), fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showLoginOrRegisterDialog(BuildContext context, VoidCallback onSuccess) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController wppController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Identificación Mágica 🔑', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa tu nombre y WhatsApp para verificar tu cuenta:'),
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
                SnackBar(content: Text('¡Bienvenida de nuevo, $name! ✨')),
              );
            } else {
              final newClient = ClientUser(name: name, whatsapp: wpp);
              globalClientsDBNotifier.value = [...globalClientsDBNotifier.value, newClient];
              globalActiveUserNotifier.value = newClient;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Cuenta creada y registrada en la base de datos, $name! 👑')),
              );
            }

            playMagicChime();
            Navigator.pop(context);
            onSuccess();
          },
          child: const Text('Ingresar 🚀', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class MainShopScreen extends StatefulWidget {
  const MainShopScreen({super.key});

  @override
  State<MainShopScreen> createState() => _MainShopScreenState();
}

class _MainShopScreenState extends State<MainShopScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 1 && globalActiveUserNotifier.value == null) {
      showLoginOrRegisterDialog(context, () {
        setState(() {
          _currentIndex = index;
        });
      });
      return;
    }

    if (index == 2 && globalActiveUserNotifier.value == null) {
      showLoginOrRegisterDialog(context, () {
        setState(() {
          _currentIndex = index;
        });
      });
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showPinDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Acceso Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el PIN de administrador:'),
            const SizedBox(height: 10),
            TextField(
              controller: pinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '****'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (pinController.text == '2024') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN incorrecto (Prueba 2024)')));
              }
            },
            child: const Text('Ingresar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [const ShopCatalogTab(), const ArcadeTab(), const CommunityHubTab()];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD85A7F),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(Icons.auto_fix_high, color: Color(0xFFFFD93D), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: ValueListenableBuilder<ClientUser?>(
                valueListenable: globalActiveUserNotifier,
                builder: (context, user, child) {
                  return Text(
                    user != null ? 'Hola, ${user.name} ✨' : 'Manillas Mágicas ✨',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<ClientUser?>(
            valueListenable: globalActiveUserNotifier,
            builder: (context, user, child) {
              if (user == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                tooltip: 'Cerrar sesión',
                onPressed: () => globalActiveUserNotifier.value = null,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Configuración',
            onPressed: () => _showPinDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 4.0),
            child: Center(
              child: SizedBox(
                key: cartIconKey,
                width: 44,
                height: 44,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _openCartModal(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 28,
                        color: Colors.white,
                      ),
                      Positioned(
                        right: -2,
                        top: 2,
                        child: ValueListenableBuilder<List<CartItem>>(
                          valueListenable: globalCartNotifier,
                          builder: (context, cartItems, child) {
                            final int totalCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
                            if (totalCount == 0) return const SizedBox.shrink();

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B263E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                '$totalCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: screens[_currentIndex > 2 ? 0 : _currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 2 ? 0 : _currentIndex,
        selectedItemColor: const Color(0xFFD85A7F),
        unselectedItemColor: const Color(0xFF4A3E5C),
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            activeIcon: Icon(Icons.store),
            label: 'Tienda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: 'Juegos',
          ),
          // Icono mágico y acogedor para la comunidad de niñas y creadoras
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Comunidad',
          ),
        ],
      ),
    );
  }
}

void runFlyToCartAnimation(BuildContext context, GlobalKey widgetKey, ProductItem product) {
  try {
    final RenderBox? renderBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox = cartIconKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || cartBox == null) return;

    final startPosition = renderBox.localToGlobal(Offset.zero);
    final endPosition = cartBox.localToGlobal(Offset.zero);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _FlyingItemWidget(
        start: startPosition,
        end: endPosition,
        product: product,
        onFinished: () {
          overlayEntry.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  } catch (_) {}
}

class _FlyingItemWidget extends StatefulWidget {
  final Offset start;
  final Offset end;
  final ProductItem product;
  final VoidCallback onFinished;

  const _FlyingItemWidget({required this.start, required this.end, required this.product, required this.onFinished});

  @override
  State<_FlyingItemWidget> createState() => _FlyingItemWidgetState();
}

class _FlyingItemWidgetState extends State<_FlyingItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _progressAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final currentX = widget.start.dx + (widget.end.dx - widget.start.dx) * _progressAnimation.value;
        final currentY = widget.start.dy + (widget.end.dy - widget.start.dy) * _progressAnimation.value - (50 * (1 - (_progressAnimation.value - 0.5).abs() * 2));
        final scale = 1.0 - (_progressAnimation.value * 0.7);

        return Positioned(
          left: currentX,
          top: currentY,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Transform.scale(
              scale: scale < 0.3 ? 0.3 : scale,
              child: Material(
                color: Colors.transparent,
                elevation: 8,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: widget.product.color,
                  backgroundImage: widget.product.imageBytes != null ? MemoryImage(widget.product.imageBytes!) : null,
                  child: widget.product.imageBytes == null ? const Icon(Icons.auto_awesome, color: Colors.white, size: 24) : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void addToCart(BuildContext context, GlobalKey widgetKey, ProductItem product) {
  playMagicChime();
  runFlyToCartAnimation(context, widgetKey, product);

  List<CartItem> currentCart = List.from(globalCartNotifier.value);
  int index = currentCart.indexWhere((item) => item.product.id == product.id);
  if (index >= 0) {
    currentCart[index].quantity++;
  } else {
    currentCart.add(CartItem(product: product, quantity: 1));
  }
  globalCartNotifier.value = currentCart;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('¡${product.name} agregado a la bolsa! ✨'), duration: const Duration(milliseconds: 1200)),
  );
}

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  void _showProductZoomInCart(BuildContext context, ProductItem product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 30, spreadRadius: 2, offset: Offset(0, 15))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: product.color,
                          child: product.imageBytes != null
                              ? Image.memory(product.imageBytes!, fit: BoxFit.cover, width: double.infinity)
                              : const Center(child: Icon(Icons.auto_awesome, size: 80, color: Colors.white)),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
                        const SizedBox(height: 6),
                        Text(product.desc, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(formatCOP(product.price), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFD85A7F))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _executeOrder(BuildContext context, List<CartItem> cartItems, double total) {
    final user = globalActiveUserNotifier.value;
    if (user == null) return;

    final name = user.name;
    final wpp = user.whatsapp;

    final randomNum = 1000 + Random().nextInt(9000);
    final orderCode = 'MM-$randomNum';

    final now = DateTime.now();
    final newOrder = OrderItem(
      orderCode: orderCode,
      clientName: name,
      clientWhatsapp: wpp,
      items: List.from(cartItems),
      total: total,
      dateTimeObj: now,
      date: DateFormat('dd/MM/yyyy HH:mm', 'es_CO').format(now),
      status: 'Pendiente',
    );

    globalOrdersNotifier.value = [newOrder, ...globalOrdersNotifier.value];
    globalCartNotifier.value = [];

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F7),
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: Color(0xFFD85A7F), size: 30),
            SizedBox(width: 8),
            Text('¡Felicidades!', style: TextStyle(color: Color(0xFF2D1B33), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '¡Bravo $name! 🎉 Has realizado una compra mágica con éxito.\n\nCódigo de tu pedido: $orderCode\n\n✨ ¡Gracias por apoyar las creaciones de Manillas Mágicas!',
          style: const TextStyle(fontSize: 15, color: Color(0xFF2D1B33)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Entendido!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context, List<CartItem> cartItems, double total) {
    if (globalActiveUserNotifier.value == null) {
      Navigator.pop(context);
      showLoginOrRegisterDialog(context, () {
        _executeOrder(context, cartItems, total);
      });
    } else {
      _executeOrder(context, cartItems, total);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tu Bolsa Mágica 🛍️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder<List<CartItem>>(
              valueListenable: globalCartNotifier,
              builder: (context, cartItems, child) {
                if (cartItems.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text('Tu bolsa está vacía. ¡Elige tus creaciones favoritas!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  );
                }

                double total = cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () => _showProductZoomInCart(context, item.product),
                              leading: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: item.product.color,
                                    backgroundImage: item.product.imageBytes != null ? MemoryImage(item.product.imageBytes!) : null,
                                    child: item.product.imageBytes == null ? const Icon(Icons.auto_awesome, color: Colors.white) : null,
                                  ),
                                  const Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.black54,
                                      child: Icon(Icons.zoom_in, size: 10, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(formatCOP(item.product.price)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                    onPressed: () {
                                      List<CartItem> list = List.from(globalCartNotifier.value);
                                      if (list[index].quantity > 1) {
                                        list[index].quantity--;
                                      } else {
                                        list.removeAt(index);
                                      }
                                      globalCartNotifier.value = list;
                                    },
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD85A7F)),
                                    onPressed: () {
                                      List<CartItem> list = List.from(globalCartNotifier.value);
                                      list[index].quantity++;
                                      globalCartNotifier.value = list;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(formatCOP(total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFD85A7F))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD85A7F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _processCheckout(context, cartItems, total),
                        child: const Text('Finalizar Pedido', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShopCatalogTab extends StatefulWidget {
  const ShopCatalogTab({super.key});

  @override
  State<ShopCatalogTab> createState() => _ShopCatalogTabState();
}

class _ShopCatalogTabState extends State<ShopCatalogTab> {
  String _selectedCategory = 'Todos';
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int next = _currentPage + 1;
        if (next >= globalPromosListNotifier.value.length) {
          next = 0;
        }
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProductItem>>(
      valueListenable: globalProductsNotifier,
      builder: (context, products, child) {
        final List<String> dynamicCategories = ['Todos'];
        for (var p in products) {
          if (!dynamicCategories.contains(p.category) && !p.category.startsWith('+')) {
            dynamicCategories.add(p.category);
          }
        }
        dynamicCategories.sort((a, b) => a == 'Todos' ? -1 : a.compareTo(b));

        if (!dynamicCategories.contains(_selectedCategory)) {
          _selectedCategory = 'Todos';
        }

        final filteredProducts = _selectedCategory == 'Todos'
            ? products
            : products.where((p) => p.category == _selectedCategory).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ValueListenableBuilder<List<PromoSlide>>(
              valueListenable: globalPromosListNotifier,
              builder: (context, promos, child) {
                return Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: promos.length,
                        itemBuilder: (context, index) {
                          final promo = promos[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [promo.color1, promo.color2],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(promo.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 6),
                                      Text(promo.subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                    ],
                                  ),
                                ),
                                Icon(promo.icon, size: 50, color: Colors.white),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        promos.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? const Color(0xFFD85A7F) : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Explora por Categorías', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dynamicCategories.length,
                itemBuilder: (context, index) => _buildCategoryChip(dynamicCategories[index]),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) => ProductCardWidget(product: filteredProducts[index]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        selectedColor: const Color(0xFFD85A7F),
        labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF2D1B33), fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        onSelected: (bool selected) => setState(() => _selectedCategory = category),
      ),
    );
  }
}

class ProductCardWidget extends StatefulWidget {
  final ProductItem product;
  const ProductCardWidget({super.key, required this.product});

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  bool _isHovered = false;
  final GlobalKey _cardKey = GlobalKey();

  void _showZoomDialog(BuildContext context, ProductItem product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 30, spreadRadius: 2, offset: Offset(0, 15))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: product.color,
                          child: product.imageBytes != null
                              ? Image.memory(product.imageBytes!, fit: BoxFit.cover, width: double.infinity)
                              : const Center(child: Icon(Icons.auto_awesome, size: 80, color: Colors.white)),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
                        const SizedBox(height: 6),
                        Text(product.desc, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(formatCOP(product.price), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFD85A7F))),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD85A7F),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            addToCart(context, _cardKey, product);
                          },
                          icon: const Icon(Icons.shopping_bag, color: Colors.white),
                          label: const Text('Agregar a la Bolsa', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      key: _cardKey,
      builder: (ctx) => GestureDetector(
        onTap: () => _showZoomDialog(context, widget.product),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(_isHovered ? 0.22 : 0.08), blurRadius: _isHovered ? 18 : 10, offset: Offset(0, _isHovered ? 8 : 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: AnimatedScale(
                          scale: _isHovered ? 1.12 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: widget.product.color),
                            child: widget.product.imageBytes != null
                                ? Image.memory(widget.product.imageBytes!, fit: BoxFit.cover, width: double.infinity)
                                : const Center(child: Icon(Icons.auto_awesome, size: 40, color: Colors.white)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                          child: const Icon(Icons.zoom_in, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(widget.product.desc, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatCOP(widget.product.price), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD85A7F))),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFFD85A7F)),
                            onPressed: () => addToCart(context, _cardKey, widget.product),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _adminTab = 0;
  String _trackingFilter = 'Todos';
  DateTime? _startDate;
  DateTime? _endDate;

  void _openPromoManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Gestión de Promociones 🎉', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 400,
              height: 350,
              child: ValueListenableBuilder<List<PromoSlide>>(
                valueListenable: globalPromosListNotifier,
                builder: (context, promos, child) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: promos.length,
                          itemBuilder: (context, index) {
                            final promo = promos[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(promo.icon, color: const Color(0xFFD85A7F)),
                                title: Text(promo.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(promo.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    List<PromoSlide> updated = List.from(globalPromosListNotifier.value);
                                    updated.removeAt(index);
                                    globalPromosListNotifier.value = updated;
                                    setStateDialog(() {});
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
                        onPressed: () {
                          _openAddPromoDialog(context, () {
                            setStateDialog(() {});
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Nueva Promoción', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4)),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddPromoDialog(BuildContext context, VoidCallback onAdded) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Promoción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título de la Promo', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: subtitleController, decoration: const InputDecoration(labelText: 'Descripción corta', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              final title = formatTitleCase(titleController.text);
              final subtitle = formatTitleCase(subtitleController.text);
              if (title.isNotEmpty) {
                List<PromoSlide> updated = List.from(globalPromosListNotifier.value);
                updated.add(PromoSlide(
                  title: title,
                  subtitle: subtitle.isEmpty ? '¡Descuento mágico especial!' : subtitle,
                  color1: const Color(0xFFD85A7F),
                  color2: const Color(0xFF4ECDC4),
                  icon: Icons.local_activity,
                ));
                globalPromosListNotifier.value = updated;
                onAdded();
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openCategoryManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final List<String> categories = [];
          for (var p in globalProductsNotifier.value) {
            if (!categories.contains(p.category)) {
              categories.add(p.category);
            }
          }
          categories.sort();

          return AlertDialog(
            title: const Text('Gestión de Categorías 🏷️', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 350,
              height: 300,
              child: categories.isEmpty
                  ? const Center(child: Text('No hay categorías registradas.'))
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.teal),
                                  tooltip: 'Renombrar categoría',
                                  onPressed: () {
                                    _openRenameCategoryDialog(context, cat, () {
                                      setStateDialog(() {});
                                      setState(() {});
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: 'Eliminar categoría',
                                  onPressed: () {
                                    _confirmDeleteCategory(context, cat, () {
                                      setStateDialog(() {});
                                      setState(() {});
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B9D)),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openRenameCategoryDialog(BuildContext context, String oldCategory, VoidCallback onUpdated) {
    final TextEditingController nameController = TextEditingController(text: oldCategory);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar Categoría'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nuevo nombre', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              final newCategory = formatTitleCase(nameController.text);
              if (newCategory.isNotEmpty && newCategory != oldCategory) {
                List<ProductItem> updatedList = List.from(globalProductsNotifier.value);
                for (var p in updatedList) {
                  if (p.category == oldCategory) {
                    p.category = newCategory;
                  }
                }
                globalProductsNotifier.value = updatedList;
                onUpdated();
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, String categoryToDelete, VoidCallback onDeleted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás segura de eliminar la categoría "$categoryToDelete"? Los productos asociados pasarán a la categoría "Accesorios".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              List<ProductItem> updatedList = List.from(globalProductsNotifier.value);
              for (var p in updatedList) {
                if (p.category == categoryToDelete) {
                  p.category = 'Accesorios';
                }
              }
              globalProductsNotifier.value = updatedList;
              onDeleted();
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openProductForm({ProductItem? productToEdit}) {
    final nameController = TextEditingController(text: productToEdit?.name ?? '');
    final priceController = TextEditingController(
      text: productToEdit != null ? '\$ ${NumberFormat('#,##0', 'es_CO').format(productToEdit.price)}' : '',
    );
    final descController = TextEditingController(text: productToEdit?.desc ?? '');
    
    final List<String> formCategories = [];
    for (var p in globalProductsNotifier.value) {
      if (!formCategories.contains(p.category)) {
        formCategories.add(p.category);
      }
    }
    formCategories.sort();
    formCategories.add('+ Otra (Escribir nueva)...');

    String initialCategory = productToEdit?.category ?? (formCategories.isNotEmpty ? formCategories.first : 'Accesorios');
    if (!formCategories.contains(initialCategory)) {
      initialCategory = formCategories.first;
    }

    String selectedDropdownCategory = initialCategory;
    final customCategoryController = TextEditingController();
    Uint8List? selectedImageBytes = productToEdit?.imageBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(productToEdit == null ? 'Nuevo Producto' : 'Editar Producto', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre del producto', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: const InputDecoration(labelText: 'Precio (\$ 3.500)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción corta', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                const Text('Categoría:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedDropdownCategory,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: formCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedDropdownCategory = val);
                  },
                ),
                if (selectedDropdownCategory == '+ Otra (Escribir nueva)...') ...[
                  const SizedBox(height: 10),
                  TextField(controller: customCategoryController, decoration: const InputDecoration(labelText: 'Nombre de la nueva categoría', border: OutlineInputBorder())),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setStateDialog(() => selectedImageBytes = bytes);
                          }
                        },
                        icon: const Icon(Icons.folder_open, color: Colors.white, size: 18),
                        label: const Text('Imagen', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    selectedImageBytes != null
                        ? const Text('¡Lista!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                        : const Text('Sin archivo', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD85A7F),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      final name = formatTitleCase(nameController.text);
                      String rawPrice = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final price = double.tryParse(rawPrice) ?? 0.0;
                      final desc = formatTitleCase(descController.text);
                      
                      String finalCategory = selectedDropdownCategory;
                      if (selectedDropdownCategory == '+ Otra (Escribir nueva)...') {
                        finalCategory = formatTitleCase(customCategoryController.text);
                        if (finalCategory.isEmpty) finalCategory = 'Accesorios';
                      }

                      if (name.isEmpty) return;

                      List<ProductItem> updatedList = List.from(globalProductsNotifier.value);
                      if (productToEdit == null) {
                        updatedList.add(ProductItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          price: price,
                          desc: desc.isEmpty ? 'Creación exclusiva' : desc,
                          category: finalCategory,
                          imageBytes: selectedImageBytes,
                          color: Colors.pink[200]!,
                        ));
                      } else {
                        productToEdit.name = name;
                        productToEdit.price = price;
                        productToEdit.desc = desc;
                        productToEdit.category = finalCategory;
                        productToEdit.imageBytes = selectedImageBytes;
                      }
                      globalProductsNotifier.value = updatedList;
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(ProductItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás segura de eliminar "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              List<ProductItem> updatedList = List.from(globalProductsNotifier.value);
              updatedList.remove(item);
              globalProductsNotifier.value = updatedList;
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreationsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.campaign, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Promociones',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  onPressed: () => _openPromoManager(context),
                  icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                  label: const Text('Gestionar Promos', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD85A7F),
                side: const BorderSide(color: Color(0xFFD85A7F)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _openCategoryManager(context),
              icon: const Icon(Icons.category),
              label: const Text('Gestionar Categorías', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Creaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD85A7F),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () => _openProductForm(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Nuevo', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder<List<ProductItem>>(
              valueListenable: globalProductsNotifier,
              builder: (context, products, child) {
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.color,
                          backgroundImage: item.imageBytes != null ? MemoryImage(item.imageBytes!) : null,
                          child: item.imageBytes == null ? const Icon(Icons.auto_awesome, color: Colors.white) : null,
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('[${item.category}] ${item.desc} - ${formatCOP(item.price)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () => _openProductForm(productToEdit: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteProduct(item),
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
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, OrderItem order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle Pedido ${order.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${order.clientName}'),
              Text('WhatsApp: ${order.clientWhatsapp}'),
              Text('Fecha del pedido: ${order.date}'),
              Text('Estado: ${order.status}', style: const TextStyle(color: Color(0xFFD85A7F), fontWeight: FontWeight.bold)),
              const Divider(),
              const Text('Productos solicitados:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.product.color,
                          backgroundImage: item.product.imageBytes != null ? MemoryImage(item.product.imageBytes!) : null,
                          child: item.product.imageBytes == null ? const Icon(Icons.auto_awesome, color: Colors.white) : null,
                        ),
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Cantidad: ${item.quantity}'),
                        trailing: Text(formatCOP(item.product.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD85A7F))),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatCOP(order.total), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD85A7F))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingView() {
    return ValueListenableBuilder<List<OrderItem>>(
      valueListenable: globalOrdersNotifier,
      builder: (context, orders, child) {
        final filteredOrders = _trackingFilter == 'Todos'
            ? orders
            : orders.where((o) => o.status == _trackingFilter).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD85A7F)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filtrar por Etapa:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
                    DropdownButton<String>(
                      value: _trackingFilter,
                      underline: const SizedBox.shrink(),
                      items: ['Todos', 'Pendiente', 'Preparación', 'Enviado', 'Entregado']
                          .map((stage) => DropdownMenuItem(value: stage, child: Text(stage, style: const TextStyle(fontWeight: FontWeight.bold))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _trackingFilter = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Center(child: Text('No hay pedidos en esta etapa.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showOrderDetailsDialog(context, order),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Pedido: ${order.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(order.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Cliente: ${order.clientName} (Wpp: ${order.clientWhatsapp})'),
                                    Text('Total: ${formatCOP(order.total)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F))),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Etapa del Pedido:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        DropdownButton<String>(
                                          value: order.status,
                                          items: ['Pendiente', 'Preparación', 'Enviado', 'Entregado']
                                              .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                              .toList(),
                                          onChanged: (newStatus) {
                                            if (newStatus != null) {
                                              setState(() {
                                                order.status = newStatus;
                                                globalOrdersNotifier.value = List.from(globalOrdersNotifier.value);
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsView() {
    return ValueListenableBuilder<List<OrderItem>>(
      valueListenable: globalOrdersNotifier,
      builder: (context, orders, child) {
        final filteredOrders = orders.where((o) {
          if (_startDate != null && o.dateTimeObj.isBefore(_startDate!)) return false;
          if (_endDate != null && o.dateTimeObj.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
          return true;
        }).toList();

        double totalSales = filteredOrders.fold(0, (sum, o) => sum + o.total);
        int totalOrdersCount = filteredOrders.length;

        Map<String, int> productSalesCount = {};
        Map<String, double> productSalesRevenue = {};
        Map<String, ProductItem> productCatalogMap = {};

        for (var p in globalProductsNotifier.value) {
          productCatalogMap[p.name] = p;
        }

        for (var order in filteredOrders) {
          for (var item in order.items) {
            productSalesCount.update(item.product.name, (val) => val + item.quantity, ifAbsent: () => item.quantity);
            productSalesRevenue.update(item.product.name, (val) => val + (item.product.price * item.quantity), ifAbsent: () => (item.product.price * item.quantity));
          }
        }

        var sortedProducts = productSalesCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtrar por Fechas 📅', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD85A7F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              DateTimeRange? picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2030),
                                locale: const Locale('es', 'CO'),
                                helpText: 'SELECCIONA EL PERIODO MÁGICO',
                                cancelText: 'Cancelar',
                                confirmText: 'Aceptar',
                                fieldStartLabelText: 'Fecha Inicio',
                                fieldEndLabelText: 'Fecha Fin',
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFFD85A7F),
                                        onPrimary: Colors.white,
                                        onSurface: Color(0xFF2D1B33),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  _startDate = picked.start;
                                  _endDate = picked.end;
                                });
                              }
                            },
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(
                              _startDate == null ? 'Elegir Rango' : '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_startDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            tooltip: 'Limpiar filtro',
                            onPressed: () => setState(() {
                              _startDate = null;
                              _endDate = null;
                            }),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Resumen Financiero 📊', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.pink[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Ventas Totales', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(formatCOP(totalSales), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFFD85A7F))),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.teal[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Pedidos', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('$totalOrdersCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.teal)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('🌟 Productos Más Vendidos e Ingresos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
            const SizedBox(height: 10),
            sortedProducts.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Aún no hay estadísticas para este periodo.')))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedProducts.length,
                    itemBuilder: (context, index) {
                      final entry = sortedProducts[index];
                      final prodName = entry.key;
                      final qty = entry.value;
                      final revenue = productSalesRevenue[prodName] ?? 0;
                      final prodObj = productCatalogMap[prodName];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: prodObj?.color ?? const Color(0xFFD85A7F),
                            backgroundImage: prodObj?.imageBytes != null ? MemoryImage(prodObj!.imageBytes!) : null,
                            child: prodObj?.imageBytes == null ? const Icon(Icons.auto_awesome, color: Colors.white) : null,
                          ),
                          title: Text(prodName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Cantidad vendida: $qty unidades'),
                          trailing: Text(formatCOP(revenue), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD85A7F), fontSize: 14)),
                        ),
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  void _openLuzGreetingEditor(BuildContext context) {
    final controller = TextEditingController(text: globalLuzGreetingNotifier.value);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Saludo de Luz ✨', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Escribe el mensaje de bienvenida de Luz...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                globalLuzGreetingNotifier.value = controller.text.trim();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Valentina 👑', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD85A7F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _adminTab = 0),
                  icon: Icon(Icons.store, color: _adminTab == 0 ? const Color(0xFFD85A7F) : Colors.grey),
                  label: Text('Creaciones', style: TextStyle(color: _adminTab == 0 ? const Color(0xFFD85A7F) : Colors.grey, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _adminTab = 1),
                  icon: Icon(Icons.local_shipping, color: _adminTab == 1 ? const Color(0xFFD85A7F) : Colors.grey),
                  label: Text('Seguimiento', style: TextStyle(color: _adminTab == 1 ? const Color(0xFFD85A7F) : Colors.grey, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _adminTab = 2),
                  icon: Icon(Icons.bar_chart, color: _adminTab == 2 ? const Color(0xFFD85A7F) : Colors.grey),
                  label: Text('Reportes', style: TextStyle(color: _adminTab == 2 ? const Color(0xFFD85A7F) : Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B6B9E),
                  side: const BorderSide(color: Color(0xFF8B6B9E)),
                ),
                onPressed: () => _openLuzGreetingEditor(context),
                icon: const Icon(Icons.smart_toy, size: 20),
                label: const Text('Personalizar Saludo de Luz ✨', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _adminTab == 0
                ? _buildCreationsView()
                : (_adminTab == 1
                    ? _buildTrackingView()
                    : _buildReportsView()),
          ),
        ],
      ),
    );
  }
}

class ArcadeTab extends StatefulWidget {
  const ArcadeTab({super.key});

  @override
  State<ArcadeTab> createState() => _ArcadeTabState();
}

class _ArcadeTabState extends State<ArcadeTab> {
  void _openTournamentManager(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Administrar Torneos 👑', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            height: 350,
            child: ValueListenableBuilder<List<Tournament>>(
              valueListenable: globalTournamentsNotifier,
              builder: (context, tournaments, child) {
                return Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Nuevo Torneo (Ej: Torneo Relámpago)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
                      onPressed: () {
                        final title = formatTitleCase(titleController.text);
                        if (title.isNotEmpty) {
                          List<Tournament> updated = List.from(globalTournamentsNotifier.value);
                          updated.add(Tournament(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            scores: [],
                          ));
                          globalTournamentsNotifier.value = updated;
                          titleController.clear();
                          setStateDialog(() {});
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Crear Torneo', style: TextStyle(color: Colors.white)),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: tournaments.length,
                        itemBuilder: (context, index) {
                          final t = tournaments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${t.scores.length} participantes registrados'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  List<Tournament> updated = List.from(globalTournamentsNotifier.value);
                                  updated.removeAt(index);
                                  globalTournamentsNotifier.value = updated;
                                  setStateDialog(() {});
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, VoidCallback gameLauncher) {
    final user = globalActiveUserNotifier.value;
    if (user == null) {
      showLoginOrRegisterDialog(context, () {
        gameLauncher();
      });
    } else {
      gameLauncher();
    }
  }

  void _showTournamentScoresDialog(BuildContext context, int tournamentIndex, String gameTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🏆 Tabla: $gameTitle', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F))),
        content: SizedBox(
          width: 400,
          height: 350,
          child: ValueListenableBuilder<List<Tournament>>(
            valueListenable: globalTournamentsNotifier,
            builder: (context, tournaments, child) {
              if (tournaments.length <= tournamentIndex) {
                return const Center(child: Text('Torneo no disponible.'));
              }
              final t = tournaments[tournamentIndex];
              t.scores.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));

              if (t.scores.isEmpty) {
                return const Center(child: Text('Aún no hay participantes registrados en este torneo. ¡Sé la primera en jugar!'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: t.scores.length,
                itemBuilder: (context, sIndex) {
                  final score = t.scores[sIndex];
                  String medal = sIndex == 0 ? '🥇' : (sIndex == 1 ? '🥈' : (sIndex == 2 ? '🥉' : '✨'));
                  return ListTile(
                    leading: Text(medal, style: const TextStyle(fontSize: 22)),
                    title: Text('${sIndex + 1}. ${score.playerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Fecha: ${score.date}'),
                    trailing: Text('${score.timeInSeconds.toStringAsFixed(3)} seg', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD85A7F), fontSize: 15)),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B9D)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🎮 Menú Arcade Mágico', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Color(0xFFD85A7F), size: 28),
              tooltip: 'Panel de Torneos',
              onPressed: () => _openTournamentManager(context),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('¡Selecciona un juego, consulta sus tablas o compite para ganar!', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD85A7F), Color(0xFFFFD93D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 32),
                    SizedBox(width: 10),
                    Text('Concentración Mágica', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Encuentra las 10 parejas de manillas y anillos en el menor tiempo posible.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFD85A7F)),
                        onPressed: () => _startGame(context, () => showDialog(context: context, barrierDismissible: false, builder: (context) => const MemoryGameDialog())),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Jugar 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                        onPressed: () => _showTournamentScoresDialog(context, 0, 'Concentración Mágica'),
                        icon: const Icon(Icons.leaderboard, size: 18),
                        label: const Text('Posiciones 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF63C7B2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.white, size: 32),
                    SizedBox(width: 10),
                    Text('Reto de Velocidad y Diseño', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Toca los productos pedidos en orden express para registrar el récord más rápido.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF2E8B82)),
                        onPressed: () => _startGame(context, () => showDialog(context: context, barrierDismissible: false, builder: (context) => const SpeedDesignGameDialog())),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Jugar ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                        onPressed: () => _showTournamentScoresDialog(context, 1, 'Reto del Diseñador'),
                        icon: const Icon(Icons.leaderboard, size: 18),
                        label: const Text('Posiciones 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MemoryGameDialog extends StatefulWidget {
  const MemoryGameDialog({super.key});

  @override
  State<MemoryGameDialog> createState() => _MemoryGameDialogState();
}

class _MemoryGameDialogState extends State<MemoryGameDialog> {
  List<_MemoryCard> _cards = [];
  int? _firstFlippedIndex;
  bool _isChecking = false;
  int _matchedPairs = 0;
  
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTimeString = '0.000';

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final products = globalProductsNotifier.value;
    List<ProductItem> pool = List.from(products);
    while (pool.length < 10) {
      pool.addAll(products);
    }
    pool = pool.take(10).toList();

    List<_MemoryCard> tempCards = [];
    for (var p in pool) {
      tempCards.add(_MemoryCard(product: p));
      tempCards.add(_MemoryCard(product: p));
    }
    tempCards.shuffle();
    _cards = tempCards;
    _matchedPairs = 0;
    _firstFlippedIndex = null;

    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          double elapsed = _stopwatch.elapsedMilliseconds / 1000.0;
          _elapsedTimeString = elapsed.toStringAsFixed(3);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _flipCard(int index) {
    if (_isChecking || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      int firstIndex = _firstFlippedIndex!;
      _firstFlippedIndex = null;

      if (_cards[firstIndex].product.id == _cards[index].product.id) {
        _cards[firstIndex].isMatched = true;
        _cards[index].isMatched = true;
        _matchedPairs++;
        playMagicChime();

        if (_matchedPairs == 10) {
          _stopwatch.stop();
          _timer?.cancel();
          _saveScore();
        }
      } else {
        _isChecking = true;
        Timer(const Duration(milliseconds: 700), () {
          setState(() {
            _cards[firstIndex].isFlipped = false;
            _cards[index].isFlipped = false;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _saveScore() {
    double finalSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
    final user = globalActiveUserNotifier.value;
    if (user == null) return;

    List<Tournament> tournaments = globalTournamentsNotifier.value;
    if (tournaments.isNotEmpty) {
      tournaments[0].scores.add(ScoreEntry(
        playerName: user.name,
        timeInSeconds: finalSeconds,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      ));
      globalTournamentsNotifier.value = List.from(tournaments);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F7),
        title: const Text('🎉 ¡Victoria Mágica! 🎉', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F))),
        content: Text('¡Bravo ${user.name}! Has completado las 10 parejas.\n\nTiempo total: ${_elapsedTimeString} segundos.\n\n✨ ¡Tu marca ha sido registrada en el torneo de Concentración!', style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('¡Genial!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '🧩 Concentración Mágica',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFD85A7F), size: 18),
                    const SizedBox(width: 4),
                    Text('$_elapsedTimeString s', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFFD85A7F))),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Text('Parejas encontradas: $_matchedPairs / 10', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  bool showFront = card.isFlipped || card.isMatched;

                  return GestureDetector(
                    onTap: () => _flipCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: showFront ? card.product.color : const Color(0xFFD85A7F),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Center(
                        child: showFront
                            ? (card.product.imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(card.product.imageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                                      const SizedBox(height: 4),
                                      Text(card.product.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), maxLines: 2),
                                    ],
                                  ))
                            : const Icon(Icons.star, color: Colors.white, size: 30),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard {
  ProductItem product;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({required this.product, this.isFlipped = false, this.isMatched = false});
}

class SpeedDesignGameDialog extends StatefulWidget {
  const SpeedDesignGameDialog({super.key});

  @override
  State<SpeedDesignGameDialog> createState() => _SpeedDesignGameDialogState();
}

class _SpeedDesignGameDialogState extends State<SpeedDesignGameDialog> {
  List<ProductItem> _targetSequence = [];
  int _currentIndexToFind = 0;
  List<ProductItem> _shuffledGrid = [];

  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTimeString = '0.000';
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final products = globalProductsNotifier.value;
    List<ProductItem> pool = List.from(products);
    pool.shuffle();
    
    _targetSequence = pool.take(6).toList();
    _currentIndexToFind = 0;
    _isGameOver = false;

    _shuffledGrid = List.from(_targetSequence);
    _shuffledGrid.shuffle();

    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted && !_isGameOver) {
        setState(() {
          double elapsed = _stopwatch.elapsedMilliseconds / 1000.0;
          _elapsedTimeString = elapsed.toStringAsFixed(3);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _onProductTap(ProductItem tappedProduct) {
    if (_isGameOver) return;

    if (tappedProduct.id == _targetSequence[_currentIndexToFind].id) {
      playMagicChime();
      setState(() {
        _currentIndexToFind++;
        if (_currentIndexToFind >= _targetSequence.length) {
          _isGameOver = true;
          _stopwatch.stop();
          _timer?.cancel();
          _saveScore();
        } else {
          _shuffledGrid.shuffle();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Ups! Ese no era. ¡Sigue el orden correcto! (+1.5s)'), duration: Duration(milliseconds: 600)),
      );
    }
  }

  void _saveScore() {
    double finalSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
    final user = globalActiveUserNotifier.value;
    if (user == null) return;

    List<Tournament> tournaments = globalTournamentsNotifier.value;
    if (tournaments.length > 1) {
      tournaments[1].scores.add(ScoreEntry(
        playerName: user.name,
        timeInSeconds: finalSeconds,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      ));
      globalTournamentsNotifier.value = List.from(tournaments);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F7),
        title: const Text('⚡ ¡Reto Superado! ⚡', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4ECDC4))),
        content: Text('¡Bravo ${user.name}! Completaste el diseño exprés.\n\nTiempo total: ${_elapsedTimeString} segundos.\n\n✨ ¡Tu marca ha sido registrada en el torneo de Velocidad!', style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4)),
            onPressed: () => {
              Navigator.pop(context),
              Navigator.pop(context),
            },
            child: const Text('¡Genial!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProductItem nextTarget = _currentIndexToFind < _targetSequence.length ? _targetSequence[_currentIndexToFind] : _targetSequence.last;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '⚡ Reto de Velocidad y Diseño',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Color(0xFF4ECDC4), size: 18),
                    const SizedBox(width: 4),
                    Text('$_elapsedTimeString s', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF4ECDC4))),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFF4ECDC4), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Busca el siguiente diseño:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('${nextTarget.name} (${_currentIndexToFind + 1} / ${_targetSequence.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _shuffledGrid.length,
                itemBuilder: (context, index) {
                  final product = _shuffledGrid[index];
                  return GestureDetector(
                    onTap: () => _onProductTap(product),
                    child: Container(
                      decoration: BoxDecoration(
                        color: product.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            product.imageBytes != null
                                ? Image.memory(product.imageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : const Center(child: Icon(Icons.auto_awesome, color: Colors.white, size: 36)),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                color: Colors.black.withOpacity(0.5),
                                child: Text(
                                  product.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              Tab(icon: Icon(Icons.mark_email_unread_outlined), text: 'Buzón de Deseos'),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Chat con Luz ✨'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              SuggestionsSubView(),
              LuzChatSubView(),
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
      const SnackBar(content: Text('¡Tu deseo o sugerencia mágica ha sido enviado a Valentina! ✨💌')),
    );
  }

  void _openReplyDialog(SuggestionItem sug) {
    final replyController = TextEditingController(text: sug.reply ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Responder a ${sug.authorName} 👑', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sugerencia: "${sug.message}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: replyController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Respuesta de Valentina', border: OutlineInputBorder()),
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
            child: const Text('Publicar Respuesta', style: TextStyle(color: Colors.white)),
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
                  Text('¿Tienes una idea o nuevo diseño para Valentina?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu sugerencia mágica aquí...',
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
                return const Center(child: Text('Sé la primera en dejar una sugerencia a Valentina ✨'));
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
                                      const Text('Valentina respondió:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFD85A7F))),
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
                              label: Text(s.reply == null ? 'Responder (Valentina)' : 'Editar respuesta', style: const TextStyle(fontSize: 11, color: Color(0xFF8B6B9E))),
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

    if (text.contains('precio') || text.contains('cuesta') || text.contains('vale')) {
      String sample = products.take(3).map((p) => '• ${p.name}: ${formatCOP(p.price)}').join('\n');
      return '¡Claro hermosa! Tenemos precios desde \$ 2.500 COP.\n\nAquí tienes algunos favoritos de Valentina:\n$sample\n\n¿Quieres que te busque alguno en especial? 💎';
    }

    if (text.contains('promo') || text.contains('descuento') || text.contains('combo') || text.contains('oferta')) {
      if (promos.isNotEmpty) {
        return '¡Sí, tenemos super promos mágicas hoy! 🎉\n\n"${promos.first.title}"\n${promos.first.subtitle}\n\n¡Aprovecha antes de que se agoten! ✨';
      }
      return '¡Lleva 2 o más manillas y recibes regalito mágico en tu pedido!';
    }

    if (text.contains('comprar') || text.contains('pedido') || text.contains('pagar') || text.contains('como pido')) {
      return '¡Es súper fácil! 🛍️ Ve a la pestaña de "Tienda", toca el botón rosa con el (+) en tu manilla o anillo favorito, y cuando estés lista, toca la bolsita mágica arriba para finalizar tu pedido.';
    }

    if (text.contains('manilla') || text.contains('anillo') || text.contains('pulsera')) {
      return 'Valentina diseña cada accesorio a mano con colores vivos, unicornios, estrellas y brillos. Puedes ver todos los estilos en la pestaña "Tienda" filtrando por categoría. 🦄✨';
    }

    if (text.contains('hola') || text.contains('buenas') || text.contains('luz')) {
      return '¡Hola hermosa! Qué alegría que me escribas. Valentina y yo estamos felices de que estés en Manillas Mágicas. ¿Qué te gustaría saber hoy? 🌟';
    }

    return '¡Qué linda pregunta! Como amiga de Valentina, te cuento que todas nuestras creaciones son 100% artesanales y mágicas. Puedes preguntarme por "precios", "promociones" o "cómo comprar" y te guiaré con gusto. 💕';
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
              Icon(Icons.face_3, color: Color(0xFFD85A7F), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text('Luz • Amiga y asistente oficial de Manillas Mágicas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4A3E5C))),
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
                            Text('Luz ✨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFD85A7F))),
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
                    hintText: 'Pregúntale a Luz sobre precios, promos...',
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