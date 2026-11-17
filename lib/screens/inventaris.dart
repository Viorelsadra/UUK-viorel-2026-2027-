import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/firestore.dart';
import '../utils/app_color.dart';
import 'detail_inventaris.dart';

class Inventaris extends StatefulWidget {
  const Inventaris({super.key});

  @override
  State<Inventaris> createState() => _InventarisState();
}

class _InventarisState extends State<Inventaris> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showItemForm({Map<String, dynamic>? item, String? docId}) {
    final isEdit = item != null;
    final nameController = TextEditingController(
      text: item?['item_name'] ?? '',
    );
    final categoryController = TextEditingController(
      text: item?['category'] ?? '',
    );
    final codeController = TextEditingController(text: item?['code'] ?? '');
    final specController = TextEditingController(
      text: item?['spesification'] ?? '',
    );
    final imageController = TextEditingController(
      text:
          item?['image'] ??
          'https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=500',
    );
    String selectedStatus = item?['status'] ?? 'Available';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEdit
                          ? 'Edit Alat Inventaris'
                          : 'Tambah Alat Inventaris',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Alat',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Alat (Contoh: LAB-005)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: specController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Spesifikasi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'Link URL Gambar',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Available',
                            child: Text('Available'),
                          ),
                          DropdownMenuItem(
                            value: 'Borrowed',
                            child: Text('Borrowed'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => selectedStatus = value);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              codeController.text.trim().isEmpty) {
                            return;
                          }
                          if (isEdit) {
                            final targetId = item['item_id'] ?? docId ?? '';
                            await _firestoreService.updateItem(
                              itemId: targetId,
                              itemName: nameController.text.trim(),
                              category: categoryController.text.trim(),
                              code: codeController.text.trim(),
                              status: selectedStatus,
                              image: imageController.text.trim(),
                              spesification: specController.text.trim(),
                            );
                          } else {
                            await _firestoreService.addItem(
                              itemName: nameController.text.trim(),
                              category: categoryController.text.trim(),
                              code: codeController.text.trim(),
                              image: imageController.text.trim(),
                              spesification: specController.text.trim(),
                            );
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: AppColor.textTertiary,
                        ),
                        child: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Alat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String itemId, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alat'),
        content: Text('Yakin ingin menghapus "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _firestoreService.deleteItem(itemId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColor.secondGradient),
        ),
        title: const Text(
          'Inventaris Alat Lab',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Isi Data Dummy',
            icon: const Icon(Icons.playlist_add),
            onPressed: () => _firestoreService.seedDummyItems(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum ada data inventaris'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _firestoreService.seedDummyItems(),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Generate Data Dummy'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final itemId = (data['item_id'] ?? docId).toString();
              final itemName = (data['item_name'] ?? 'Tanpa Nama').toString();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailInventaris(docId: docId),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data['image'] ?? '',
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 75,
                              height: 75,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.inventory_2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showItemForm(item: data, docId: docId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(itemId, itemName),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showItemForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}