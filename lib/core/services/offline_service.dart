import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OfflineService {
  final FirebaseFirestore _firestore;
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _offlineDataKey = 'offline_data';

  OfflineService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _initializeOfflineCapability();
  }

  Future<void> _initializeOfflineCapability() async {
    // Set cache size and enable persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100000000, // 100MB
    );
  }

  Future<void> saveOfflineData(
      String collection, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineData = prefs.getString(_offlineDataKey);
    Map<String, dynamic> allData = {};

    if (offlineData != null) {
      allData = json.decode(offlineData);
    }

    if (!allData.containsKey(collection)) {
      allData[collection] = [];
    }

    // Add timestamp for synchronization
    data['_offlineTimestamp'] = DateTime.now().toIso8601String();
    data['_needsSync'] = true;

    (allData[collection] as List).add(data);
    await prefs.setString(_offlineDataKey, json.encode(allData));
  }

  Future<List<Map<String, dynamic>>> getOfflineData(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineData = prefs.getString(_offlineDataKey);

    if (offlineData != null) {
      final allData = json.decode(offlineData);
      if (allData.containsKey(collection)) {
        return List<Map<String, dynamic>>.from(allData[collection]);
      }
    }

    return [];
  }

  Future<void> synchronizeOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineData = prefs.getString(_offlineDataKey);

    if (offlineData != null) {
      final allData = json.decode(offlineData) as Map<String, dynamic>;

      for (var collection in allData.keys) {
        final items = List<Map<String, dynamic>>.from(allData[collection]);
        for (var item in items) {
          if (item['_needsSync'] == true) {
            try {
              // Remove sync flags before saving to Firestore
              item.remove('_needsSync');
              item.remove('_offlineTimestamp');

              await _firestore.collection(collection).add(item);
            } catch (e) {
              print('Error syncing item: $e');
              continue;
            }
          }
        }
      }

      // Clear synchronized data
      await prefs.setString(_offlineDataKey, json.encode({}));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    }
  }

  Future<bool> isDataStale() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);

    if (lastSync == null) return true;

    final lastSyncTime = DateTime.parse(lastSync);
    final staleDuration = const Duration(hours: 24);

    return DateTime.now().difference(lastSyncTime) > staleDuration;
  }

  Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineDataKey);
    await prefs.remove(_lastSyncKey);
  }
}
