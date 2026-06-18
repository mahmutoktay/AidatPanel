import 'package:flutter/material.dart';

import '../../core/theme/app_color_palette.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_date_picker_theme.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/month_labels.dart';
import '../../l10n/strings.g.dart';

const _wheelItemExtent = 48.0;
const _wheelHeight = 200.0;

enum _PickerView { calendar, spinner }

/// Android tarzı hibrit tarih seçici: ay grid + kaydırma + başlıkta çark.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final first = DateTime(firstDate.year, firstDate.month, firstDate.day);
  final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
  final clampedInitial = _clampDate(initialDate, firstDate: first, lastDate: last);

  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) => Theme(
      data: Theme.of(dialogContext).copyWith(
        dialogTheme: AppDatePickerTheme.dialogTheme(
          Theme.of(dialogContext).dialogTheme,
          AppColors.isDark ? AppColorPalette.dark : AppColorPalette.light,
        ),
      ),
      child: _HybridDatePickerDialog(
        initialDate: clampedInitial,
        firstDate: first,
        lastDate: last,
      ),
    ),
  );
}

DateTime _clampDate(
  DateTime value, {
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final d = DateTime(value.year, value.month, value.day);
  if (d.isBefore(firstDate)) return firstDate;
  if (d.isAfter(lastDate)) return lastDate;
  return d;
}

int _monthIndex(DateTime anchor, DateTime target) {
  return (target.year - anchor.year) * 12 + (target.month - anchor.month);
}

DateTime _monthFromIndex(DateTime anchor, int index) {
  final total = anchor.month - 1 + index;
  return DateTime(anchor.year + total ~/ 12, total % 12 + 1);
}

class _HybridDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _HybridDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_HybridDatePickerDialog> createState() => _HybridDatePickerDialogState();
}

class _HybridDatePickerDialogState extends State<_HybridDatePickerDialog> {
  late DateTime _selected;
  late DateTime _anchorMonth;
  late int _monthCount;
  late PageController _monthPageController;

  _PickerView _view = _PickerView.calendar;

  late int _wheelYear;
  late int _wheelMonth;
  late int _wheelDay;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _anchorMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    _monthCount = _monthIndex(_anchorMonth, widget.lastDate) + 1;
    _monthPageController = PageController(
      initialPage: _monthIndex(_anchorMonth, _selected).clamp(0, _monthCount - 1),
    );
    _monthPageController.addListener(() {
      if (_view == _PickerView.calendar && mounted) setState(() {});
    });
    _initWheelControllers();
  }

  void _initWheelControllers() {
    _wheelYear = _selected.year;
    _wheelMonth = _selected.month;
    _wheelDay = _clampWheelDay(_selected.day);
    _dayController = FixedExtentScrollController(initialItem: _wheelDay - _wheelMinDay());
    _monthController = FixedExtentScrollController(initialItem: _wheelMonth - 1);
    _yearController = FixedExtentScrollController(
      initialItem: _wheelYear - widget.firstDate.year,
    );
  }

  @override
  void dispose() {
    _monthPageController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int get _displayMonthIndex =>
      _monthPageController.hasClients
          ? _monthPageController.page?.round() ??
              _monthIndex(_anchorMonth, _selected)
          : _monthIndex(_anchorMonth, _selected);

  DateTime get _displayMonth => _monthFromIndex(_anchorMonth, _displayMonthIndex);

  List<int> get _years => [
        for (var y = widget.firstDate.year; y <= widget.lastDate.year; y++) y,
      ];

  int _wheelMinDay() {
    if (_wheelYear == widget.firstDate.year && _wheelMonth == widget.firstDate.month) {
      return widget.firstDate.day;
    }
    return 1;
  }

  int _wheelMaxDay() {
    final end = DateTime(_wheelYear, _wheelMonth + 1, 0).day;
    if (_wheelYear == widget.lastDate.year && _wheelMonth == widget.lastDate.month) {
      return widget.lastDate.day.clamp(1, end);
    }
    return end;
  }

  int _clampWheelDay(int day) => day.clamp(_wheelMinDay(), _wheelMaxDay());

  void _syncWheelFromSelected() {
    _wheelYear = _selected.year;
    _wheelMonth = _selected.month;
    _wheelDay = _clampWheelDay(_selected.day);
    _dayController.jumpToItem(_wheelDay - _wheelMinDay());
    _monthController.jumpToItem(_wheelMonth - 1);
    _yearController.jumpToItem(_wheelYear - widget.firstDate.year);
  }

  void _applyWheelToSelected() {
    setState(() {
      _selected = DateTime(_wheelYear, _wheelMonth, _wheelDay);
    });
    final page = _monthIndex(_anchorMonth, _selected).clamp(0, _monthCount - 1);
    if (_monthPageController.hasClients) {
      _monthPageController.jumpToPage(page);
    }
  }

  void _toggleView() {
    setState(() {
      if (_view == _PickerView.calendar) {
        _syncWheelFromSelected();
        _view = _PickerView.spinner;
      } else {
        _applyWheelToSelected();
        _view = _PickerView.calendar;
      }
    });
  }

  void _selectDay(DateTime day) {
    if (_isDisabled(day)) return;
    setState(() => _selected = day);
  }

  bool _isDisabled(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return d.isBefore(widget.firstDate) || d.isAfter(widget.lastDate);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isWeekendColumn(int columnIndex) {
    // Pzt=0 … Paz=6
    return columnIndex >= 5;
  }

  void _shiftMonth(int delta) {
    final next = (_displayMonthIndex + delta).clamp(0, _monthCount - 1);
    _monthPageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _onWheelYear(int index) {
    setState(() {
      _wheelYear = _years[index];
      _wheelDay = _clampWheelDay(_wheelDay);
    });
    _jumpDayWheel();
  }

  void _onWheelMonth(int index) {
    setState(() {
      _wheelMonth = index + 1;
      _wheelDay = _clampWheelDay(_wheelDay);
    });
    _jumpDayWheel();
  }

  void _onWheelDay(int index) {
    setState(() => _wheelDay = _wheelMinDay() + index);
  }

  void _jumpDayWheel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dayController.hasClients) return;
      final target = (_wheelDay - _wheelMinDay()).clamp(0, _wheelMaxDay() - _wheelMinDay());
      if (_dayController.selectedItem != target) {
        _dayController.jumpToItem(target);
      }
    });
  }

  String _monthYearTitle(BuildContext context, DateTime month) {
    return '${localizedMonthName(context, month.month)} ${month.year}';
  }

  String _monthAbbrev(BuildContext context, int month) {
    final name = localizedMonthName(context, month);
    final len = name.length >= 3 ? 3 : name.length;
    return name.substring(0, len).toUpperCase();
  }

  List<String> _weekdayLabels(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final labels = material.narrowWeekdays;
    final first = material.firstDayOfWeekIndex;
    final rotated = [...labels.sublist(first), ...labels.sublist(0, first)];
    return rotated.map((e) => e.toUpperCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.common;
    final titleMonth = _view == _PickerView.calendar
        ? _displayMonth
        : DateTime(_wheelYear, _wheelMonth);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingM,
          AppSizes.spacingM,
          AppSizes.spacingM,
          AppSizes.spacingS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_view == _PickerView.calendar) _CalendarHeaderBar(selected: _selected),
            const SizedBox(height: AppSizes.spacingS),
            _MonthTitleBar(
              title: _monthYearTitle(context, titleMonth),
              showArrows: _view == _PickerView.calendar,
              onTitleTap: _toggleView,
              onPrevious: () => _shiftMonth(-1),
              onNext: () => _shiftMonth(1),
              canGoPrevious: _displayMonthIndex > 0,
              canGoNext: _displayMonthIndex < _monthCount - 1,
            ),
            const SizedBox(height: AppSizes.spacingS),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _view == _PickerView.calendar
                  ? _CalendarBody(
                      key: const ValueKey('calendar'),
                      pageController: _monthPageController,
                      monthCount: _monthCount,
                      anchorMonth: _anchorMonth,
                      selected: _selected,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      weekdayLabels: _weekdayLabels(context),
                      isWeekendColumn: _isWeekendColumn,
                      isSameDay: _isSameDay,
                      isDisabled: _isDisabled,
                      onDaySelected: _selectDay,
                    )
                  : _SpinnerBody(
                      key: const ValueKey('spinner'),
                      dayController: _dayController,
                      monthController: _monthController,
                      yearController: _yearController,
                      dayCount: _wheelMaxDay() - _wheelMinDay() + 1,
                      minDay: _wheelMinDay(),
                      years: _years,
                      monthAbbrev: (m) => _monthAbbrev(context, m),
                      onDayChanged: _onWheelDay,
                      onMonthChanged: _onWheelMonth,
                      onYearChanged: _onWheelYear,
                    ),
            ),
            const SizedBox(height: AppSizes.spacingXS),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.cancel),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (_view == _PickerView.spinner) {
                        _applyWheelToSelected();
                      }
                      Navigator.of(context).pop(_selected);
                    },
                    child: Text(t.ok),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeaderBar extends StatelessWidget {
  final DateTime selected;

  const _CalendarHeaderBar({required this.selected});

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final weekday = material.formatShortMonthDay(selected);
    return Row(
      children: [
        Expanded(
          child: Text(
            weekday,
            style: AppTypography.body2.copyWith(color: AppColors.textPrimary),
          ),
        ),
        Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
      ],
    );
  }
}

class _MonthTitleBar extends StatelessWidget {
  final String title;
  final bool showArrows;
  final VoidCallback onTitleTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;

  const _MonthTitleBar({
    required this.title,
    required this.showArrows,
    required this.onTitleTap,
    required this.onPrevious,
    required this.onNext,
    required this.canGoPrevious,
    required this.canGoNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showArrows)
          _NavIconButton(
            icon: Icons.chevron_left,
            onPressed: canGoPrevious ? onPrevious : null,
          )
        else
          const SizedBox(width: AppSizes.minTouchTarget),
        Expanded(
          child: Material(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTitleTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingM,
                  vertical: AppSizes.spacingS,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showArrows)
          _NavIconButton(
            icon: Icons.chevron_right,
            onPressed: canGoNext ? onNext : null,
          )
        else
          const SizedBox(width: AppSizes.minTouchTarget),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavIconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.minTouchTarget,
      height: AppSizes.minTouchTarget,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CalendarBody extends StatelessWidget {
  final PageController pageController;
  final int monthCount;
  final DateTime anchorMonth;
  final DateTime selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<String> weekdayLabels;
  final bool Function(int columnIndex) isWeekendColumn;
  final bool Function(DateTime a, DateTime b) isSameDay;
  final bool Function(DateTime day) isDisabled;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarBody({
    super.key,
    required this.pageController,
    required this.monthCount,
    required this.anchorMonth,
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.weekdayLabels,
    required this.isWeekendColumn,
    required this.isSameDay,
    required this.isDisabled,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    weekdayLabels[i],
                    style: AppTypography.caption.copyWith(
                      color: isWeekendColumn(i)
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingXS),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: pageController,
            itemCount: monthCount,
            itemBuilder: (context, pageIndex) {
              final month = _monthFromIndex(anchorMonth, pageIndex);
              return _MonthGrid(
                month: month,
                selected: selected,
                isSameDay: isSameDay,
                isDisabled: isDisabled,
                isWeekendColumn: isWeekendColumn,
                onDaySelected: onDaySelected,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final bool Function(DateTime a, DateTime b) isSameDay;
  final bool Function(DateTime day) isDisabled;
  final bool Function(int columnIndex) isWeekendColumn;
  final ValueChanged<DateTime> onDaySelected;

  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.isSameDay,
    required this.isDisabled,
    required this.isWeekendColumn,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final leading = firstOfMonth.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final prevMonthDays = DateTime(month.year, month.month, 0).day;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        late DateTime day;
        late bool outsideMonth;

        if (index < leading) {
          final d = prevMonthDays - leading + index + 1;
          day = DateTime(month.year, month.month - 1, d);
          outsideMonth = true;
        } else if (index < leading + daysInMonth) {
          final d = index - leading + 1;
          day = DateTime(month.year, month.month, d);
          outsideMonth = false;
        } else {
          final d = index - leading - daysInMonth + 1;
          day = DateTime(month.year, month.month + 1, d);
          outsideMonth = true;
        }

        final col = index % 7;
        final disabled = isDisabled(day);
        final isSelected = isSameDay(day, selected);
        final isWeekend = isWeekendColumn(col);

        Color textColor;
        if (disabled || outsideMonth) {
          textColor = AppColors.textDisabled;
        } else if (isWeekend) {
          textColor = AppColors.error;
        } else {
          textColor = AppColors.textPrimary;
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : () => onDaySelected(day),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              alignment: Alignment.center,
              decoration: isSelected && !disabled
                  ? BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${day.day}',
                style: AppTypography.body1.copyWith(
                  color: isSelected && !disabled ? Colors.white : textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpinnerBody extends StatelessWidget {
  final FixedExtentScrollController dayController;
  final FixedExtentScrollController monthController;
  final FixedExtentScrollController yearController;
  final int dayCount;
  final int minDay;
  final List<int> years;
  final String Function(int month) monthAbbrev;
  final ValueChanged<int> onDayChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const _SpinnerBody({
    super.key,
    required this.dayController,
    required this.monthController,
    required this.yearController,
    required this.dayCount,
    required this.minDay,
    required this.years,
    required this.monthAbbrev,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _wheelHeight + AppSizes.spacingM,
      child: Row(
        children: [
          Expanded(
            child: _DateWheel(
              controller: dayController,
              itemCount: dayCount,
              onChanged: onDayChanged,
              itemBuilder: (index) => '${minDay + index}',
            ),
          ),
          Expanded(
            child: _DateWheel(
              controller: monthController,
              itemCount: 12,
              onChanged: onMonthChanged,
              itemBuilder: (index) => monthAbbrev(index + 1),
            ),
          ),
          Expanded(
            child: _DateWheel(
              controller: yearController,
              itemCount: years.length,
              onChanged: onYearChanged,
              itemBuilder: (index) => '${years[index]}',
            ),
          ),
        ],
      ),
    );
  }
}

class _DateWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final ValueChanged<int> onChanged;
  final String Function(int index) itemBuilder;

  const _DateWheel({
    required this.controller,
    required this.itemCount,
    required this.onChanged,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _wheelHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: _wheelItemExtent,
            diameterRatio: 1.35,
            perspective: 0.003,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                if (index < 0 || index >= itemCount) return null;
                final selected = controller.selectedItem == index;
                return Center(
                  child: Text(
                    itemBuilder(index),
                    style: AppTypography.body1.copyWith(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          IgnorePointer(
            child: Container(
              height: _wheelItemExtent,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                border: Border(
                  top: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
