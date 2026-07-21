/// `POST /auth/check-identifier` sonucu (`manager_identifier` | `resident_phone`).
class ManagerIdentifierLookup {
  const ManagerIdentifierLookup({
    required this.exists,
    this.name,
  });

  final bool exists;

  /// Trim edilmiş ad; boş veya yoksa `null`.
  final String? name;
}
