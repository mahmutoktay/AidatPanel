import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PasswordCriterion extends StatelessWidget {
  final String text;
  final bool isMet;

  const PasswordCriterion({
    super.key,
    required this.text,
    required this.isMet,
  });

  static final _metIcon = Icon(
    Icons.check_circle,
    color: AppColors.success,
    size: 16,
  );
  static final _unmetIcon = Icon(
    Icons.circle_outlined,
    color: AppColors.textDisabled,
    size: 16,
  );
  static final _metStyle = TextStyle(
    color: AppColors.success,
    fontSize: 12,
  );
  static final _unmetStyle = TextStyle(
    color: AppColors.textDisabled,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          isMet ? _metIcon : _unmetIcon,
          const SizedBox(width: 8),
          Text(text, style: isMet ? _metStyle : _unmetStyle),
        ],
      ),
    );
  }
}
