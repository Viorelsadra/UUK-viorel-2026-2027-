import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String kelas,
    required String foto,
  }) async {
    await _db.collection('users').doc(uid).set({
      'user_id': uid,
      'name': name,
      'email': email,
      'kelas': kelas,
      'foto': foto,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getItems() {
    return FirebaseFirestore.instance
        .collection('items')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> addItem({
    required String itemName,
    required String category,
    required String code,
    required String image,
    required String spesification,
  }) async {
    final docRef = _db.collection('items').doc();
    await docRef.set({
      'item_id': docRef.id,
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': 'Available',
      'image': image,
      'spesification': spesification,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String itemId,
    required String itemName,
    required String category,
    required String code,
    required String status,
    required String image,
    required String spesification,
  }) async {
    await _db.collection('items').doc(itemId).update({
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'spesification': spesification,
    });
  }

  Future<void> deleteItem(String itemId) async {
    await _db.collection('items').doc(itemId).delete();
  }

  Future<void> borrowItem({
    required String uid,
    required String itemId,
    required String itemName,
  }) async {
    await _db.collection('items').doc(itemId).update({
      'status': 'Borrowed',
      'borrowed_by': uid,
    });

    await _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .doc(itemId)
        .set({
          'item_id': itemId,
          'item_name': itemName,
          'borrowed_at': FieldValue.serverTimestamp(),
        });
  }

  Future<void> cancelBorrowItem({
    required String uid,
    required String itemId,
  }) async {
    await _db.collection('items').doc(itemId).update({
      'status': 'Available',
      'borrowed_by': '',
    });

    final borrowingsRef = _db
        .collection('users')
        .doc(uid)
        .collection('borrowings');

    await borrowingsRef.doc(itemId).delete();

    final snapshots = await borrowingsRef
        .where('item_id', isEqualTo: itemId)
        .get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> returnItem({
    required String uid,
    required String borrowId,
    required String itemId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .doc(borrowId)
        .delete();

    await _db.collection('items').doc(itemId).update({'status': 'Available'});
  }

  Stream<QuerySnapshot> getBorrowings(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .orderBy('borrow_date', descending: true)
        .snapshots();
  }

  Future<void> requestBorrowItem({
    required String uid,
    required String docId,
    required String itemId,
    required String itemName,
    required String code,
  }) async {
    final borrowRef = _db
        .collection('users')
        .doc(uid)
        .collection('borrowings')
        .doc();

    await borrowRef.set({
      'borrow_id': borrowRef.id,
      'item_id': itemId,
      'item_name': itemName,
      'code': code,
      'borrowed_at': FieldValue.serverTimestamp(),
    });

    await _db.collection('items').doc(docId).update({
      'status': 'Borrowed',
      'borrowed_by': uid,
    });
  }

  Future<void> seedDummyItems() async {
    final dummyList = [
      {
        'item_name': 'Laptop ASUS ROG Zephyrus',
        'category': 'Komputer',
        'code': 'LAB-001',
        'image':
            'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500',
        'spesification': 'AMD Ryzen 9 ultra, RAM 64GB, SSD 4TB, Layar 14 inci',
      },
      {
        'item_name': 'Proyektor Epson EB-X500',
        'category': 'Multimedia',
        'code': 'LAB-002',
        'image':
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500',
        'spesification': '3600 Lumens, Resolusi XGA, Port HDMI & VGA',
      },
      {
        'item_name': 'Kamera Canon EOS M50',
        'category': 'Dokumentasi',
        'code': 'LAB-003',
        'image':
            'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
        'spesification': '24.1 MP APS-C CMOS, Video 4K, Lensa Kit 15-45mm',
      },
      {
        'item_name': 'Mikroskop Digital Binokuler',
        'category': 'Alat Ukur',
        'code': 'LAB-004',
        'image':
            'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=500',
        'spesification': 'Pembesaran 40x-1000x, Lampu LED, Lensa Achromatic',
      },
    ];
    for (var item in dummyList) {
      await addItem(
        itemName: item['item_name']!,
        category: item['category']!,
        code: item['code']!,
        image: item['image']!,
        spesification: item['spesification']!,
      );
    }
  }
}
