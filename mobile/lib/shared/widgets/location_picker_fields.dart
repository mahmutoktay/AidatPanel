import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locations/location_models.dart';
import '../../core/locations/location_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../l10n/strings.g.dart';
import 'minimal_form_widgets.dart';
import 'toast_overlay.dart';
import 'location_picker_sheet.dart';

/// İl / ilçe / (opsiyonel) mahalle seçici alanları.
class LocationPickerFields extends ConsumerStatefulWidget {
  final Province? selectedProvince;
  final District? selectedDistrict;
  final Neighborhood? selectedNeighborhood;
  final ValueChanged<Province?> onProvinceChanged;
  final ValueChanged<District?> onDistrictChanged;
  final ValueChanged<Neighborhood?>? onNeighborhoodChanged;
  final bool showNeighborhood;
  final bool showCity;
  final bool showDistrict;
  final bool enabled;

  const LocationPickerFields({
    super.key,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    this.selectedNeighborhood,
    this.onNeighborhoodChanged,
    this.showNeighborhood = false,
    this.showCity = true,
    this.showDistrict = true,
    this.enabled = true,
  });

  @override
  ConsumerState<LocationPickerFields> createState() =>
      _LocationPickerFieldsState();
}

class _LocationPickerFieldsState extends ConsumerState<LocationPickerFields> {
  List<Province> _provinces = const [];
  List<District> _districts = const [];
  List<Neighborhood> _neighborhoods = const [];
  bool _loadingProvinces = true;
  bool _loadingNeighborhoods = false;

  @override
  void initState() {
    super.initState();
    if (widget.showNeighborhood &&
        !widget.showCity &&
        widget.selectedDistrict != null) {
      _loadNeighborhoods();
    } else {
      _loadProvinces();
    }
  }

  @override
  void didUpdateWidget(covariant LocationPickerFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedProvince?.id != widget.selectedProvince?.id) {
      _loadDistricts();
    }
    if (oldWidget.selectedDistrict?.id != widget.selectedDistrict?.id &&
        widget.showNeighborhood) {
      _loadNeighborhoods();
    }
  }

  Future<void> _loadProvinces() async {
    setState(() => _loadingProvinces = true);
    try {
      final repo = ref.read(locationRepositoryProvider);
      final provinces = await repo.getProvinces();
      if (!mounted) return;
      setState(() {
        _provinces = provinces;
        _loadingProvinces = false;
      });
      await _loadDistricts();
      if (widget.showNeighborhood) {
        await _loadNeighborhoods();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingProvinces = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.wizardLocationLoadFailed,
            type: ToastType.error,
          );
    }
  }

  Future<void> _loadDistricts() async {
    final province = widget.selectedProvince;
    if (province == null) {
      setState(() => _districts = const []);
      return;
    }
    try {
      final districts = await ref
          .read(locationRepositoryProvider)
          .getDistrictsForProvince(province.id);
      if (!mounted) return;
      setState(() => _districts = districts);
    } catch (_) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.common.wizardLocationLoadFailed,
            type: ToastType.error,
          );
    }
  }

  Future<void> _loadNeighborhoods() async {
    final district = widget.selectedDistrict;
    if (district == null || !widget.showNeighborhood) {
      setState(() {
        _neighborhoods = const [];
        _loadingNeighborhoods = false;
      });
      return;
    }
    setState(() => _loadingNeighborhoods = true);
    try {
      final neighborhoods = await ref
          .read(locationRepositoryProvider)
          .getNeighborhoodsForDistrict(district.id);
      if (!mounted) return;
      setState(() {
        _neighborhoods = neighborhoods;
        _loadingNeighborhoods = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingNeighborhoods = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.wizardNeighborhoodLoadFailed,
            type: ToastType.error,
          );
    }
  }

  Future<void> _showProvincePicker() async {
    if (!widget.enabled || _loadingProvinces) return;
    await LocationPickerSheet.show(
      context,
      title: context.t.common.selectCityTitle,
      items: _provinces.map((p) => p.name).toList(),
      selected: widget.selectedProvince?.name,
      onSelected: (name) {
        final province = _provinces.firstWhere((p) => p.name == name);
        widget.onProvinceChanged(province);
        widget.onDistrictChanged(null);
        widget.onNeighborhoodChanged?.call(null);
      },
    );
  }

  Future<void> _showDistrictPicker() async {
    if (!widget.enabled || widget.selectedProvince == null) return;
    await LocationPickerSheet.show(
      context,
      title: context.t.common.selectDistrictTitle,
      items: _districts.map((d) => d.name).toList(),
      selected: widget.selectedDistrict?.name,
      onSelected: (name) {
        final district = _districts.firstWhere((d) => d.name == name);
        widget.onDistrictChanged(district);
        widget.onNeighborhoodChanged?.call(null);
        _loadNeighborhoods();
      },
    );
  }

  Future<void> _showNeighborhoodPicker() async {
    if (!widget.enabled ||
        widget.selectedDistrict == null ||
        _loadingNeighborhoods) {
      return;
    }
    if (_neighborhoods.isEmpty && !_loadingNeighborhoods) {
      await _loadNeighborhoods();
    }
    if (!mounted || _neighborhoods.isEmpty) return;
    await LocationPickerSheet.show(
      context,
      title: context.t.common.selectNeighborhoodTitle,
      items: _neighborhoods.map((n) => n.name).toList(),
      selected: widget.selectedNeighborhood?.name,
      onSelected: (name) {
        final neighborhood = _neighborhoods.firstWhere((n) => n.name == name);
        widget.onNeighborhoodChanged?.call(neighborhood);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showCity) ...[
          MinimalPickerField(
            label: context.t.common.cityRequired.replaceAll(' *', ''),
            value: widget.selectedProvince?.name,
            hint: _loadingProvinces
                ? context.t.common.loading
                : context.t.common.selectCity,
            icon: Icons.location_on_outlined,
            iconColor: AppColors.info,
            required: true,
            enabled: widget.enabled && !_loadingProvinces,
            onTap: _showProvincePicker,
          ),
          const SizedBox(height: AppSizes.spacingFieldSpacing),
        ],
        if (widget.showDistrict) ...[
          MinimalPickerField(
            label: context.t.common.districtRequired.replaceAll(' *', ''),
            value: widget.selectedDistrict?.name,
            hint: widget.selectedProvince != null
                ? context.t.common.selectDistrict
                : context.t.common.selectCityFirst,
            icon: Icons.map_outlined,
            required: true,
            enabled: widget.enabled && widget.selectedProvince != null,
            onTap: widget.selectedProvince != null ? _showDistrictPicker : null,
          ),
          if (widget.showNeighborhood)
            const SizedBox(height: AppSizes.spacingFieldSpacing),
        ],
        if (widget.showNeighborhood) ...[
          MinimalPickerField(
            label: context.t.common.neighborhoodRequired.replaceAll(' *', ''),
            value: widget.selectedNeighborhood?.name,
            hint: widget.selectedDistrict != null
                ? (_loadingNeighborhoods
                    ? context.t.common.loading
                    : context.t.common.selectNeighborhood)
                : context.t.common.selectDistrictFirst,
            icon: Icons.home_work_outlined,
            required: true,
            enabled: widget.enabled &&
                widget.selectedDistrict != null &&
                !_loadingNeighborhoods,
            onTap: widget.selectedDistrict != null
                ? _showNeighborhoodPicker
                : null,
          ),
        ],
      ],
    );
  }
}
