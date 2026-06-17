import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_filter_chips_row.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
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
      child: DashboardSecondaryScaffold(
        title: t.createTitle,
        onBack: _submitting ? () {} : () => context.pop(),
        bottomNavigationBar: MinimalStickyActionBar(
          label: t.submit,
          onPressed: _submit,
          loading: _submitting,
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
                  DashboardSectionTitle(title: t.fieldCategory),
                  const SizedBox(height: AppSizes.spacingS),
                  DashboardFilterChipsRow(
                    enabled: !_submitting,
                    chips: [
                      for (final c in TicketCategory.values)
                        DashboardFilterChipItem(
                          label: c.label(context),
                          selected: _category == c,
                          onTap: () => setState(() => _category = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  MinimalTextField(
                    controller: _titleController,
                    label: t.fieldTitle,
                    hint: t.fieldTitleHint,
                    icon: Icons.title_rounded,
                    required: true,
                    enabled: !_submitting,
                    textCapitalization: TextCapitalization.sentences,
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
                  MinimalTextField(
                    controller: _descriptionController,
                    label: t.fieldDescription,
                    hint: t.fieldDescriptionHint,
                    icon: Icons.description_rounded,
                    maxLines: 5,
                    required: true,
                    enabled: !_submitting,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) {
                      final raw = v?.trim() ?? '';
                      if (raw.isEmpty) {
                        return context.t.common.fieldRequired;
                      }
                      if (raw.length < 10) return t.descriptionTooShort;
                      return null;
                    },
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
              userFacingError(e),
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
    return userFacingError(ApiException(message: msg));
  }
}
