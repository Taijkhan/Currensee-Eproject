import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserStatus(String userId, bool isActive) async {
    await _firestore.collection('registration').doc(userId).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('registration').doc(userId).delete();
  }
  // Get all users
  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('registration').snapshots();
  }

  // Get all conversion history
  Stream<QuerySnapshot> getConversionHistory() {
    return _firestore.collection('conversion_history').orderBy('timestamp', descending: true).snapshots();
  }

  // Get all rate alerts
  Stream<QuerySnapshot> getRateAlerts() {
    return _firestore.collection('rate_alerts').snapshots();
  }

  // Get supported currencies - FIXED
  Future<List<Map<String, dynamic>>> getSupportedCurrencies() async {
    try {
      final snapshot = await _firestore.collection('currency').orderBy('name').get();
      print('Fetched ${snapshot.docs.length} currencies from Firestore');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure all required fields are present
        return {
          'id': doc.id,
          'code': data['code'] ?? '',
          'name': data['name'] ?? '',
          'symbol': data['symbol'] ?? '',
          'flagImage': data['flagImage'] ?? [],
        };
      }).toList();
    } catch (e) {
      print("Error fetching currencies: $e");
      return [];
    }
  }

  // Add new currency
  Future<void> addCurrency(Map<String, dynamic> currencyData) async {
    await _firestore.collection('currency').add(currencyData);
  }

  // Update currency
  Future<void> updateCurrency(String currencyId, Map<String, dynamic> updates) async {
    await _firestore.collection('currency').doc(currencyId).update(updates);
  }

  // Delete currency
  Future<void> deleteCurrency(String currencyId) async {
    await _firestore.collection('currency').doc(currencyId).delete();
  }

  // Get dashboard statistics - UPDATED collection name
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final conversionsCount = await _firestore.collection('conversion_history').count().get();
      final alertsCount = await _firestore.collection('rate_alerts').count().get();
      final currenciesCount = await _firestore.collection('currency').count().get();

      return {
        'users': usersCount.count,
        'conversions': conversionsCount.count,
        'alerts': alertsCount.count,
        'currencies': currenciesCount.count,
      };
    } catch (e) {
      return {
        'users': 0,
        'conversions': 0,
        'alerts': 0,
        'currencies': 0,
      };
    }
  }

  // Delete conversion record
  Future<void> deleteConversion(String conversionId) async {
    await _firestore.collection('conversion_history').doc(conversionId).delete();
  }

  // Delete rate alert
  Future<void> deleteAlert(String alertId) async {
    await _firestore.collection('rate_alerts').doc(alertId).delete();
  }

  // Toggle user status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _firestore.collection('users').doc(userId).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}