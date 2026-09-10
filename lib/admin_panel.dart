import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';
import 'services.dart';

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
            title: const Text('Gestión de Promociones ✨', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 450,
              height: 450,
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.teal),
                                      tooltip: 'Editar promoción',
                                      onPressed: () {
                                        _openPromoForm(context, promoToEdit: promo, editIndex: index, onSaved: () {
                                          setStateDialog(() {});
                                          setState(() {});
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: 'Eliminar promoción',
                                      onPressed: () {
                                        List<PromoSlide> updated = List.from(globalPromosListNotifier.value);
                                        updated.removeAt(index);
                                        globalPromosListNotifier.value = updated;
                                        setStateDialog(() {});
                                        setState(() {});
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
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
                        onPressed: () {
                          _openPromoForm(context, onSaved: () {
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

  void _openPromoForm(BuildContext context, {PromoSlide? promoToEdit, int? editIndex, required VoidCallback onSaved}) {
    final titleController = TextEditingController(text: promoToEdit?.title ?? '');
    final subtitleController = TextEditingController(text: promoToEdit?.subtitle ?? '');

    final List<Map<String, dynamic>> availableIcons = [
      {'name': 'Corona', 'icon': Icons.emoji_events},
      {'name': 'Magia', 'icon': Icons.auto_awesome},
      {'name': 'Estrella', 'icon': Icons.star},
      {'name': 'Corazón', 'icon': Icons.favorite},
      {'name': 'Regalo', 'icon': Icons.card_giftcard},
      {'name': 'Diamante', 'icon': Icons.diamond},
      {'name': 'Oferta', 'icon': Icons.local_offer},
      {'name': 'Envío', 'icon': Icons.local_shipping},
      {'name': 'Fiesta', 'icon': Icons.celebration},
      {'name': 'Descuento', 'icon': Icons.discount},
    ];

    IconData selectedStartIcon = promoToEdit?.icon ?? Icons.emoji_events;
    IconData selectedEndIcon = promoToEdit?.icon ?? Icons.auto_awesome;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(promoToEdit == null ? 'Nueva Promoción' : 'Editar Promoción', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            height: 720,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleController,
                    textAlign: TextAlign.justify,
                    decoration: const InputDecoration(labelText: 'Título de la Promo', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subtitleController,
                    textAlign: TextAlign.justify,
                    decoration: const InputDecoration(labelText: 'Descripción corta', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Icono Inicial (Izquierda):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 120,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final item = availableIcons[index];
                        IconData iconData = item['icon'];
                        bool isSelected = selectedStartIcon == iconData;

                        return InkWell(
                          onTap: () => setStateDialog(() => selectedStartIcon = iconData),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFD85A7F).withOpacity(0.2) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? const Color(0xFFD85A7F) : Colors.transparent, width: 2),
                            ),
                            child: Icon(iconData, color: isSelected ? const Color(0xFFD85A7F) : Colors.black54, size: 24),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Icono Final (Derecha):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 120,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final item = availableIcons[index];
                        IconData iconData = item['icon'];
                        bool isSelected = selectedEndIcon == iconData;

                        return InkWell(
                          onTap: () => setStateDialog(() => selectedEndIcon = iconData),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF4ECDC4).withOpacity(0.2) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? const Color(0xFF4ECDC4) : Colors.transparent, width: 2),
                            ),
                            child: Icon(iconData, color: isSelected ? const Color(0xFF4ECDC4) : Colors.black54, size: 24),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                  if (promoToEdit == null) {
                    updated.add(PromoSlide(
                      title: title,
                      subtitle: subtitle.isEmpty ? '¡Descuento especial!' : subtitle,
                      color1: const Color(0xFFD85A7F),
                      color2: const Color(0xFF4ECDC4),
                      icon: selectedEndIcon,
                    ));
                  } else if (editIndex != null) {
                    updated[editIndex] = PromoSlide(
                      title: title,
                      subtitle: subtitle.isEmpty ? '¡Descuento especial!' : subtitle,
                      color1: promoToEdit.color1,
                      color2: promoToEdit.color2,
                      icon: selectedEndIcon,
                    );
                  }
                  globalPromosListNotifier.value = updated;
                  onSaved();
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
          textAlign: TextAlign.justify,
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
        content: Text(
          '¿Desea eliminar la categoría "$categoryToDelete"? Los productos asociados pasarán a la categoría "Accesorios".',
          textAlign: TextAlign.justify,
        ),
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

  // --- GESTIÓN DE LA PALETA DE COLORES PERSONALIZADOS Y PRECIOS ---
  void _openPaletteManager(BuildContext context) {
    final price1Controller = TextEditingController(text: NumberFormat('#,##0', 'es_CO').format(globalCustomPrice1Notifier.value));
    final price2Controller = TextEditingController(text: NumberFormat('#,##0', 'es_CO').format(globalCustomPrice2Notifier.value));
    final price3Controller = TextEditingController(text: NumberFormat('#,##0', 'es_CO').format(globalCustomPrice3Notifier.value));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Gestión de Paleta y Precios 🎨', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 460,
              height: 520,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD85A7F),
                        side: const BorderSide(color: Color(0xFFD85A7F), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openChangePinDialog(context),
                      icon: const Icon(Icons.lock_reset, size: 22),
                      label: const Text('Cambiar PIN de Admin 🔒', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.pink.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Precios de Manillas Personalizadas 💰', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D1B33))),
                          const SizedBox(height: 10),
                          TextField(
                            controller: price1Controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: const InputDecoration(labelText: 'Precio 1 Color', border: OutlineInputBorder(), isDense: true),
                            onChanged: (val) {
                              String raw = val.replaceAll(RegExp(r'[^0-9]'), '');
                              globalCustomPrice1Notifier.value = double.tryParse(raw) ?? globalCustomPrice1Notifier.value;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: price2Controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: const InputDecoration(labelText: 'Precio 2 Colores', border: OutlineInputBorder(), isDense: true),
                            onChanged: (val) {
                              String raw = val.replaceAll(RegExp(r'[^0-9]'), '');
                              globalCustomPrice2Notifier.value = double.tryParse(raw) ?? globalCustomPrice2Notifier.value;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: price3Controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: const InputDecoration(labelText: 'Precio 3 Colores', border: OutlineInputBorder(), isDense: true),
                            onChanged: (val) {
                              String raw = val.replaceAll(RegExp(r'[^0-9]'), '');
                              globalCustomPrice3Notifier.value = double.tryParse(raw) ?? globalCustomPrice3Notifier.value;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Colores Disponibles en la Paleta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<List<CustomPaletteColor>>(
                      valueListenable: globalCustomPaletteNotifier,
                      builder: (context, paletteColors, child) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paletteColors.length,
                          itemBuilder: (context, index) {
                            final item = paletteColors[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black26),
                                  ),
                                ),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.teal, size: 20),
                                      onPressed: () {
                                        _openColorForm(context, colorToEdit: item, editIndex: index, onSaved: () {
                                          setStateDialog(() {});
                                          setState(() {});
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        List<CustomPaletteColor> updated = List.from(globalCustomPaletteNotifier.value);
                                        updated.removeAt(index);
                                        globalCustomPaletteNotifier.value = updated;
                                        setStateDialog(() {});
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
                      onPressed: () {
                        _openColorForm(context, onSaved: () {
                          setStateDialog(() {});
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Agregar Nuevo Color', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
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

  void _openColorForm(BuildContext context, {CustomPaletteColor? colorToEdit, int? editIndex, required VoidCallback onSaved}) {
    final nameController = TextEditingController(text: colorToEdit?.name ?? '');
    Color selectedColor = colorToEdit?.color ?? Colors.pinkAccent;

    final List<Color> colorSpectrum = [
      Colors.black, Colors.white, Colors.grey, Colors.brown,
      Colors.red, Colors.redAccent, Colors.deepOrange, Colors.orange,
      Colors.amber, Colors.yellow, Colors.lime, Colors.lightGreen,
      Colors.green, Colors.teal, Colors.cyan, Colors.lightBlue,
      Colors.blue, Colors.indigo, Colors.purple, Colors.purpleAccent,
      Colors.pink, Colors.pinkAccent, const Color(0xFFFFD700), const Color(0xFFE6E6FA),
      Colors.blueGrey, Colors.deepPurple, Colors.cyanAccent, Colors.greenAccent,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(colorToEdit == null ? 'Nuevo Color' : 'Editar Color', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 440,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Tono (ej. Rosado Brillante)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('1. Elige un color de la escala mágica:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: colorSpectrum.length,
                        itemBuilder: (context, index) {
                          final colorVal = colorSpectrum[index];
                          bool isSelected = selectedColor.value == colorVal.value;

                          return InkWell(
                            onTap: () {
                              setStateDialog(() {
                                selectedColor = colorVal;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorVal,
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? const Color(0xFFD85A7F) : Colors.black26, width: isSelected ? 3 : 1),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))],
                              ),
                              child: isSelected ? Icon(Icons.check, color: colorVal == Colors.white ? Colors.black : Colors.white, size: 18) : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Tono seleccionado: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
              onPressed: () {
                final name = formatTitleCase(nameController.text);
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor escribe un nombre para el color')));
                  return;
                }

                List<CustomPaletteColor> updated = List.from(globalCustomPaletteNotifier.value);
                if (colorToEdit == null) {
                  updated.add(CustomPaletteColor(
                    id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    color: selectedColor,
                  ));
                } else if (editIndex != null) {
                  updated[editIndex] = CustomPaletteColor(
                    id: colorToEdit.id,
                    name: name,
                    color: selectedColor,
                  );
                }
                globalCustomPaletteNotifier.value = updated;
                onSaved();
                Navigator.pop(context);
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openChangePinDialog(BuildContext context) {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar PIN de Admin 🔒', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa tu PIN actual y el nuevo PIN de 4 números:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 14),
              TextField(
                controller: currentPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'PIN Actual', border: OutlineInputBorder(), counterText: ''),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nuevo PIN (4 dígitos)', border: OutlineInputBorder(), counterText: ''),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Confirmar Nuevo PIN', border: OutlineInputBorder(), counterText: ''),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              final currentInput = currentPinController.text.trim();
              final newInput = newPinController.text.trim();
              final confirmInput = confirmPinController.text.trim();

              if (currentInput != globalAdminPinNotifier.value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Error: El PIN actual es incorrecto')),
                );
                return;
              }

              if (newInput.length != 4 || int.tryParse(newInput) == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Error: El nuevo PIN debe tener exactamente 4 números')),
                );
                return;
              }

              if (newInput != confirmInput) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Error: Los nuevos PINs no coinciden')),
                );
                return;
              }

              globalAdminPinNotifier.value = newInput;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✨ ¡PIN de administrador cambiado con éxito! ✨')),
              );
            },
            child: const Text('Actualizar PIN', style: TextStyle(color: Colors.white)),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.justify,
                  decoration: const InputDecoration(labelText: 'Nombre del producto', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  textAlign: TextAlign.justify,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: const InputDecoration(labelText: 'Precio (\$ 3.500)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  textAlign: TextAlign.justify,
                  decoration: const InputDecoration(labelText: 'Descripción corta', border: OutlineInputBorder()),
                ),
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
                  TextField(
                    controller: customCategoryController,
                    textAlign: TextAlign.justify,
                    decoration: const InputDecoration(labelText: 'Nombre de la nueva categoría', border: OutlineInputBorder()),
                  ),
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
                        ? const Text('¡Cargada!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
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
                    onPressed: () async {
                      final name = formatTitleCase(nameController.text);
                      String rawPrice = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final price = double.tryParse(rawPrice) ?? 0.0;
                      final desc = formatTitleCase(descController.text);
                      
                      String finalCategory = selectedDropdownCategory;
                      if (selectedDropdownCategory == '+ Otra (Escribir nueva)...') {
                        finalCategory = formatTitleCase(customCategoryController.text);
                        if (finalCategory.isEmpty) finalCategory = 'Accesorios';
                      }

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El nombre del producto no puede estar vacío')),
                        );
                        return;
                      }

                      String? base64Img;
                      if (selectedImageBytes != null) {
                        try {
                          if (selectedImageBytes!.lengthInBytes > 700000) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('La imagen es demasiado pesada. Usa una más pequeña.')),
                            );
                            return;
                          }
                          base64Img = base64Encode(selectedImageBytes!);
                        } catch (_) {}
                      } else if (productToEdit?.imageBytes != null) {
                        base64Img = base64Encode(productToEdit!.imageBytes!);
                      }

                      Map<String, dynamic> productData = {
                        'name': name,
                        'price': price,
                        'desc': desc.isEmpty ? 'Creación exclusiva' : desc,
                        'category': finalCategory,
                        'imageBase64': base64Img ?? '',
                      };

                      String docId = productToEdit?.id ?? '';
                      if (docId.isEmpty || docId.length < 5) {
                        docId = 'prod_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}';
                      }

                      List<ProductItem> updatedList = List.from(globalProductsNotifier.value);
                      if (productToEdit == null) {
                        updatedList.add(ProductItem(
                          id: docId,
                          name: name,
                          price: price,
                          desc: desc.isEmpty ? 'Creación exclusiva' : desc,
                          category: finalCategory,
                          imageBytes: selectedImageBytes,
                          color: Colors.pink[200]!,
                        ));
                      } else {
                        final index = updatedList.indexWhere((p) => p.id == productToEdit.id);
                        if (index >= 0) {
                          updatedList[index].name = name;
                          updatedList[index].price = price;
                          updatedList[index].desc = desc.isEmpty ? 'Creación exclusiva' : desc;
                          updatedList[index].category = finalCategory;
                          if (selectedImageBytes != null) {
                            updatedList[index].imageBytes = selectedImageBytes;
                          }
                        }
                      }
                      globalProductsNotifier.value = updatedList;

                      try {
                        if (productToEdit == null) {
                          await FirebaseFirestore.instance.collection('products').doc(docId).set(productData);
                        } else {
                          await FirebaseFirestore.instance.collection('products').doc(productToEdit.id).set(productData, SetOptions(merge: true));
                        }
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Guardado con éxito en la nube! ☁️✨')),
                        );
                      } catch (_) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Guardado localmente (Verifica conexión a la nube)')),
                        );
                      }

                      setState(() {});
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
        content: Text(
          '¿Desea eliminar el producto "${item.name}"?',
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                if (item.id.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('products').doc(item.id).delete();
                }
              } catch (_) {}
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

  // --- GESTIÓN DE TORNEOS EXCLUSIVA DE VALENTINA ---
  void _openTournamentManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Gestión de Torneos 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 450,
              height: 400,
              child: ValueListenableBuilder<List<TournamentItem>>(
                valueListenable: globalTournamentsNotifier,
                builder: (context, tournaments, child) {
                  return Column(
                    children: [
                      Expanded(
                        child: tournaments.isEmpty
                            ? const Center(child: Text('No hay torneos programados.'))
                            : ListView.builder(
                                itemCount: tournaments.length,
                                itemBuilder: (context, index) {
                                  final t = tournaments[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(t.gameName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      subtitle: Text('Premio: ${t.prize}\nFin: ${DateFormat('dd/MM/yyyy HH:mm').format(t.endDate)}', style: const TextStyle(fontSize: 11)),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () {
                                          List<TournamentItem> updated = List.from(globalTournamentsNotifier.value);
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
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
                        onPressed: () {
                          _openAddTournamentDialog(context, () {
                            setStateDialog(() {});
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Programar Nuevo Torneo', style: TextStyle(color: Colors.white)),
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

  void _openAddTournamentDialog(BuildContext context, VoidCallback onAdded) {
    // Se ha retirado "Sopa de Letras Mágica" y solo quedan los juegos permitidos
    String selectedGame = 'Concentración Mágica';
    final prizeController = TextEditingController();
    final rulesController = TextEditingController();
    
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Programar Torneo 👑'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Elige el Juego:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: selectedGame,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ['Concentración Mágica', 'Reto de Velocidad']
                      .map((game) => DropdownMenuItem(value: game, child: Text(game)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedGame = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: prizeController,
                  textAlign: TextAlign.justify,
                  decoration: const InputDecoration(labelText: 'Premio de la Administración', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: rulesController,
                  textAlign: TextAlign.justify,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Reglas del Torneo', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text('Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(startDate)}'),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2026), lastDate: DateTime(2030));
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startDate));
                      if (pickedTime != null) {
                        setStateDialog(() {
                          startDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                        });
                      }
                    }
                  },
                ),
                ListTile(
                  title: Text('Cierre: ${DateFormat('dd/MM/yyyy HH:mm').format(endDate)}'),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: endDate, firstDate: DateTime(2026), lastDate: DateTime(2030));
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(endDate));
                      if (pickedTime != null) {
                        setStateDialog(() {
                          endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
              onPressed: () {
                final prize = formatTitleCase(prizeController.text);
                final rules = rulesController.text.trim();

                if (prize.isEmpty || rules.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa el premio y las reglas')));
                  return;
                }

                List<TournamentItem> updated = List.from(globalTournamentsNotifier.value);
                updated.add(TournamentItem(
                  id: 't_${DateTime.now().millisecondsSinceEpoch}',
                  gameName: selectedGame,
                  prize: prize,
                  rules: rules,
                  startDate: startDate,
                  endDate: endDate,
                  scores: [],
                ));
                globalTournamentsNotifier.value = updated;
                onAdded();
                Navigator.pop(context);
              },
              child: const Text('Guardar Torneo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD85A7F),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _openTournamentManager(context),
              icon: const Icon(Icons.emoji_events, color: Colors.white),
              label: const Text('Gestionar Torneos de Juegos 🏆', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4ECDC4),
                side: const BorderSide(color: Color(0xFF4ECDC4)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _openPaletteManager(context),
              icon: const Icon(Icons.palette),
              label: const Text('Gestionar Paleta y Precios 🎨', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                helpText: 'SELECCIONA EL PERIODO',
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
                      final revenue = (productSalesRevenue[prodName] ?? 0.0) > 0 ? productSalesRevenue[prodName]! : 0.0;
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
        title: const Text('Exactitud y Saludo de Luz', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.justify,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Escribe el mensaje de bienvenida de Luz...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () => Navigator.pop(context),
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
        title: const Text('Panel de Administración', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  icon: Icon(Icons.local_shipping, color: _adminTab == 1 ? const Color(0xFFD85A7F) : Colors.grey), // ignore: avoid_returning_null_for_void
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
                label: const Text('Personalizar Saludo de Luz', style: TextStyle(fontWeight: FontWeight.bold)),
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