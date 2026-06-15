import 'package:flutter/material.dart';

/// Zamanlayıcı / sayaç hissi — rakamlar dikey kayarak 0'dan hedefe gelir.
class AnimatedRollingValue extends StatefulWidget {
  final num target;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Duration delay;
  final String Function(num value)? formatter;

  const AnimatedRollingValue({
    super.key,
    required this.target,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1100),
    this.delay = Duration.zero,
    this.formatter,
  });

  static double lineHeightFor(TextStyle style) =>
      (style.fontSize ?? 18) * 1.15;

  @override
  State<AnimatedRollingValue> createState() => _AnimatedRollingValueState();
}

class _AnimatedRollingValueState extends State<AnimatedRollingValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedRollingValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineHeight = AnimatedRollingValue.lineHeightFor(widget.style);

    if (widget.formatter != null) {
      return SizedBox(
        height: lineHeight,
        width: double.infinity,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _curve,
            builder: (context, _) {
              final current = widget.target * _curve.value;
              return Text(
                '${widget.prefix}${widget.formatter!(current)}${widget.suffix}',
                style: widget.style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),
      );
    }

    final digits = widget.target.abs().round().toString();
    final digitStyle = widget.style.copyWith(height: 1.0);

    return SizedBox(
      height: lineHeight,
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.prefix.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 1),
                child: Text(
                  widget.prefix,
                  style: widget.style,
                  maxLines: 1,
                ),
              ),
            for (var i = 0; i < digits.length; i++)
              _RollingDigitColumn(
                targetDigit: int.parse(digits[i]),
                progress: _curve,
                style: digitStyle,
                lineHeight: lineHeight,
                delayFactor: i * 0.08,
              ),
            if (widget.suffix.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text(
                  widget.suffix,
                  style: widget.style,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RollingDigitColumn extends StatelessWidget {
  final int targetDigit;
  final Animation<double> progress;
  final TextStyle style;
  final double lineHeight;
  final double delayFactor;

  const _RollingDigitColumn({
    required this.targetDigit,
    required this.progress,
    required this.style,
    required this.lineHeight,
    required this.delayFactor,
  });

  double get _digitWidth {
    final painter = TextPainter(
      text: TextSpan(text: '8', style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width.ceilToDouble() + 1;
  }

  @override
  Widget build(BuildContext context) {
    final digitWidth = _digitWidth;

    return SizedBox(
      height: lineHeight,
      width: digitWidth,
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) {
            final t = delayFactor >= 1
                ? 1.0
                : ((progress.value - delayFactor) / (1 - delayFactor))
                    .clamp(0.0, 1.0);
            final offset = -targetDigit * lineHeight * t;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: offset,
                  left: 0,
                  width: digitWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var d = 0; d <= 9; d++)
                        SizedBox(
                          height: lineHeight,
                          width: digitWidth,
                          child: Center(
                            child: Text(
                              '$d',
                              style: style,
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
