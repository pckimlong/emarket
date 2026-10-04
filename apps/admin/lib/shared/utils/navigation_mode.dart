import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum AppNavigationMode {
  full,
  collapsed,
  drawer,
}

extension ResponsiveNavigationHelper on BuildContext {
  FBreakpoints get breakpoints => theme.breakpoints;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobileSize => screenWidth < breakpoints.sm;
  bool get isTabletSize =>
      screenWidth >= breakpoints.sm && screenWidth < breakpoints.lg;
  bool get isDesktopSize => screenWidth >= breakpoints.lg;

  AppNavigationMode get resolveNavigationMode {
    if (isMobileSize) {
      return AppNavigationMode.drawer;
    } else if (isTabletSize) {
      return AppNavigationMode.collapsed;
    } else {
      return AppNavigationMode.full;
    }
  }
}

class AppNavigationModeScope extends InheritedWidget {
  const AppNavigationModeScope({
    required this.mode,
    required super.child,
    super.key,
  });

  final AppNavigationMode mode;

  static AppNavigationMode? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppNavigationModeScope>()
        ?.mode;
  }

  static AppNavigationMode of(BuildContext context) {
    final mode = maybeOf(context);
    assert(mode != null, 'No AppNavigationModeScope found in context');
    return mode!;
  }

  @override
  bool updateShouldNotify(AppNavigationModeScope oldWidget) =>
      oldWidget.mode != mode;
}

extension AppNavigationModeScopeHelper on BuildContext {
  AppNavigationMode? get navigationMode => AppNavigationModeScope.maybeOf(this);
  bool get isNavigationFull => navigationMode == AppNavigationMode.full;
  bool get isNavigationCollapsed =>
      navigationMode == AppNavigationMode.collapsed;
  bool get isNavigationDrawer => navigationMode == AppNavigationMode.drawer;
}
