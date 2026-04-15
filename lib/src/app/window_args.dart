import 'dart:convert';

enum NexoWindowType { main, widget }

class NexoWindowArgs {
  const NexoWindowArgs({required this.type});

  final NexoWindowType type;

  String encode() => jsonEncode({'type': type.name});

  static NexoWindowArgs decode(String raw) {
    try {
      final m = jsonDecode(raw);
      if (m is Map && m['type'] is String) {
        final t = (m['type'] as String);
        final type = NexoWindowType.values.firstWhere(
          (e) => e.name == t,
          orElse: () => NexoWindowType.main,
        );
        return NexoWindowArgs(type: type);
      }
    } catch (_) {}
    return const NexoWindowArgs(type: NexoWindowType.main);
  }
}

