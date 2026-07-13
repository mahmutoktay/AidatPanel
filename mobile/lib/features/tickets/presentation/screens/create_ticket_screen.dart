import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/form_step_actions.dart';
import '../../../../shared/widgets/image_source_sheet.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/tickets_provider.dart';
import '../utils/ticket_form_helpers.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_submitting) return;
    final source = await showImageSourceSheet(context);
    if (source == null || !mounted) return;
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = file.name;
      });
    } catch (_) {
      if (!mounted) return;
      final isCamera = source == ImageSource.camera;
      ref.read(toastProvider.notifier).show(
            isCamera
                ? context.t.features.profile.avatarCameraError
                : context.t.features.tickets.attachmentPickFailed,
            type: ToastType.error,
          );
    }
  }

  void _removeImage() {
    setState(() {
      _pickedImageBytes = null;
      _pickedImageName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;

    return DashboardSecondaryScaffold(
      title: t.newTicket,
      canPop: !_submitting,
      onBack: _submitting ? () {} : null,
      onFallback: () {
        ref.read(residentTabIndexProvider.notifier).update(2);
        context.go('/resident-dashboard');
      },
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _submitting,
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSizes.screenBodyScrollPadding.copyWith(
                top: AppSizes.spacingS,
                bottom: AppSizes.spacingXL,
              ),
              children: [
                MinimalTextField(
                  controller: _descriptionController,
                  label: t.fieldDescription,
                  hint: t.fieldDescriptionHint,
                  icon: Icons.notes_outlined,
                  required: true,
                  maxLines: 6,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_submitting,
                  validator: (v) {
                    final raw = v?.trim() ?? '';
                    if (raw.isEmpty) return context.t.common.fieldRequired;
                    if (raw.length < 10) return t.descriptionTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacingM),
                _AttachmentSection(
                  hint: t.attachmentHint,
                  imageBytes: _pickedImageBytes,
                  imageName: _pickedImageName,
                  onPick: _pickImage,
                  onRemove: _removeImage,
                ),
                FormStepActions(
                  primaryLabel: t.createTitle,
                  onPrimary: _submitting ? null : _submit,
                  isLoading: _submitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final apartmentId = ref.read(authStateProvider).user?.apartmentId;
    if (apartmentId == null || apartmentId.isEmpty) {
      ref.read(toastProvider.notifier).show(
            context.t.features.tickets.apartmentRequired,
            type: ToastType.error,
          );
      return;
    }

    final description = _descriptionController.text.trim();
    final title = deriveTicketTitle(description);

    setState(() => _submitting = true);
    try {
      final ok = await ref.read(ticketsNotifierProvider.notifier).createTicket(
            apartmentId: apartmentId,
            title: title,
            description: description,
            category: TicketCategory.request,
            attachmentBytes: _pickedImageBytes,
            attachmentFilename: _pickedImageName,
          );
      if (!mounted) return;
      if (ok) {
        ref.read(toastProvider.notifier).show(
              context.t.features.tickets.createSuccess,
              type: ToastType.success,
            );
        ref.read(residentTabIndexProvider.notifier).update(2);
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go('/resident-dashboard');
        }
      } else {
        final err = ref.read(ticketsNotifierProvider).error;
        ref.read(toastProvider.notifier).show(
              _createErrorMessage(err),
              type: ToastType.error,
            );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ref.read(toastProvider.notifier).show(
              userFacingError(e),
              type: ToastType.error,
            );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _createErrorMessage(String? errorKey) {
    final t = context.t.features.tickets;
    if (errorKey == null || errorKey.isEmpty) return t.createFailed;
    if (errorKey == 'service_unavailable') return t.createServiceUnavailable;
    return t.createFailed;
  }
}

class _AttachmentSection extends StatelessWidget {
  const _AttachmentSection({
    required this.hint,
    required this.imageBytes,
    required this.imageName,
    required this.onPick,
    required this.onRemove,
  });

  final String hint;
  final Uint8List? imageBytes;
  final String? imageName;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: Image.memory(
              imageBytes!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              Expanded(
                child: Text(
                  imageName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onRemove,
                child: Text(context.t.common.remove),
              ),
            ],
          ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacingL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.border),
            color: AppColors.fill,
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
