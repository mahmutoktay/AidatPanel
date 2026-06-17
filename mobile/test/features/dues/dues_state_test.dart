import 'package:flutter_test/flutter_test.dart';

import 'package:aidatpanel/features/dues/presentation/providers/dues_provider.dart';

void main() {
  group('DuesState pagination cursor', () {
    test('clearNextCursor resets nextCursor to null', () {
      const state = DuesState(nextCursor: 'cursor-abc');

      final cleared = state.copyWith(clearNextCursor: true);

      expect(cleared.nextCursor, isNull);
      expect(cleared.canLoadMore, isFalse);
    });

    test('preserves cursor when API returns next page token', () {
      const state = DuesState(nextCursor: 'cursor-abc');

      final updated = state.copyWith(nextCursor: 'cursor-def');

      expect(updated.nextCursor, 'cursor-def');
      expect(updated.canLoadMore, isTrue);
    });

    test('clears stale cursor when result has no next page', () {
      final state = DuesState(
        nextCursor: 'cursor-abc',
        dues: const [],
      );

      final updated = state.copyWith(
        nextCursor: null,
        clearNextCursor: true,
      );

      expect(updated.nextCursor, isNull);
      expect(updated.canLoadMore, isFalse);
    });

    test('canLoadMore is false while loading more', () {
      const state = DuesState(
        nextCursor: 'cursor-abc',
        isLoadingMore: true,
      );

      expect(state.canLoadMore, isFalse);
    });
  });
}
