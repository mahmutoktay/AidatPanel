import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../data/sites_store.dart';

const int _kFloorsMin = 1;
const int _kFloorsMax = 200;
const int _kApartmentsPerFloorMin = 1;
const int _kApartmentsPerFloorMax = 50;

class AddSiteBuildingScreen extends ConsumerStatefulWidget {
  const AddSiteBuildingScreen({super.key, required this.siteId});

  final String siteId;

  @override
  ConsumerState<AddSiteBuildingScreen> createState() =>
      _AddSiteBuildingScreenState();
}

class _AddSiteBuildingScreenState extends ConsumerState<AddSiteBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _blockLabelController = TextEditingController();
  final _addressExtraController = TextEditingController();
  final _floorsController = TextEditingController();
  final _apartmentsPerFloorController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _blockLabelController.dispose();
    _addressExtraController.dispose();
    _floorsController.dispose();
    _apartmentsPerFloorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        appBar: AppBar(
          title: Text(t.addBlock, style: ProfileSettingsUi.title),
        ),
        bottomNavigationBar: MinimalStickyActionBar(
          label: t.addBlock,
          loading: _submitting,
          onPressed: _onSubmit,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: AppSizes.screenBodyScrollPadding,
              children: [
                MinimalTextField(
                  controller: _nameController,
                  label: context.t.common.buildingName,
                  hint: context.t.common.buildingNameHint,
                  icon: Icons.apartment_outlined,
                  required: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.t.common.fieldRequired
                      : null,
                ),
                const SizedBox(height: AppSizes.spacingFieldSpacing),
                MinimalTextField(
                  controller: _blockLabelController,
                  label: t.blockCount,
                  hint: 'A Blok',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: AppSizes.spacingFieldSpacing),
                MinimalTextField(
                  controller: _addressExtraController,
                  label: context.t.common.streetAddress,
                  hint: context.t.common.streetAddressHint,
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: AppSizes.spacingFieldSpacing),
                Row(
                  children: [
                    Expanded(
                      child: MinimalTextField(
                        controller: _floorsController,
                        label: context.t.common.floorCount,
                        hint: context.t.common.floorCountHint,
                        icon: Icons.apartment_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        required: true,
                        validator: (v) => _validateRange(
                          v,
                          min: _kFloorsMin,
                          max: _kFloorsMax,
                          rangeError: context.t.common.floorRangeError,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    Expanded(
                      child: MinimalTextField(
                        controller: _apartmentsPerFloorController,
                        label: context.t.common.apartmentsPerFloor,
                        hint: context.t.common.apartmentsPerFloorHint,
                        icon: Icons.door_front_door_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        required: true,
                        validator: (v) => _validateRange(
                          v,
                          min: _kApartmentsPerFloorMin,
                          max: _kApartmentsPerFloorMax,
                          rangeError:
                              context.t.common.apartmentsPerFloorRangeError,
                        ),
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

  String? _validateRange(
    String? value, {
    required int min,
    required int max,
    required String rangeError,
  }) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return context.t.common.fieldRequired;
    final n = int.tryParse(raw);
    if (n == null || n < min || n > max) return rangeError;
    return null;
  }

  Future<void> _onSubmit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await ref.read(siteRepositoryProvider).createSiteBuilding(
            siteId: widget.siteId,
            name: _nameController.text.trim(),
            blockLabel: _blockLabelController.text.trim(),
            addressExtra: _addressExtraController.text.trim(),
            totalFloors: int.parse(_floorsController.text.trim()),
            apartmentsPerFloor:
                int.parse(_apartmentsPerFloorController.text.trim()),
          );
      await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
      ref.invalidate(siteDetailProvider(widget.siteId));
      ref.invalidate(siteBuildingsProvider(widget.siteId));
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.features.buildings.newBuilding,
            type: ToastType.success,
          );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
          );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
