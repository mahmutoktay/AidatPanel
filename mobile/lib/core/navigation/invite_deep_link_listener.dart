import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import 'invite_link_parser.dart';

/// Uygulama açıkken veya soğuk başlangıçta davet linklerini `/join?code=` rotasına yönlendirir.
class InviteDeepLinkListener extends ConsumerStatefulWidget {
  const InviteDeepLinkListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InviteDeepLinkListener> createState() =>
      _InviteDeepLinkListenerState();
}

class _InviteDeepLinkListenerState extends ConsumerState<InviteDeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    _subscription = _appLinks.uriLinkStream.listen(
      _navigateForUri,
      onError: (_) {},
    );
  }

  void _navigateForUri(Uri uri) {
    final code = InviteLinkParser.inviteCodeFrom(uri);
    if (code == null) return;

    final router = ref.read(appRouterProvider);
    final target = '/join?code=${Uri.encodeComponent(code)}';
    if (router.state.uri.toString() == target) return;
    router.go(target);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
