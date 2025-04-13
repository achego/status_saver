import 'dart:async';
import 'dart:developer';

logger(dynamic item, [String? name]) {
  return log(
    item.toString(),
    name: name ?? '',
    time: DateTime.now(),
    sequenceNumber: 2,
  );
}

loggerEx(dynamic e, [StackTrace? s]) {
  return log(
    'Error mow',
    name: 'Error 00',
    time: DateTime.now(),
    sequenceNumber: 2,
    zone: Zone.current,
    error: e,
    stackTrace: s,
    level: 4,
  );
}
