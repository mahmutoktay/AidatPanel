import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_select_field.dart';
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
  final _descriptionController = TextEditingController();
  TicketCategory _category = TicketCategory.malfunction;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.tickets;

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(t.createTitle),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _submitting ? null : () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: AbsorbPointer(
            absorbing: _submitting,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: AppSizes.screenBodyScrollPadding,
                children: [
                  AppSelectField<TicketCategory>(
                    label: t.fieldCategory,
                    value: _category,
                    enabled: !_submitting,
                    displayText: (v) => v?.label(context) ?? '',
                    options: [
                      for (final c in TicketCategory.values)
                        AppSelectOption(value: c, label: c.label(context)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  _ModernField(
                    controller: _titleController,
                    label: t.fieldTitle,
                    hint: t.fieldTitleHint,
                    icon: Icons.edit_note_rounded,
                    validator: (v) {
                      final raw = v?.trim() ?? '';
                      if (raw.isEmpty) {
                        return context.t.common.fieldRequired;
                      }
                      if (raw.length < 3) return t.titleTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  _ModernField(
                    controller: _descriptionController,
                    label: t.fieldDescription,
                    hint: t.fieldDescriptionHint,
                    icon: Icons.subject_rounded,
                    maxLines: 5,
                    validator: (v) {
                      final raw = v?.trim() ?? '';
                      if (raw.isEmpty) {
                        return context.t.common.fieldRequired;
                      }
                      if (raw.length < 10) return t.descriptionTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                  SizedBox(
                    height: AppSizes.buttonHeightPrimary,
                    child: FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        t.submit,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
    setState(() => _submitting = true);
    try {
      final ok = await ref.read(ticketsNotifierProvider.notifier).createTicket(
            apartmentId: apartmentId,
            title: _titleController.text,
            description: _descriptionController.text,
            category: _category,
          );
      if (!mounted) return;
      if (ok) {
        ref.read(toastProvider.notifier).show(
              context.t.features.tickets.createSuccess,
              type: ToastType.success,
            );
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
              _createErrorMessage(e.message),
              type: ToastType.error,
            );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Sunucu 404 "Route not found" gibi teknik metinleri sade Türkçe'ye çevirir.
  String _createErrorMessage(String? raw) {
    final msg = raw?.trim() ?? '';
    if (msg.isEmpty) return context.t.features.tickets.createFailed;
    final lower = msg.toLowerCase();
    if (lower.contains('route') && lower.contains('not found')) {
      return context.t.features.tickets.createServiceUnavailable;
    }
    if (lower.contains('route') || lower.contains('bulunamad')) {
      return context.t.features.tickets.createServiceUnavailable;
    }
    return msg;
  }
}

class _ModernField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ModernField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: AppColors.cardBorderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: AppColors.cardBorderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }
}
