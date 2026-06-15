import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../data/cities_data.dart';
import '../widgets/building_collection_fields.dart';

/// Backend `buildingService.createBuildingService` Zod aralıkları (Tur 5 §10/2):
///  - totalFloors: 1..200
///  - apartmentsPerFloor: 1..50
/// Backend bu aralıklar dışında 400 döner; mobile aynı kontrolü öne çekerek
/// kullanıcıya sunucu round-trip beklemeden form içi hata gösterir.
const int _kFloorsMin = 1;
const int _kFloorsMax = 200;
const int _kApartmentsPerFloorMin = 1;
const int _kApartmentsPerFloorMax = 50;

class AddBuildingScreen extends ConsumerStatefulWidget {
  const AddBuildingScreen({super.key});

  @override
  ConsumerState<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends ConsumerState<AddBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _floorsController = TextEditingController();
  final _apartmentsPerFloorController = TextEditingController();
  final _monthlyDuesController = TextEditingController();
  final _collectionIbanController = TextEditingController();
  final _collectionAccountTitleController = TextEditingController();
  final _collectionReferenceTemplateController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;

  /// Submit edildiğinde buton disable'lanır + loading gösterilir.
  /// Aynı submit boyunca PopScope geri tuşunu da bastırır; aksi halde
  /// 50+ kullanıcı kazara back basınca create yarıda kalıp yarım state
  /// oluşur (bina yaratıldı ama daireler seed edilmedi gibi).
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _floorsController.dispose();
    _apartmentsPerFloorController.dispose();
    _monthlyDuesController.dispose();
    _collectionIbanController.dispose();
    _collectionAccountTitleController.dispose();
    _collectionReferenceTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: DashboardSecondaryScaffold(
        title: context.t.common.addBuildingNew,
        onBack: _submitting ? () {} : () => context.pop(),
        bottomNavigationBar: _buildSaveBar(context),
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
                  DashboardSectionTitle(title: context.t.common.basicInfo),
                  const SizedBox(height: AppSizes.spacingS),
                  _FormSectionCard(
                    child: _buildTextField(
                      controller: _nameController,
                      label: context.t.common.buildingName,
                      hint: context.t.common.buildingNameHint,
                      icon: Icons.apartment,
                      required: true,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  DashboardSectionTitle(title: context.t.common.location),
                  const SizedBox(height: AppSizes.spacingS),
                  _FormSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCityPicker(),
                        const SizedBox(height: AppSizes.spacingM),
                        _buildDistrictPicker(),
                        const SizedBox(height: AppSizes.spacingM),
                        _buildTextField(
                          controller: _addressController,
                          label: context.t.common.streetAddress,
                          hint: context.t.common.streetAddressHint,
                          icon: Icons.home_outlined,
                          required: true,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  DashboardSectionTitle(title: context.t.common.details),
                  const SizedBox(height: AppSizes.spacingS),
                  _FormSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _floorsController,
                                label: context.t.common.floorCount,
                                hint: context.t.common.floorCountHint,
                                icon: Icons.stairs_outlined,
                                required: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) => _validateRange(
                                  v,
                                  min: _kFloorsMin,
                                  max: _kFloorsMax,
                                  rangeError: context.t.common.floorRangeError,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.spacingM),
                            Expanded(
                              child: _buildTextField(
                                controller: _apartmentsPerFloorController,
                                label: context.t.common.apartmentsPerFloor,
                                hint: context.t.common.apartmentsPerFloorHint,
                                icon: Icons.door_front_door_outlined,
                                required: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) => _validateRange(
                                  v,
                                  min: _kApartmentsPerFloorMin,
                                  max: _kApartmentsPerFloorMax,
                                  rangeError: context
                                      .t.common.apartmentsPerFloorRangeError,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacingM),
                        _buildTextField(
                          controller: _monthlyDuesController,
                          label: context.t.common.monthlyDuesLabel,
                          hint: context.t.common.monthlyDuesHint,
                          icon: Icons.payments_outlined,
                          required: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  DashboardSectionTitle(
                    title: context.t.features.buildings.collection.sectionTitle,
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  _FormSectionCard(
                    child: BuildingCollectionFields(
                      ibanController: _collectionIbanController,
                      accountTitleController: _collectionAccountTitleController,
                      referenceTemplateController:
                          _collectionReferenceTemplateController,
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

  Widget _buildSaveBar(BuildContext context) {
    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: ProfileSettingsUi.buttonHeight,
          child: ElevatedButton(
            onPressed: _submitting ? null : _onSubmit,
            style: ProfileSettingsUi.primaryButton,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(context.t.common.createBuilding),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: ProfileSettingsUi.fieldValue,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: ProfileSettingsUi.fieldLabel,
        hintText: hint,
        hintStyle: ProfileSettingsUi.fieldLabel,
        prefixIcon: Icon(icon, color: ProfileSettingsUi.ink),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: AppColors.cardBorderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: AppColors.cardBorderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? context.t.common.fieldRequired
                  : null
              : null),
    );
  }

  /// Sayısal alan için zorunlu + aralık kontrolü.
  /// Boş ise [fieldRequired], parse edilemez veya aralık dışıysa [rangeError]
  /// döndürür. Backend Zod kuralları ile birebir uyumlu olsun diye
  /// kullanılır.
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

  Widget _buildCityPicker() {
    return _buildDropdownField(
      label: context.t.common.cityRequired,
      value: _selectedCity,
      hint: context.t.common.selectCity,
      icon: Icons.location_city,
      onTap: _showCityPicker,
    );
  }

  Widget _buildDistrictPicker() {
    final hasCity = _selectedCity != null;
    return _buildDropdownField(
      label: context.t.common.districtRequired,
      value: _selectedDistrict,
      hint: hasCity
          ? context.t.common.selectDistrict
          : context.t.common.selectCityFirst,
      icon: Icons.map_outlined,
      enabled: hasCity,
      onTap: hasCity ? _showDistrictPicker : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              color: enabled ? ProfileSettingsUi.ink : AppColors.textDisabled,
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
            ),
            filled: true,
            fillColor: enabled
                ? Colors.white
                : AppColors.textDisabled.withValues(alpha: 0.12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: AppColors.cardBorderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: AppColors.cardBorderSide,
            ),
          ),
          child: Text(
            value ?? hint,
            style: ProfileSettingsUi.fieldValue.copyWith(
              color: value != null
                  ? ProfileSettingsUi.ink
                  : ProfileSettingsUi.muted,
              fontWeight: value != null ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: AppButtonStyles.sheetTop,
      builder: (ctx) => _SearchablePicker(
        title: context.t.common.selectCityTitle,
        items: sortedCityNames,
        selected: _selectedCity,
        onSelected: (city) {
          setState(() {
            _selectedCity = city;
            _selectedDistrict = null; // şehir değiştiğinde ilçe sıfırlanır
          });
        },
      ),
    );
  }

  void _showDistrictPicker() {
    final districts = turkishCities[_selectedCity] ?? const [];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: AppButtonStyles.sheetTop,
      builder: (ctx) => _SearchablePicker(
        title: context.t.common.selectDistrictTitle,
        items: districts,
        selected: _selectedDistrict,
        onSelected: (district) {
          setState(() => _selectedDistrict = district);
        },
      ),
    );
  }

  Future<void> _onSubmit() async {
    // Hızlı dürtüklenme + yarı yarıya işlenmiş submit'e karşı koruma.
    // Notifier seviyesinde de aynı guard var (BuildingsNotifier._isCreating);
    // bu UI guard'ı kullanıcıya görsel feedback sağlar (buton disable + spinner).
    if (_submitting) return;

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) {
      ref
          .read(toastProvider.notifier)
          .show(context.t.common.fillRequiredFields, type: ToastType.error);
      return;
    }
    if (_selectedCity == null || _selectedDistrict == null) {
      ref
          .read(toastProvider.notifier)
          .show(context.t.common.selectCityAndDistrict, type: ToastType.error);
      return;
    }

    // Form validator zaten range + parse kontrolü yaptığı için burada
    // tryParse'lar güvenli (null gelmez). Yine de defansif fallback'le
    // okuyup runtime patlamasını önlüyoruz.
    final floors = int.tryParse(_floorsController.text.trim()) ?? 0;
    final apartmentsPerFloor =
        int.tryParse(_apartmentsPerFloorController.text.trim()) ?? 0;
    final dueAmount =
        double.tryParse(_monthlyDuesController.text.trim()) ?? 0;

    if (dueAmount <= 0) {
      ref.read(toastProvider.notifier).show(
            context.t.common.fillRequiredFields,
            type: ToastType.error,
          );
      return;
    }

    setState(() => _submitting = true);
    try {
      final address =
          '${_addressController.text.trim()}, $_selectedDistrict';

      // Backend `buildingService.createBuildingService` (commit 8cc2152)
      // tek transaction içinde:
      //   1. Building kaydı oluşturur
      //   2. totalFloors × apartmentsPerFloor adet daire (1A, 1B, 2A …) seed eder
      //   3. dueAmount > 0 ise her daire için içinde bulunulan aydan yıl
      //      sonuna kadar PENDING due üretir
      // Bu yüzden mobile artık ekstra "fallback seed loop" çalıştırmaz —
      // eski Tur 1-3 sürümünde yapılan _seedApartmentsIfNeeded kaldırıldı.
      final collection = BuildingCollectionInput.fromControllers(
        iban: _collectionIbanController,
        accountTitle: _collectionAccountTitleController,
        referenceTemplate: _collectionReferenceTemplateController,
      );

      final id = await ref.read(buildingsStoreProvider.notifier).addBuilding(
            name: _nameController.text.trim(),
            address: address,
            city: _selectedCity!,
            totalFloors: floors,
            apartmentsPerFloor: apartmentsPerFloor,
            dueAmount: dueAmount,
            dueDay: 1,
            currency: 'TRY',
            collectionIban: collection?.collectionIban,
            collectionAccountTitle: collection?.collectionAccountTitle,
            paymentReferenceTemplate: collection?.paymentReferenceTemplate,
          );

      if (!mounted) return;
      if (id == null) {
        ref.read(toastProvider.notifier).show(
              context.t.common.buildingAddFailed,
              type: ToastType.error,
            );
        return;
      }

      ref
          .read(toastProvider.notifier)
          .show(context.t.common.buildingAddedSuccess, type: ToastType.success);
      context.pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _FormSectionCard extends StatelessWidget {
  final Widget child;

  const _FormSectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(),
      child: child,
    );
  }
}

/// Aranabilir liste seçici (şehir veya ilçe için)
class _SearchablePicker extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _SearchablePicker({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<_SearchablePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.dashboardScreenPaddingHorizontal,
              vertical: AppSizes.spacingS,
            ),
            child: Text(
              widget.title,
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.dashboardScreenPaddingHorizontal,
              vertical: AppSizes.spacingS,
            ),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: context.t.common.search,
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.dashboardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      context.t.common.noResults,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final item = filtered[index];
                      final isSelected = item == widget.selected;
                      return ListTile(
                        title: Text(
                          item,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: AppColors.success)
                            : null,
                        onTap: () {
                          widget.onSelected(item);
                          context.pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
