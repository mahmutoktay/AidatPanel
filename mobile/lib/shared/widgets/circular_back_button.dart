import 'package:flutter/material.dart';

import 'app_back_button.dart';

/// Eski kullanım adı; görsel uygulama [AppBackButton] üzerinden tekilleştirildi.
class CircularBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CircularBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppBackButton(onPressed: onPressed);
  }
}
