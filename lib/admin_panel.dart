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
            title: const Text('Gestión de Promociones', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  subtitle: subtitle.isEmpty ? '¡Descuento especial!' : subtitle,
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
        content: Text('¿Desea eliminar la categoría "$categoryToDelete"? Los productos asociados pasarán a la categoría "Accesorios".'),
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

                      // Generar un ID estable y único garantizando que Firestore guarde el documento permanentemente con una clave clara
                      String docId = productToEdit?.id ?? '';
                      if (docId.isEmpty || docId.length < 5 || docId.startsWith('1') || docId.startsWith('2') || docId.startsWith('3') || docId.startsWith('4') || docId.startsWith('5') || docId.startsWith('6') || docId.startsWith('7') || docId.startsWith('8') || docId.startsWith('9') || docId.startsWith('10')) {
                        docId = 'prod_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}';
                      }

                      // 1. Actualización local instantánea (Optimistic UI)
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

                      // 2. Persistencia en la nube de Firestore (Compatible con Web sin arrojar TypeError de FirebaseException)
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
        content: Text('¿Desea eliminar el producto "${item.name}"?'),
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
        title: const Text('Editar Saludo de Luz', style: TextStyle(fontWeight: FontWeight.bold)),
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