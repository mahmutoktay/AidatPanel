/// Cursor tabanlı liste yanıtı (`{ items, nextCursor }` veya düz dizi).
class PaginatedListResult<T> {
  const PaginatedListResult({
    required this.items,
    this.nextCursor,
  });

  final List<T> items;
  final String? nextCursor;

  bool get hasMore =>
      nextCursor != null && nextCursor!.isNotEmpty;
}
