import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_find/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('timeAgo returns "Just now" for recent timestamps', () {
      final now = DateTime.now();
      expect(DateFormatter.timeAgo(now), 'Just now');
    });

    test('timeAgo returns minutes ago', () {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.timeAgo(past), '5 minutes ago');
    });

    test('timeAgo returns singular minute', () {
      final past = DateTime.now().subtract(const Duration(minutes: 1));
      expect(DateFormatter.timeAgo(past), '1 minute ago');
    });

    test('timeAgo returns hours ago', () {
      final past = DateTime.now().subtract(const Duration(hours: 3));
      expect(DateFormatter.timeAgo(past), '3 hours ago');
    });

    test('timeAgo returns days ago', () {
      final past = DateTime.now().subtract(const Duration(days: 2));
      expect(DateFormatter.timeAgo(past), '2 days ago');
    });

    test('timeAgo returns weeks ago', () {
      final past = DateTime.now().subtract(const Duration(days: 14));
      expect(DateFormatter.timeAgo(past), '2 weeks ago');
    });

    test('formatDate returns formatted date', () {
      final date = DateTime(2026, 3, 15);
      expect(DateFormatter.formatDate(date), 'Mar 15, 2026');
    });

    test('formatTime returns 12-hour format', () {
      final morning = DateTime(2026, 1, 1, 9, 5);
      expect(DateFormatter.formatTime(morning), '9:05 AM');

      final afternoon = DateTime(2026, 1, 1, 14, 30);
      expect(DateFormatter.formatTime(afternoon), '2:30 PM');
    });

    test('formatTime handles midnight', () {
      final midnight = DateTime(2026, 1, 1, 0, 0);
      expect(DateFormatter.formatTime(midnight), '12:00 AM');
    });

    test('formatDateTime combines date and time', () {
      final dt = DateTime(2026, 10, 31, 15, 45);
      expect(DateFormatter.formatDateTime(dt), 'Oct 31, 2026 at 3:45 PM');
    });
  });
}
