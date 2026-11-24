import 'package:flutter_test/flutter_test.dart';
import 'package:waratel_app/core/call/call_service.dart';

void main() {
  test('CallService.callUuid generates deterministic RFC 4122 v5 UUID', () {
    final uuid1 = CallService.callUuid('181');
    final uuid2 = CallService.callUuid('181');
    final uuidEmpty = CallService.callUuid('');

    expect(uuid1, equals(uuid2));
    expect(uuid1.length, equals(36));
    expect(uuidEmpty, equals('00000000-0000-4000-8000-000000000000'));
  });
}
