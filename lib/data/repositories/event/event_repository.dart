
import 'package:event_go/data/models/event/event_detail_model.dart';

abstract class EventRepository {
  Stream<List<EventDetailModel>> watchAllEvents();
}