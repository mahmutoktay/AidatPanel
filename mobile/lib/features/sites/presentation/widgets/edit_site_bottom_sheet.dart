import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_entity.dart';

/// Site temel bilgilerini (ad/adres/şehir) düzenler.
class EditSiteBottomSheet extends ConsumerStatefulWidget {
  final SiteEntity site;

  const EditSiteBottomSheet({super.key, required this.site});

  static Future<void> show(
    BuildContext context, {
    required SiteEntity site,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => EditSiteBottomSheet(site: site),
    );
  }

  @override
  ConsumerState<EditSiteBottomSheet> createState() =>
      _EditSiteBottomSheetState();
}

class _EditSiteBottomSheetState extends ConsumerState<EditSiteBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site.name);
    _addressController = TextEditingController(text: widget.site.address);
    _cityController = TextEditingController(text: widget.site.city);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();

    final original = widget.site;
    final payloadName = name == original.name ? null : name;
    final payloadAddress = address == original.address ? null : address;
    final payloadCity = city == original.city ? null : city;

    if (payloadName == null && payloadAddress == null && payloadCity == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      await ref.read(sitesStoreProvider.notifier).updateSite(
            id: original.id,
            name: payloadName,
            address: payloadAddress,
            city: payloadCity,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(toastProvider.notifier).show(
            context.t.common.buildingUpdated,
            type: ToastType.success,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.buildingUpdateFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.common;

    return Form(
      key: _formKey,
      child: PremiumBottomSheetScaffold(
        title: t.editBuilding,
        scrollable: false,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MinimalTextField(
              controller: _nameController,
              label: t.buildingNameField,
              icon: Icons.location_city_outlined,
              required: true,
              enabled: !_saving,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? t.fieldRequired : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            MinimalTextField(
              controller: _addressController,
              label: t.buildingAddressField,
              icon: Icons.location_on_outlined,
              required: true,
              maxLines: 2,
              enabled: !_saving,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? t.fieldRequired : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            MinimalTextField(
              controller: _cityController,
              label: t.buildingCityField,
              icon: Icons.location_city_outlined,
              required: true,
              enabled: !_saving,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? t.fieldRequired : null,
            ),
          ],
        ),
        actions: PremiumSheetActions(
          primaryLabel: t.save,
          onPrimary: _saving ? null : _save,
          primaryLoading: _saving,
          icon: Icons.save_outlined,
          secondaryLabel: t.cancelBtn,
          onSecondary: _saving ? null : () => Navigator.of(context).pop(),
          secondaryEnabled: !_saving,
        ),
      ),
    );
  }
}
