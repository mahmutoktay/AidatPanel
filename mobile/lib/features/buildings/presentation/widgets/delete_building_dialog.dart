import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/building_entity.dart';

/// Bina silmek için tip-to-confirm bottom sheet'i.
/// Kullanıcı, bina adını aynen yazana kadar "Sil" butonu pasiftir.
/// Belge §5: DELETE /buildings/:id; FK varsa 400 döner, mesajı
/// kullanıcı dostu Türkçeye çeviriyoruz.
class DeleteBuildingDialog extends ConsumerStatefulWidget {
  final BuildingEntity building;

  const DeleteBuildingDialog({super.key, required this.building});

  /// `true` döner: silindi; `false`/`null`: iptal veya hata.
  static Future<bool?> show(
    BuildContext context, {
    required BuildingEntity building,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF4F2EC),
      barrierColor: const Color(0x6114120C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => DeleteBuildingDialog(building: building),
    );
  }

  @override
  ConsumerState<DeleteBuildingDialog> createState() =>
      _DeleteBuildingDialogState();
}

class _DeleteBuildingDialogState extends ConsumerState<DeleteBuildingDialog> {
  final _controller = TextEditingController();
  bool _deleting = false;
  bool _attempted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _matches => _controller.text.trim() == widget.building.name.trim();

  void _fillPhrase(String phrase) {
    _controller.text = phrase;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() {
      _attempted = false;
    });
  }

  Future<void> _delete() async {
    if (!_matches) {
      setState(() => _attempted = true);
      return;
    }
    setState(() => _deleting = true);
    try {
      await ref.read(buildingsStoreProvider.notifier).removeBuilding(
            widget.building.id,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ref.read(toastProvider.notifier).show(
            context.t.common.buildingDeleted,
            type: ToastType.success,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
            duration: const Duration(seconds: 6),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.buildingDeleteFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = _matches && !_deleting;
    final phrase = widget.building.name;

    return PopScope(
      canPop: !_deleting,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E4DA),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEDEC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE15B4D),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.common.deleteBuilding,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15140F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.common.deleteBuildingHeader,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B6757),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Type hint text
                Text(
                  t.common.deleteBuildingTypeHint,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A9686),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),

                // 4. Clickable Red Card (phrase preview)
                _PhrasePreview(
                  phrase: phrase,
                  onTap: _deleting ? null : () => _fillPhrase(phrase),
                ),
                const SizedBox(height: 16),

                // 5. Text input field
                TextField(
                  controller: _controller,
                  enabled: !_deleting,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15140F),
                  ),
                  cursorColor: const Color(0xFF15140F),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                    hintText: phrase,
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0AC9D),
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF9A9686),
                      size: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE7E4DA), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE7E4DA), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF15140F), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE15B4D), width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE15B4D), width: 1.5),
                    ),
                    errorStyle: const TextStyle(
                      color: Color(0xFFE15B4D),
                      fontSize: 12,
                    ),
                    errorText: _attempted && !_matches
                        ? context.t.common.buildingNameMismatch
                        : null,
                  ),
                ),
                const SizedBox(height: 28),

                // 6. Actions row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _deleting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF15140F),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE7E4DA), width: 1.5),
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(t.common.cancelBtn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canSubmit ? _delete : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE15B4D),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE15B4D).withValues(alpha: 0.3),
                          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                          elevation: 0,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: _deleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(t.common.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Doğrulama cümlesini/bina adını gösteren — tıklanınca input'a yazan — kompakt kırmızı kart.
class _PhrasePreview extends StatelessWidget {
  final String phrase;
  final VoidCallback? onTap;

  const _PhrasePreview({required this.phrase, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDEDEC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  phrase,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFFE15B4D),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.touch_app_outlined,
                size: 20,
                color: Color(0xFFE15B4D),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
