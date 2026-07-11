import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// `aidatpanel://join?code=` ve `https://aidatpanel.com/join?code=` deep link'leri.
class InviteDeepLinkNotifier extends Notifier<void> {
  StreamSubscription<Uri>? _sub;
  final AppLinks _appLinks = AppLinks();

  @override
  void build() {
    ref.onDispose(() {
      _sub?.cancel();
    });
    Future.microtask(_init);
  }

  Future<void> _init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleUri(initial);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[invite_deep_link] initial error: $e');
      }
    }

    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('[invite_deep_link] stream error: $e');
        }
      },
    );
  }

  void _handleUri(Uri uri) {
    final code = _extractInviteCode(uri);
    if (code == null) return;

    final path = '/login?role=resident&code=${Uri.encodeComponent(code)}';
    if (kDebugMode) {
      debugPrint('[invite_deep_link] navigate → $path');
    }

    // Router henüz hazır olmayabilir (cold start); kısa gecikme ile dene.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        GoRouter.of(ctx).go(path);
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        final ctx2 = rootNavigatorKey.currentContext;
        if (ctx2 != null && ctx2.mounted) {
          GoRouter.of(ctx2).go(path);
        }
      });
    });
  }

  /// Desteklenen URI'ler:
  /// - aidatpanel://join?code=AP3-...
  /// - https://aidatpanel.com/join?code=AP3-...
  static String? _extractInviteCode(Uri uri) {
    final code = uri.queryParameters['code']?.trim();
    if (code == null || code.isEmpty) return null;

    final isCustomScheme =
        uri.scheme == 'aidatpanel' && uri.host.toLowerCase() == 'join';
    final isHttpsJoin = (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.toLowerCase() == 'aidatpanel.com' &&
        (uri.path == '/join' || uri.path.startsWith('/join/'));

    if (!isCustomScheme && !isHttpsJoin) return null;
    return code.toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }
}

final inviteDeepLinkProvider =
    NotifierProvider<InviteDeepLinkNotifier, void>(InviteDeepLinkNotifier.new);
