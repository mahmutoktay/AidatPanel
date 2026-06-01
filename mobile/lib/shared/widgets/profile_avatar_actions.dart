import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/presentation/providers/profile_photo_provider.dart';
import '../../l10n/strings.g.dart';
import 'toast_overlay.dart';

Future<void> handleProfileAvatarTap(BuildContext context, WidgetRef ref) async {
  final t = context.t.features.profile;
  final photoState = ref.read(profilePhotoProvider);
  final notifier = ref.read(profilePhotoProvider.notifier);

  if (!photoState.hasPhoto) {
    await notifier.saveBundledDefault();
    if (!context.mounted) return;
    ref.read(toastProvider.notifier).show(
          t.photoSaved,
          type: ToastType.success,
        );
    return;
  }

  final remove = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(sheetContext).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(t.removePhoto),
            onTap: () => Navigator.pop(sheetContext, true),
          ),
        ],
      ),
    ),
  );

  if (remove == true) {
    await notifier.clearPhoto();
    if (!context.mounted) return;
    ref.read(toastProvider.notifier).show(
          t.photoRemoved,
          type: ToastType.info,
        );
  }
}
