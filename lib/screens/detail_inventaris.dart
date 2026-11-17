import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/firestore.dart';
import '../utils/app_color.dart';

class DetailInventaris extends StatefulWidget {
  final String docId;

  const DetailInventaris({super.key, required this.docId});

  @override
  State<DetailInventaris> createState() => _DetailInventarisState();
}

class _DetailInventarisState extends State<DetailInventaris> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _borrowItem({
    required String itemId,
    required String itemName,
    required String code,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.requestBorrowItem(
        uid: user.uid,
        docId: widget.docId,
        itemId: itemId,
        itemName: itemName,
        code: code,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil mengajukan pinjam $itemName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal mengajukan pinjam: $e'),
          ),
        );
      }
    }
  }

  Future<void> _cancelBorrowItem(String itemId, String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.cancelBorrowItem(
        uid: user.uid,
        itemId: itemId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Peminjaman $itemName dibatalkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal membatalkan: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Inventaris',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .doc(widget.docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data alat tidak ditemukan'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final itemId = (data['item_id'] ?? widget.docId).toString();
          final itemName = (data['item_name'] ?? 'Tanpa Nama').toString();
          final code = (data['code'] ?? '-').toString();
          final category = (data['category'] ?? '-').toString();
          final spesification = (data['spesification'] ?? '-').toString();
          final image = (data['image'] ?? '').toString();
          final status = (data['status'] ?? 'Available').toString();
          final isAvailable = status == 'Available';

          final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final borrowedBy = (data['borrowed_by'] ?? '').toString();
          final canCancel =
              !isAvailable && (borrowedBy.isEmpty || borrowedBy == currentUid);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          image,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 220,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.inventory_2, size: 60),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            code,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? Colors.green.shade100
                                  : const Color.fromARGB(255, 255, 178, 178),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isAvailable
                                    ? Colors.green.shade800
                                    : const Color.fromARGB(255, 239, 0, 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: $category',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Spesifikasi Alat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(height: 20),
                              Text(
                                spesification,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isAvailable
                      ? ElevatedButton.icon(
                          onPressed: () => _borrowItem(
                            itemId: itemId,
                            itemName: itemName,
                            code: code,
                          ),
                          icon: const Icon(Icons.assignment_turned_in),
                          label: const Text('Ajukan Pinjam'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : canCancel
                          ? OutlinedButton.icon(
                              onPressed: () =>
                                  _cancelBorrowItem(itemId, itemName),
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Color.fromARGB(255, 255, 0, 0),
                              ),
                              label: const Text(
                                'Batal Pinjam',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 0, 0),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 255, 0, 0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Sedang Dipinjam'),
                            ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}