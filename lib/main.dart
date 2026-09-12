import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'models.dart';
import 'services.dart';
import 'admin_panel.dart';
import 'arcade_games.dart';
import 'community.dart';
import 'custom_bracelets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  
  await loadShopSettings();
  runApp(const ManillasMagicasApp());
}

class ManillasMagicasApp extends StatelessWidget {
  const ManillasMagicasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manillas Mágicas - Valentina',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'CO'),
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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initFirestoreSync();

    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));
    
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => playMagicChime());
    
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainShopScreen()));
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Image.asset(
                  'assets/images/LogoManillasMagicas.png',
                  width: 280,
                  fit: BoxFit.contain,
                ),
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
            maxLength: 10,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'WhatsApp', border: OutlineInputBorder(), counterText: ''),
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

            if (wpp.length != 10 || int.tryParse(wpp) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚠️ Número de WhatsApp errado o no corresponde a un contacto válido.')),
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

void showOrderTrackingDialog(BuildContext context) {
  final TextEditingController wppController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('📦 Mis Pedidos Mágicos', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa tu número de WhatsApp para consultar el historial de tus compras:'),
          const SizedBox(height: 12),
          TextField(
            controller: wppController,
            maxLength: 10,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'WhatsApp (10 dígitos)', border: OutlineInputBorder(), counterText: ''),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
          onPressed: () {
            final wpp = wppController.text.trim();

            if (wpp.length != 10 || int.tryParse(wpp) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚠️ Número de WhatsApp errado o no corresponde a un contacto válido.')),
              );
              return;
            }

            Navigator.pop(context);
            _showOrderResultsModal(context, wpp);
          },
          child: const Text('Consultar 🔍', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _showOrderResultsModal(BuildContext context, String whatsapp) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Historial para: $whatsapp', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
      content: SizedBox(
        width: 450,
        height: 400,
        child: ValueListenableBuilder<List<OrderItem>>(
          valueListenable: globalOrdersNotifier,
          builder: (context, orders, child) {
            final clientOrders = orders.where((o) => o.clientWhatsapp == whatsapp).toList();

            if (clientOrders.isEmpty) {
              return const Center(
                child: Text(
                  'No encontramos pedidos registrados con este número de WhatsApp. ¡Anímate a pedir tus manillas favoritas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              );
            }

            return ListView.builder(
              itemCount: clientOrders.length,
              itemBuilder: (context, index) {
                final order = clientOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Código: ${order.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F))),
                            Chip(
                              backgroundColor: order.status == 'Pendiente' ? Colors.amber[100] : Colors.green[100],
                              label: Text(order.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: order.status == 'Pendiente' ? Colors.amber[800] : Colors.green[800])),
                            ),
                          ],
                        ),
                        Text('Fecha: ${order.date}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Divider(),
                        ...order.items.map((item) => Text('• ${item.product.name} (x${item.quantity})', style: const TextStyle(fontSize: 12))),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('Total: ${formatCOP(order.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF2D1B33))),
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

class MainShopScreen extends StatefulWidget {
  const MainShopScreen({super.key});

  @override
  State<MainShopScreen> createState() => _MainShopScreenState();
}

class _MainShopScreenState extends State<MainShopScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initFirestoreSync();
  }

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
              if (verifyAdminPin(pinController.text)) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN incorrecto. Inténtalo de nuevo.')));
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
        titleSpacing: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Manillas Mágicas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Botón en pastilla translúcida con el icono de la caja y texto blanco contrastado
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.25),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.local_shipping, color: Colors.white, size: 18),
            label: const Text(
              'Mis Pedidos',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            onPressed: () => showOrderTrackingDialog(context),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 20),
            tooltip: 'Configuración',
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(),
            onPressed: () => _showPinDialog(context),
          ),
          const SizedBox(width: 4),
          Center(
            child: SizedBox(
              key: cartIconKey,
              width: 38,
              height: 38,
              child: InkWell(
                borderRadius: BorderRadius.circular(19),
                onTap: () => _openCartModal(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      size: 24,
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
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B263E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '$totalCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
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
          const SizedBox(width: 8),
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
    SnackBar(content: Text('${product.name} agregado al carrito'), duration: const Duration(milliseconds: 1200)),
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

  void _executeOrder(BuildContext context, List<CartItem> cartItems, total) {
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
            Icon(Icons.check_circle, color: Color(0xFFD85A7F), size: 30),
            SizedBox(width: 8),
            Text('Pedido Realizado', style: TextStyle(color: Color(0xFF2D1B33), fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Su pedido ha sido registrado con éxito, $name.\n\nCódigo de pedido: $orderCode\n\nGracias por su compra en Manillas Mágicas.',
          style: const TextStyle(fontSize: 15, color: Color(0xFF2D1B33)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
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
              const Text('Carrito de Compras 🛍️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
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
                      child: Text('Su carrito está vacío. Agregue productos para continuar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                        child: const Text('Realizar Pedido', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_pageController.hasClients && !_isPaused) {
        int next = _currentPage + 1;
        if (next >= globalPromosListNotifier.value.length) {
          next = 0;
        }
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
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
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomBraceletsScreen()),
                  );
                },
                icon: const Icon(Icons.palette_rounded, size: 24),
                label: const Text(
                  '✨ ¡Diseña tu Propia Manilla Personalizada! ✨',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            ValueListenableBuilder<List<PromoSlide>>(
              valueListenable: globalPromosListNotifier,
              builder: (context, promos, child) {
                return MouseRegion(
                  onEnter: (_) => setState(() => _isPaused = true),
                  onExit: (_) => setState(() => _isPaused = false),
                  child: Column(
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
                                  Icon(promo.icon, size: 40, color: Colors.white),
                                  const SizedBox(width: 12),
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
                                  const SizedBox(width: 8),
                                  const Icon(Icons.auto_awesome, size: 40, color: Colors.white),
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
                          (index) => InkWell(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: _currentPage == index ? 20 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentPage == index ? const Color(0xFFD85A7F) : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      const SizedBox(height: 12),
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
