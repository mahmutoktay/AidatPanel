import '../constants/invite_link_constants.dart';
import '../../shared/utils/auth_validators.dart';

/// HTTPS / özel şema davet linklerinden kod çıkarır.
class InviteLinkParser {
  InviteLinkParser._();

  static String? inviteCodeFrom(Uri uri) {
    String? raw;

    if (uri.scheme == InviteLinkConstants.customScheme &&
        uri.host == 'join') {
      raw = uri.queryParameters['code'];
    } else if (uri.scheme == 'https' &&
        uri.host == 'aidatpanel.com' &&
        (uri.path == '/join' || uri.path == '/join/')) {
      raw = uri.queryParameters['code'];
    }

    if (raw == null || raw.trim().isEmpty) return null;
    final normalized = AuthValidators.normalizeInviteCode(raw);
    if (!AuthValidators.isValidInviteCode(normalized)) return null;
    return normalized;
  }
}
