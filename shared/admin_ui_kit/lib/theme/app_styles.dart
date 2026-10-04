import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

abstract final class AppStyles {
  /// Default size for user avatars in lists
  static const double avatarSize = 32.0;

  /// Style for mobile list items (zero padding around card, vertical margins/paddings on inner items)
  static final FItemStyleDelta mobileList = .delta(
    shape: const RoundedRectangleBorder(),
    padding: .value(EdgeInsets.zero),
    contentDecoration: .delta([
      .all(.boxDelta(borderRadius: BorderRadius.zero)),
    ]),
    contentStyle: const .delta(
      unsuffixedPadding: .value(EdgeInsets.symmetric(vertical: 6)),
      suffixedPadding: .value(EdgeInsets.symmetric(vertical: 6)),
    ),
  );

  /// Style for desktop list items (8px left, 16px right, 6px vertical padding)
  static final FItemStyleDelta desktopList = .delta(
    shape: const RoundedRectangleBorder(),
    padding: .value(EdgeInsets.zero),
    contentDecoration: .delta([
      .all(.boxDelta(borderRadius: BorderRadius.zero)),
    ]),
    contentStyle: const .delta(
      middleSpacing: 0,
      unsuffixedPadding: .value(
        EdgeInsets.only(left: 8, right: 16, top: 6, bottom: 6),
      ),
      suffixedPadding: .value(
        EdgeInsets.only(left: 8, right: 16, top: 6, bottom: 6),
      ),
    ),
  );

  /// Style for desktop table headers (8px left, 16px right, 8px vertical padding)
  static final FItemStyleDelta desktopHeader = .delta(
    shape: const RoundedRectangleBorder(),
    padding: .value(EdgeInsets.zero),
    contentDecoration: .delta([
      .all(.boxDelta(borderRadius: BorderRadius.zero)),
    ]),
    contentStyle: const .delta(
      middleSpacing: 0,
      unsuffixedPadding: .value(
        EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
      ),
      suffixedPadding: .value(
        EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
      ),
    ),
  );
}
