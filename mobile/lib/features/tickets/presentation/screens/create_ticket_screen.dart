import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/tickets_provider.dart';
import '../utils/ticket_labels.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketCategory _category = TicketCategory.malfunction;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  IconData _categoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.complaint:
        return Icons.report_problem_outlined;
      case TicketCategory.request:
        return Icons.help_outline_rounded;
      case TicketCategory.malfunction:
        return Icons.build_outlined;
      case TicketCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Future<void> _pickCategory() async {
    if (_submitting) return;
    final t = context.t.features.tickets;
    final picked = await showPremiumSingleSelectPicker<TicketCategory>(
      context: context,
      title: t.fieldCategory,
      selected: _category,
      options: [
        for (final category in TicketCategory.values)
          PremiumFilterPickerOption(
            value: category,
            label: category.label(context),
            icon: _categoryIcon(category),
          ),
      ],
    );
    if (picked != null && mounted) {
      setState(() => _category = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;

    return DashboardSecondaryScaffold(
      title: t.reportFaultTitle,
      canPop: !_submitting,
      onBack: _submitting ? () {} : null,
      onFallback: () {
        ref.read(residentTabIndexProvider.notifier).update(2);
        context.go('/resident-dashboard');
      },
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: AppSizes.buttonHeightPrimary,
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(t.submit),
          ),
        ),
      ),
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
                _PickerField(
                  label: t.fieldCategory,
                  value: _category.label(context),
                  onTap: _pickCategory,
                ),
                const SizedBox(height: AppSizes.spacingM),
                _LabeledField(
                  controller: _titleController,
                  label: t.fieldTitle,
                  hint: t.fieldTitleHint,
                  validator: (v) {
                    final raw = v?.trim() ?? '';
                    if (raw.isEmpty) return context.t.common.fieldRequired;
                    if (raw.length < 3) return t.titleTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacingM),
                _LabeledField(
                  controller: _detailController,
                  label: t.fieldDetail,
                  hint: t.fieldDetailHint,
                  validator: (v) {
                    final raw = v?.trim() ?? '';
                    if (raw.isEmpty) return context.t.common.fieldRequired;
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacingM),
                _LabeledField(
                  controller: _descriptionController,
                  label: t.fieldDescription,
                  hint: t.fieldDescriptionHint,
                  maxLines: 5,
                  maxLength: 500,
                  validator: (v) {
                    final raw = v?.trim() ?? '';
                    if (raw.isEmpty) return context.t.common.fieldRequired;
                    if (raw.length < 10) return t.descriptionTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacingM),
                _AttachmentPlaceholder(
                  hint: t.attachmentHint,
                  onTap: () => ref.read(toastProvider.notifier).show(
                        t.attachmentComingSoon,
                        type: ToastType.info,
                      ),
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

    final detail = _detailController.text.trim();
    final description = _descriptionController.text.trim();
    final fullDescription = detail.isEmpty
        ? description
        : '$detail\n\n$description';

    setState(() => _submitting = true);
    try {
      final ok = await ref.read(ticketsNotifierProvider.notifier).createTicket(
            apartmentId: apartmentId,
            title: _titleController.text,
            description: fullDescription,
            category: _category,
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

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.spacingXS),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingM,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: AppTypography.body1,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.spacingXS),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}

class _AttachmentPlaceholder extends StatelessWidget {
  const _AttachmentPlaceholder({
    required this.hint,
    required this.onTap,
  });

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacingL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
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
