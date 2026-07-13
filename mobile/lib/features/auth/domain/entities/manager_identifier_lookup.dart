/// `POST /auth/check-identifier` purpose=`manager_identifier` sonucu.
class ManagerIdentifierLookup {
  const ManagerIdentifierLookup({
    required this.exists,
    this.name,
  });

  final bool exists;

  /// Trim edilmiş ad; boş veya yoksa `null`.
  final String? name;
}
