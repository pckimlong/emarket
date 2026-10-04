import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class FProgressButton extends StatelessWidget {
  const FProgressButton({
    required this.label,
    required this.onPress,
    this.isLoading = false,
    this.variant = FButtonVariant.primary,
    this.size = FButtonSizeVariant.md,
    this.style = const FButtonStyleDelta.context(),
    this.onLongPress,
    this.onDoubleTap,
    this.onSecondaryPress,
    this.onSecondaryLongPress,
    this.semanticsLabel,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.onHoverChange,
    this.onVariantChange,
    this.selected = false,
    this.shortcuts,
    this.actions,
    this.mainAxisSize = MainAxisSize.max,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textBaseline,
    this.prefixBuilder,
    this.prefix,
    this.suffixBuilder,
    this.suffix,
    this.builder = FButton.defaultContentBuilder,
    super.key,
  });

  final Widget label;
  final VoidCallback? onPress;
  final bool isLoading;
  final FButtonVariant variant;
  final FButtonSizeVariant size;
  final FButtonStyleDelta style;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSecondaryPress;
  final VoidCallback? onSecondaryLongPress;
  final String? semanticsLabel;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<bool>? onHoverChange;
  final FTappableVariantChangeCallback? onVariantChange;
  final bool selected;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextBaseline? textBaseline;
  final FButtonContentBuilder? prefixBuilder;
  final Widget? prefix;
  final FButtonContentBuilder? suffixBuilder;
  final Widget? suffix;
  final FButtonContentBuilder builder;

  @override
  Widget build(BuildContext context) {
    final resolvedPrefix = prefix != null
        ? Opacity(
            opacity: isLoading ? 0 : 1,
            child: prefix,
          )
        : null;

    final resolvedSuffix = suffix != null
        ? Opacity(
            opacity: isLoading ? 0 : 1,
            child: suffix,
          )
        : null;

    final resolvedPrefixBuilder = isLoading && prefixBuilder != null
        ? (
            BuildContext context,
            FButtonStyle style,
            TextStyle textStyle,
            IconThemeData iconStyle,
            FCircularProgressStyle progressStyle,
            Widget? child,
          ) {
            return Opacity(
              opacity: 0,
              child: prefixBuilder!(
                context,
                style,
                textStyle,
                iconStyle,
                progressStyle,
                child,
              ),
            );
          }
        : prefixBuilder;

    final resolvedSuffixBuilder = isLoading && suffixBuilder != null
        ? (
            BuildContext context,
            FButtonStyle style,
            TextStyle textStyle,
            IconThemeData iconStyle,
            FCircularProgressStyle progressStyle,
            Widget? child,
          ) {
            return Opacity(
              opacity: 0,
              child: suffixBuilder!(
                context,
                style,
                textStyle,
                iconStyle,
                progressStyle,
                child,
              ),
            );
          }
        : suffixBuilder;

    return FButton(
      onPress: isLoading ? null : onPress,
      variant: variant,
      size: size,
      style: style,
      onLongPress: isLoading ? null : onLongPress,
      onDoubleTap: isLoading ? null : onDoubleTap,
      onSecondaryPress: isLoading ? null : onSecondaryPress,
      onSecondaryLongPress: isLoading ? null : onSecondaryLongPress,
      semanticsLabel: semanticsLabel,
      autofocus: autofocus,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      onHoverChange: onHoverChange,
      onVariantChange: onVariantChange,
      selected: selected,
      shortcuts: shortcuts,
      actions: actions,
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      textBaseline: textBaseline,
      prefix: resolvedPrefix,
      prefixBuilder: resolvedPrefixBuilder,
      suffix: resolvedSuffix,
      suffixBuilder: resolvedSuffixBuilder,
      builder: builder,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isLoading ? 0 : 1,
            child: label,
          ),
          if (isLoading)
            Positioned.fill(
              child: Center(
                child: FCircularProgress.loader(),
              ),
            ),
        ],
      ),
    );
  }
}
