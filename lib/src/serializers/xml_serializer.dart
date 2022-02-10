import 'dart:io';
import 'package:otstudio/src/progress_tracker.dart';
import 'package:xml/xml.dart';
import 'package:otstudio/src/serializers/disk_serializer.dart';

class XmlSerializer extends DiskSerializer<XmlDocument> {
  @override
  Future<void> serialize(
      ProgressTracker<DiskSerializerSerializePayload<XmlDocument>>
          tracker) async {
    String xmlString = tracker.data.data.toXmlString(pretty: true);
    await File(tracker.data.path).writeAsString(xmlString);
  }

  @override
  Future<XmlDocument> deserialize(
      ProgressTracker<DiskSerializerDeserializePayload> tracker) async {
    String xmlString = await File(tracker.data.path).readAsString();
    return XmlDocument.parse(xmlString);
  }
}
