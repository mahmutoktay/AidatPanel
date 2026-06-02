import 'package:flutter/material.dart';

const _metricTextHeightBehavior = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);

/// Hero metrik değerleri — alarm-saati tarzı dikey kaydırmalı rakamlar.
class RollingMetricValue extends StatefulWidget {
  final num target;
  final String? prefix;
  final TextStyle style;
  final Color? color;
  final bool animate;

  static const Duration totalDuration = Duration(milliseconds: 1000);
  static const Duration columnStagger = Duration(milliseconds: 80);

  const RollingMetricValue({
    super.key,
    required this.target,
    required this.style,
    this.prefix,
    this.color,
    this.animate = true,
  });

  /// [DashboardMetricTile] value satırı ile uyumlu sabit yükseklik.
  static double measureSlotHeight(TextStyle style) {
    final digitStyle = style.copyWith(height: 1.0);
    final painter = TextPainter(
      text: TextSpan(text: '8', style: digitStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textHeightBehavior: _metricTextHeightBehavior,
    )..layout();
    final fontSize = digitStyle.fontSize ?? 14;
    return painter.height.ceilToDouble().clamp(fontSize, fontSize * 1.4);
  }

  @override
  State<RollingMetricValue> createState() => _RollingMetricValueState();
}

class _RollingMetricValueState extends State<RollingMetricValue> {
  late int _fromValue;
  late int _toValue;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _fromValue = 0;
    _toValue = _roundedTarget;
  }

  @override
  void didUpdateWidget(RollingMetricValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _roundedTarget;
    if (oldWidget.target != widget.target) {
      _fromValue = _toValue;
      _toValue = next;
      _generation++;
    }
  }

  int get _roundedTarget => widget.target.round();

  TextStyle get _digitStyle {
    final base = widget.color == null
        ? widget.style
        : widget.style.copyWith(color: widget.color);
    return base.copyWith(height: 1.0);
  }

  TextStyle get _prefixStyle {
    final base = widget.color == null
        ? widget.style
        : widget.style.copyWith(color: widget.color);
    return base.copyWith(height: 1.0);
  }

  double _digitColumnWidth(TextStyle digitStyle) {
    final painter = TextPainter(
      text: TextSpan(text: '8', style: digitStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textHeightBehavior: _metricTextHeightBehavior,
    )..layout();
    return painter.width.ceilToDouble();
  }

  bool _shouldAnimate(BuildContext context) {
    if (!widget.animate) return false;
    return !MediaQuery.disableAnimationsOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final digitStyle = _digitStyle;
    final slotHeight = RollingMetricValue.measureSlotHeight(widget.style);

    if (!_shouldAnimate(context)) {
      return _StaticMetricText(
        prefix: widget.prefix,
        value: _toValue,
        style: digitStyle,
        lineHeight: slotHeight,
      );
    }

    final digitCount = _digitCount(_fromValue, _toValue);
    final fromDigits = _digitsFor(_fromValue, digitCount);
    final toDigits = _digitsFor(_toValue, digitCount);
    final columnWidth = _digitColumnWidth(digitStyle);

    return SizedBox(
      height: slotHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.prefix != null)
            Padding(
              padding: const EdgeInsets.only(right: 1),
              child: Text(
                widget.prefix!,
                style: _prefixStyle,
                textHeightBehavior: _metricTextHeightBehavior,
              ),
            ),
          for (var i = 0; i < digitCount; i++)
            _DigitReel(
              key: ValueKey('$_generation-$i-${fromDigits[i]}-${toDigits[i]}'),
              fromDigit: fromDigits[i],
              toDigit: toDigits[i],
              style: digitStyle,
              slotHeight: slotHeight,
              columnWidth: columnWidth,
              delay: RollingMetricValue.columnStagger * i,
              duration: RollingMetricValue.totalDuration,
            ),
        ],
      ),
    );
  }

  static int _digitCount(int from, int to) {
    final fromLen = from.abs().toString().length;
    final toLen = to.abs().toString().length;
    final maxLen = fromLen > toLen ? fromLen : toLen;
    return maxLen < 1 ? 1 : maxLen;
  }

  static List<int> _digitsFor(int value, int width) {
    final text = value.abs().toString().padLeft(width, '0');
    return text.split('').map(int.parse).toList(growable: false);
  }
}

class _StaticMetricText extends StatelessWidget {
  final String? prefix;
  final int value;
  final TextStyle style;
  final double lineHeight;

  const _StaticMetricText({
    required this.prefix,
    required this.value,
    required this.style,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: lineHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${prefix ?? ''}$value',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.clip,
          textHeightBehavior: _metricTextHeightBehavior,
        ),
      ),
    );
  }
}

/// Tek basamak — Stack + Positioned ile layout overflow üretmez.
class _DigitReel extends StatefulWidget {
  final int fromDigit;
  final int toDigit;
  final TextStyle style;
  final double slotHeight;
  final double columnWidth;
  final Duration delay;
  final Duration duration;

  const _DigitReel({
    super.key,
    required this.fromDigit,
    required this.toDigit,
    required this.style,
    required this.slotHeight,
    required this.columnWidth,
    required this.delay,
    required this.duration,
  });

  @override
  State<_DigitReel> createState() => _DigitReelState();
}

class _DigitReelState extends State<_DigitReel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _offsetAnimation = _tweenFor(widget.fromDigit, widget.toDigit).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _startAnimation();
  }

  @override
  void didUpdateWidget(_DigitReel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromDigit != widget.fromDigit ||
        oldWidget.toDigit != widget.toDigit) {
      _controller.dispose();
      _controller = AnimationController(vsync: this, duration: widget.duration);
      _offsetAnimation = _tweenFor(widget.fromDigit, widget.toDigit).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _startAnimation();
    }
  }

  Tween<double> _tweenFor(int from, int to) {
    final h = widget.slotHeight;
    return Tween<double>(begin: -from * h, end: -to * h);
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (!mounted) return;
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildReelStrip() {
    final h = widget.slotHeight;
    final w = widget.columnWidth;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (digit) {
        return SizedBox(
          height: h,
          width: w,
          child: Center(
            child: Text(
              '$digit',
              style: widget.style,
              maxLines: 1,
              textHeightBehavior: _metricTextHeightBehavior,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.slotHeight;
    final w = widget.columnWidth;

    return SizedBox(
      height: h,
      width: w,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _offsetAnimation,
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: _offsetAnimation.value,
                  left: 0,
                  width: w,
                  child: child!,
                ),
              ],
            );
          },
          child: _buildReelStrip(),
        ),
      ),
    );
  }
}
