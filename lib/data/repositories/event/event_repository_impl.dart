import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/data/repositories/event/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'events';

  @override
  Stream<List<EventDetailModel>> watchAllEvents() {
    try {
      return _firestore.collection(_collectionName).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final raw = doc.data();
          final Map<String, dynamic> jsonData = {
            ...raw,
            if (raw['startTime'] != null && raw['startTime'] is Timestamp)
              'startTime': (raw['startTime'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            if (raw['endTime'] != null && raw['endTime'] is Timestamp)
              'endTime': (raw['endTime'] as Timestamp)
                  .toDate()
                  .toIso8601String(),
            'id': raw['id'] ?? doc.id,
          };
          return EventDetailModel.fromJson(jsonData);
        }).toList();
      });
    } catch (e) {
      return Stream.error('Failed to watch events: $e');
    }
  }
}
