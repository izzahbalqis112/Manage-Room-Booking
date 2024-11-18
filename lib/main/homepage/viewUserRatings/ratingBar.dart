import 'package:flutter/material.dart';

class RatingWidget {
  const RatingWidget({
    required this.full,
    required this.half,
    required this.empty,
  });
  final Widget full;
  final Widget half;
  final Widget empty;
}

class RatingBar extends StatefulWidget {
  const RatingBar({
    required RatingWidget ratingWidget,
    required this.onRatingUpdate,
    this.glowColor,
    this.maxRating,
    this.textDirection,
    this.unratedColor,
    this.allowHalfRating = false,
    this.direction = Axis.horizontal,
    this.glow = true,
    this.glowRadius = 2,
    this.ignoreGestures = false,
    this.initialRating = 0.0,
    this.itemCount = 5,
    this.itemPadding = EdgeInsets.zero,
    this.itemSize = 40.0,
    this.minRating = 0,
    this.tapOnlyMode = false,
    this.updateOnDrag = false,
    this.wrapAlignment = WrapAlignment.start,
    super.key,
  })  : _itemBuilder = null,
        _ratingWidget = ratingWidget;

  const RatingBar.builder({
    required IndexedWidgetBuilder itemBuilder,
    required this.onRatingUpdate,
    this.glowColor,
    this.maxRating,
    this.textDirection,
    this.unratedColor,
    this.allowHalfRating = false,
    this.direction = Axis.horizontal,
    this.glow = true,
    this.glowRadius = 2,
    this.ignoreGestures = false,
    this.initialRating = 0.0,
    this.itemCount = 5,
    this.itemPadding = EdgeInsets.zero,
    this.itemSize = 40.0,
    this.minRating = 0,
    this.tapOnlyMode = false,
    this.updateOnDrag = false,
    this.wrapAlignment = WrapAlignment.start,
    super.key,
  })  : _itemBuilder = itemBuilder,
        _ratingWidget = null;
  final ValueChanged<double> onRatingUpdate;
  final Color? glowColor;
  final double? maxRating;
  final TextDirection? textDirection;
  final Color? unratedColor;
  final bool allowHalfRating;
  final Axis direction;
  final bool glow;
  final double glowRadius;
  final bool ignoreGestures;
  final double initialRating;
  final int itemCount;
  final EdgeInsetsGeometry itemPadding;
  final double itemSize;
  final double minRating;
  final bool tapOnlyMode;
  final bool updateOnDrag;
  final WrapAlignment wrapAlignment;
  final IndexedWidgetBuilder? _itemBuilder;
  final RatingWidget? _ratingWidget;
  
  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  double _rating = 0;
  bool _isRTL = false;
  double iconRating = 0;

  late double _minRating;
  late double _maxRating;
  late final ValueNotifier<bool> _glow;

  @override
  void initState() {
    super.initState();
    _glow = ValueNotifier(false);
    _minRating = widget.minRating;
    _maxRating = widget.maxRating ?? widget.itemCount.toDouble();
    _rating = widget.initialRating;
  }

  @override
  void didUpdateWidget(RatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      _rating = widget.initialRating;
    }
    _minRating = widget.minRating;
    _maxRating = widget.maxRating ?? widget.itemCount.toDouble();
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = widget.textDirection ?? Directionality.of(context);
    _isRTL = textDirection == TextDirection.rtl;
    iconRating = 0.0;

    return Material(
      color: Colors.transparent,
      child: Wrap(
        alignment: widget.wrapAlignment,
        textDirection: textDirection,
        direction: widget.direction,
        children: List.generate(
          widget.itemCount,
              (index) => _buildRating(context, index),
        ),
      ),
    );
  }

  Widget _buildRating(BuildContext context, int index) {
    final ratingWidget = widget._ratingWidget;
    final item = widget._itemBuilder?.call(context, index);
    final ratingOffset = widget.allowHalfRating ? 0.5 : 1.0;

    Widget resolvedRatingWidget;

    if (index >= _rating) {
      resolvedRatingWidget = _NoRatingWidget(
        size: widget.itemSize,
        enableMask: ratingWidget == null,
        unratedColor: widget.unratedColor ?? Theme.of(context).disabledColor,
        child: ratingWidget?.empty ?? item!,
      );
    } else if (index >= _rating - ratingOffset && widget.allowHalfRating) {
      if (ratingWidget?.half == null) {
        resolvedRatingWidget = _HalfRatingWidget(
          size: widget.itemSize,
          enableMask: ratingWidget == null,
          rtlMode: _isRTL,
          unratedColor: widget.unratedColor ?? Theme.of(context).disabledColor,
          child: item!,
        );
      } else {
        resolvedRatingWidget = SizedBox(
          width: widget.itemSize,
          height: widget.itemSize,
          child: FittedBox(
            child: _isRTL
                ? Transform(
              transform: Matrix4.identity()..scale(-1.0, 1, 1),
              alignment: Alignment.center,
              transformHitTests: false,
              child: ratingWidget!.half,
            )
                : ratingWidget!.half,
          ),
        );
      }
      iconRating += 0.5;
    } else {
      resolvedRatingWidget = SizedBox(
        width: widget.itemSize,
        height: widget.itemSize,
        child: FittedBox(
          child: ratingWidget?.full ?? item,
        ),
      );
      iconRating += 1.0;
    }

    return Padding(
      padding: widget.itemPadding,
      child: resolvedRatingWidget,
    );
  }
}

class _HalfRatingWidget extends StatelessWidget {
  const _HalfRatingWidget({
    required this.size,
    required this.child,
    required this.enableMask,
    required this.rtlMode,
    required this.unratedColor,
  });

  final Widget child;
  final double size;
  final bool enableMask;
  final bool rtlMode;
  final Color unratedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: enableMask
          ? Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            child: _NoRatingWidget(
              size: size,
              unratedColor: unratedColor,
              enableMask: enableMask,
              child: child,
            ),
          ),
          FittedBox(
            child: ClipRect(
              clipper: _HalfClipper(
                rtlMode: rtlMode,
              ),
              child: child,
            ),
          ),
        ],
      )
          : FittedBox(
        child: child,
      ),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  _HalfClipper({required this.rtlMode});

  final bool rtlMode;

  @override
  Rect getClip(Size size) => rtlMode
      ? Rect.fromLTRB(
    size.width / 2,
    0,
    size.width,
    size.height,
  )
      : Rect.fromLTRB(
    0,
    0,
    size.width / 2,
    size.height,
  );

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class _NoRatingWidget extends StatelessWidget {
  const _NoRatingWidget({
    required this.size,
    required this.child,
    required this.enableMask,
    required this.unratedColor,
  });

  final double size;
  final Widget child;
  final bool enableMask;
  final Color unratedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: FittedBox(
        child: enableMask
            ? ColorFiltered(
          colorFilter: ColorFilter.mode(
            unratedColor,
            BlendMode.srcIn,
          ),
          child: child,
        )
            : child,
      ),
    );
  }
}
