import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:forui/forui.dart';
import 'package:presentation_utils/presentation_utils.dart';

import '../theme/app_styles.dart';

/// Defines the configuration and rendering logic for a column in [AdminDataTable].
class DataColumnDef<T> {
  const DataColumnDef({
    this.header,
    this.headerWidget,
    required this.cellBuilder,
    this.sortValue,
    this.flex,
    this.width,
    this.alignment = Alignment.centerLeft,
  }) : assert(
         header != null || headerWidget != null,
         'Either header or headerWidget must be provided',
       );

  /// String header title.
  final String? header;

  /// Custom header widget (overrides [header] text if provided).
  final Widget? headerWidget;

  /// Builder for rendering each cell in this column.
  final Widget Function(BuildContext context, T item) cellBuilder;

  /// Optional extractor returning a [Comparable] value to enable column sorting.
  final Comparable? Function(T item)? sortValue;

  /// Sizing flex factor when [width] is not set. Defaults to 1.
  final int? flex;

  /// Fixed column width in logical pixels.
  final double? width;

  /// Alignment of the header and cells within this column.
  final AlignmentGeometry alignment;
}

/// A responsive, accessible data table component for admin dashboards.
///
/// Features:
/// - Desktop tabular presentation with column sorting, alignment, and optional horizontal scroll.
/// - Mobile card/tile fallback via [mobileItemBuilder].
/// - Optional multi-row checkbox selection.
/// - Seamless styling adhering to the design system with [forui] and [LucideIcons].
class AdminDataTable<T> extends StatefulWidget {
  const AdminDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.onRowTap,
    this.mobileItemBuilder,
    this.selectedItems,
    this.onSelectionChanged,
    this.enableHorizontalScroll = false,
    this.initialSortRule,
    this.onSortChanged,
    this.headerColor,
    this.emptyPlaceholder,
    this.mobileBreakpoint = 768.0,
  });

  /// Custom background color for the desktop table header. Defaults to [Colors.transparent].
  final Color? headerColor;

  /// The data items to display.
  final Iterable<T> items;

  /// The column definitions.
  final List<DataColumnDef<T>> columns;

  /// Optional callback invoked when a row is clicked.
  final ValueChanged<T>? onRowTap;

  /// Optional custom builder for mobile viewports.
  final Widget Function(BuildContext context, T item)? mobileItemBuilder;

  /// Selected items set when selection mode is enabled.
  final Set<T>? selectedItems;

  /// Callback triggered when item selection changes.
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Whether to enable horizontal scrolling when columns exceed viewport width.
  final bool enableHorizontalScroll;

  /// Initial sorting rule (column index + direction).
  final SortRule<int>? initialSortRule;

  /// Callback when sorting rule changes.
  final ValueChanged<SortRule<int>?>? onSortChanged;

  /// Custom widget displayed when [items] is empty.
  final Widget? emptyPlaceholder;

  /// Screen width threshold (in logical pixels) to switch to mobile layout. Defaults to 768.
  final double mobileBreakpoint;

  @override
  State<AdminDataTable<T>> createState() => _AdminDataTableState<T>();
}

class _AdminDataTableState<T> extends State<AdminDataTable<T>> {
  SortRule<int>? _activeSort;
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _activeSort = widget.initialSortRule;
    _horizontalScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant AdminDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSortRule != oldWidget.initialSortRule) {
      _activeSort = widget.initialSortRule;
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<T> get _sortedItems {
    final rawList = widget.items.toList();
    final sort = _activeSort;
    if (sort == null) return rawList;

    if (sort.field < 0 || sort.field >= widget.columns.length) {
      return rawList;
    }

    final col = widget.columns[sort.field];
    final selector = col.sortValue;
    if (selector == null) return rawList;

    return rawList.sortBySelector(
      selector,
      direction: sort.direction,
    );
  }

  void _handleSort(int colIndex) {
    setState(() {
      _activeSort = nextSortRule<int>(_activeSort, field: colIndex);
    });
    widget.onSortChanged?.call(_activeSort);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < widget.mobileBreakpoint;
    final itemsList = _sortedItems;

    if (itemsList.isEmpty && widget.emptyPlaceholder != null) {
      return widget.emptyPlaceholder!;
    }

    final hasSelection =
        widget.selectedItems != null && widget.onSelectionChanged != null;
    final selectedCount = hasSelection
        ? itemsList.where((item) => widget.selectedItems!.contains(item)).length
        : 0;
    final allSelected =
        itemsList.isNotEmpty && selectedCount == itemsList.length;

    if (isMobile && widget.mobileItemBuilder != null) {
      return ListView.separated(
        itemCount: itemsList.length,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = itemsList[index];
          final mobileCard = widget.mobileItemBuilder!(context, item);

          if (hasSelection) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: FCheckbox(
                    value: widget.selectedItems!.contains(item),
                    onChange: (selected) {
                      final updated = Set<T>.from(widget.selectedItems!);
                      if (selected == true) {
                        updated.add(item);
                      } else {
                        updated.remove(item);
                      }
                      widget.onSelectionChanged!(updated);
                    },
                  ),
                ),
                Expanded(child: mobileCard),
              ],
            );
          }

          return mobileCard;
        },
      );
    }

    final effectiveColumns = [
      if (hasSelection)
        DataColumnDef<T>(
          width: 48,
          alignment: Alignment.center,
          headerWidget: FCheckbox(
            value: allSelected,
            onChange: (selected) {
              final updated = Set<T>.from(widget.selectedItems!);
              if (selected == true) {
                updated.addAll(itemsList);
              } else {
                for (final item in itemsList) {
                  updated.remove(item);
                }
              }
              widget.onSelectionChanged!(updated);
            },
          ),
          cellBuilder: (context, item) => FCheckbox(
            value: widget.selectedItems!.contains(item),
            onChange: (selected) {
              final updated = Set<T>.from(widget.selectedItems!);
              if (selected == true) {
                updated.add(item);
              } else {
                updated.remove(item);
              }
              widget.onSelectionChanged!(updated);
            },
          ),
        ),
      ...widget.columns,
    ];

    if (!widget.enableHorizontalScroll) {
      return Column(
        children: [
          _buildDesktopHeader(context, effectiveColumns, hasSelection),
          Expanded(
            child: _buildDesktopList(context, itemsList, effectiveColumns),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = effectiveColumns.fold<double>(0.0, (sum, col) {
          if (col.width != null) return sum + col.width!;
          return sum + (col.flex ?? 1) * 80.0;
        });

        final tableWidth = constraints.maxWidth < minWidth
            ? minWidth
            : constraints.maxWidth;

        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _buildDesktopHeader(context, effectiveColumns, hasSelection),
                  Expanded(
                    child: _buildDesktopList(
                      context,
                      itemsList,
                      effectiveColumns,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopHeader(
    BuildContext context,
    List<DataColumnDef<T>> effectiveColumns,
    bool hasSelection,
  ) {
    final colors = context.theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: widget.headerColor ?? Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: FItem(
        style: AppStyles.desktopHeader,
        title: Row(
          children: List.generate(effectiveColumns.length, (index) {
            final col = effectiveColumns[index];
            final originalIndex = hasSelection ? index - 1 : index;

            Widget headerChild =
                col.headerWidget ??
                Text(
                  col.header ?? '',
                  style: context.theme.typography.body.xs.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.mutedForeground,
                    letterSpacing: 0.5,
                  ),
                );

            if (col.sortValue != null && originalIndex >= 0) {
              final isActive = _activeSort?.field == originalIndex;
              final direction = isActive ? _activeSort?.direction : null;
              final icon = switch (direction) {
                SortDirection.ascending => LucideIcons.arrow_up,
                SortDirection.descending => LucideIcons.arrow_down,
                null => LucideIcons.chevrons_up_down,
              };

              headerChild = InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => _handleSort(originalIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: headerChild),
                      const SizedBox(width: 4),
                      Icon(
                        icon,
                        size: 14,
                        color: isActive
                            ? colors.primary
                            : colors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              );
            }

            final cell = Align(
              alignment: col.alignment,
              child: headerChild,
            );

            if (col.width != null) {
              return SizedBox(width: col.width, child: cell);
            }
            return Expanded(
              flex: col.flex ?? 1,
              child: cell,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDesktopList(
    BuildContext context,
    List<T> items,
    List<DataColumnDef<T>> effectiveColumns,
  ) {
    return ListView.separated(
      itemCount: items.length,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, _) => Divider(
        height: 0,
        thickness: context.theme.dividerStyles.horizontal.width,
        color: context.theme.dividerStyles.horizontal.color,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return FItem(
          style: AppStyles.desktopList,
          onPress: widget.onRowTap != null
              ? () => widget.onRowTap!(item)
              : null,
          title: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Row(
              children: effectiveColumns.map((col) {
                final cell = Align(
                  alignment: col.alignment,
                  child: col.cellBuilder(context, item),
                );

                if (col.width != null) {
                  return SizedBox(width: col.width, child: cell);
                }
                return Expanded(
                  flex: col.flex ?? 1,
                  child: cell,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
