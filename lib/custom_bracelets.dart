import 'package:flutter/material.dart';
import 'models.dart';
import 'services.dart';

class CustomBraceletsScreen extends StatefulWidget {
  const CustomBraceletsScreen({super.key});

  @override
  State<CustomBraceletsScreen> createState() => _CustomBraceletsScreenState();
}

class _CustomBraceletsScreenState extends State<CustomBraceletsScreen> {
  final List<CustomPaletteColor> _selectedColors = [];
  final GlobalKey _previewKey = GlobalKey();

  double get _calculatedPrice {
    if (_selectedColors.length == 1) return globalCustomPrice1Notifier.value;
    if (_selectedColors.length == 2) return globalCustomPrice2Notifier.value;
    if (_selectedColors.length >= 3) return globalCustomPrice3Notifier.value;
    return 0;
  }

  void _toggleColor(CustomPaletteColor colorItem) {
    setState(() {
      if (_selectedColors.any((c) => c.id == colorItem.id)) {
        _selectedColors.removeWhere((c) => c.id == colorItem.id);
      } else {
        if (_selectedColors.length < 3) {
          _selectedColors.add(colorItem);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Puedes elegir máximo 3 colores para tu manilla mágica! ✨')),
          );
        }
      }
    });
  }

  void _processAndAddBracelet(BuildContext context) {
    if (_selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor elige al menos 1 color para tu manilla')),
      );
      return;
    }

    String colorNames = _selectedColors.map((c) => c.name).join(' - ');
    String braceletId = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    ProductItem customProduct = ProductItem(
      id: braceletId,
      name: 'Manilla Personalizada (${_selectedColors.length} colores)',
      price: _calculatedPrice,
      desc: 'Diseño único: $colorNames',
      category: 'Personalizadas',
      color: _selectedColors.first.color,
    );

    playMagicChime();
    
    List<CartItem> currentCart = List.from(globalCartNotifier.value);
    currentCart.add(CartItem(product: customProduct, quantity: 1));
    globalCartNotifier.value = currentCart;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Manilla personalizada agregada al carrito con éxito! 🪄💖')),
    );

    setState(() {
      _selectedColors.clear();
    });
  }

  void _addCustomBraceletToCart(BuildContext context) {
    if (_selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor elige al menos 1 color para tu manilla')),
      );
      return;
    }

    // Validación inteligente de sesión: Si no está logueado, pide login antes de agregar
    if (globalActiveUserNotifier.value == null) {
      showLoginOrRegisterDialog(context, () {
        _processAndAddBracelet(context);
      });
    } else {
      _processAndAddBracelet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseña tu Manilla Mágica 🧶✨', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD85A7F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '¡Crea tu propia manilla combinando hasta 3 colores favoritos!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            // Precios dinámicos reflejados en el subtítulo
            ValueBuilderPricesInfo(),
            const SizedBox(height: 24),
            
            // Vista previa interactiva de la manilla
            Container(
              key: _previewKey,
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFF0F3), Color(0xFFFFE3E8)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD85A7F).withOpacity(0.3), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tu Diseño Mágico:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8B263E))),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _selectedColors.isEmpty
                        ? [const Text('Selecciona colores abajo 👇', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))]
                        : _selectedColors.map((c) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: c.color,
                                shape: BoxShape.circle,
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                                border: Border.all(color: c.color == Colors.white ? Colors.grey.shade300 : Colors.white, width: 3),
                              ),
                            )).toList(),
                  ),
                  const SizedBox(height: 14),
                  if (_selectedColors.isNotEmpty)
                    Text(
                      'Precio: ${formatCOP(_calculatedPrice)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFD85A7F)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Elige tus Colores Favoritos (Máximo 3):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
            ),
            const SizedBox(height: 12),

            // Selector de colores desde la paleta de Valentina
            ValueListenableBuilder<List<CustomPaletteColor>>(
              valueListenable: globalCustomPaletteNotifier,
              builder: (context, palette, child) {
                if (palette.isEmpty) {
                  return const Center(child: Text('Valentina aún no ha agregado colores a la paleta.'));
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: palette.length,
                  itemBuilder: (context, index) {
                    final colorItem = palette[index];
                    bool isSelected = _selectedColors.any((c) => c.id == colorItem.id);

                    return InkWell(
                      onTap: () => _toggleColor(colorItem),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD85A7F).withOpacity(0.15) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFD85A7F) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: colorItem.color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                colorItem.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFFD85A7F) : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD85A7F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedColors.isEmpty ? null : () => _addCustomBraceletToCart(context),
                icon: const Icon(Icons.shopping_bag, color: Colors.white),
                label: const Text('Agregar Manilla Personalizada al Carrito', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para renderizar los precios dinámicos configurados por Valentina
class ValueBuilderPricesInfo extends StatelessWidget {
  const ValueBuilderPricesInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: globalCustomPrice1Notifier,
      builder: (context, p1, child) {
        return ValueListenableBuilder<double>(
          valueListenable: globalCustomPrice2Notifier,
          builder: (context, p2, child) {
            return ValueListenableBuilder<double>(
              valueListenable: globalCustomPrice3Notifier,
              builder: (context, p3, child) {
                return Text(
                  'Precios: 1 color (${formatCOP(p1)}) | 2 colores (${formatCOP(p2)}) | 3 colores (${formatCOP(p3)})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                );
              },
            );
          },
        );
      },
    );
  }
}