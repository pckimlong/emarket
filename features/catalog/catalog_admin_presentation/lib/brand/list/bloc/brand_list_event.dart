sealed class const BrandListEvent();

sealed class const BrandListWatchEvent() extends BrandListEvent;

final class const BrandListStarted() extends BrandListWatchEvent;

final class const BrandListRefreshed() extends BrandListWatchEvent;

final class const BrandListFilterChanged({final bool? isActive})
    extends BrandListEvent;

final class const BrandListSearchChanged(final String query)
    extends BrandListEvent;
