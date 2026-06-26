import 'package:flutter/material.dart';

/// Buton okları için standart widget.
///
/// - [`ChevronDirection.right`]: "detaya git / sonraki ekran" iması
/// - [`ChevronDirection.down`]: "liste/picker/sheet açar" iması
///
/// Mevcut boyut/renk değerlerini parametre olarak alır,
/// böylece her kullanım yerindeki görünüm aynen korunur.
class ActionChevron extends StatelessWidget {
  const ActionChevron({
    super.key,
    this.direction = ChevronDirection.right,
    this.size,
    this.color,
  });

  final ChevronDirection direction;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      direction == ChevronDirection.right
          ? Icons.chevron_right_rounded
          : Icons.keyboard_arrow_down_rounded,
      size: size,
      color: color,
    );
  }
}

enum ChevronDirection { right, down }
