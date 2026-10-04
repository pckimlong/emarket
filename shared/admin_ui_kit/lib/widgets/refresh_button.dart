import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'progress_button.dart';

class FRefreshButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPress;
  final Duration minDuration;
  final FButtonVariant variant;

  const FRefreshButton({
    required this.isLoading,
    required this.onPress,
    this.minDuration = const Duration(milliseconds: 500),
    this.variant = FButtonVariant.secondary,
    super.key,
  });

  @override
  State<FRefreshButton> createState() => _FRefreshButtonState();
}

class _FRefreshButtonState extends State<FRefreshButton> {
  bool _displayLoading = false;
  DateTime? _loadingStartTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _displayLoading = widget.isLoading;
    if (_displayLoading) {
      _loadingStartTime = DateTime.now();
    }
  }

  @override
  void didUpdateWidget(covariant FRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _timer?.cancel();
        _timer = null;
        setState(() {
          _displayLoading = true;
          _loadingStartTime = DateTime.now();
        });
      } else {
        final startTime = _loadingStartTime;
        if (startTime != null) {
          final elapsed = DateTime.now().difference(startTime);
          final remaining = widget.minDuration - elapsed;
          if (remaining > Duration.zero) {
            _timer?.cancel();
            _timer = Timer(remaining, () {
              if (mounted) {
                setState(() {
                  _displayLoading = false;
                });
              }
            });
          } else {
            setState(() {
              _displayLoading = false;
            });
          }
        } else {
          setState(() {
            _displayLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FProgressButton(
      isLoading: _displayLoading,
      onPress: widget.onPress,
      variant: widget.variant,
      label: const Icon(Icons.refresh),
    );
  }
}
