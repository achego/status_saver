extension DateTimeExtension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inSeconds > 0) {
      return '${difference.inSeconds}s ago';
    }

    return 'just now';
  }
}
