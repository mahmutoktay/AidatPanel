import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_entity.dart';
import 'dues_list_item_card.dart';

class DuesListItemSlidable extends StatelessWidget {
  const DuesListItemSlidable({
    super.key,
    required this.due,
    required this.currencySymbol,
    required this.highlighted,
    required this.onTap,
    this.onCollectPayment,
  });

  final DueEntity due;
  final String currencySymbol;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback? onCollectPayment;

  bool get _canSwipe =>
      onCollectPayment != null &&
      (due.status == DueStatus.pending || due.status == DueStatus.overdue);

  @override
  Widget build(BuildContext context) {
    final card = DuesListItemCard(
      due: due,
      currencySymbol: currencySymbol,
      highlighted: highlighted,
      onTap: onTap,
    );

    if (!_canSwipe) return card;

    final t = context.t.features.dues;

    return Slidable(
      key: ValueKey<String>(due.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.34,
        children: [
          SlidableAction(
            onPressed: (_) => onCollectPayment!(),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.payments_outlined,
            label: t.collectPayment,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
        ],
      ),
      child: card,
    );
  }
}
