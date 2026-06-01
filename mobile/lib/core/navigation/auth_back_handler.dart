import 'package:flutter/material.dart';

import 'app_back_navigation.dart';

/// Login vb. auth ekranları için geri tuşu.
class AuthBackHandler extends StatelessWidget {
  const AuthBackHandler({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async =>
          AppBackNavigation.handleAuthBackPressed(context),
      child: child,
    );
  }
}
