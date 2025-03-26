part of '../calendar_date_picker2.dart';

/// An alternative view for the year picker.
///
/// The year picker widget is rarely used directly. Instead, consider using
/// [CalendarDatePicker2], or [showDatePicker2] which create full date pickers.
///
/// See also:
///
///  * [CalendarDatePicker2], which provides a Material Design date picker
///    interface.
///
///  * [showDatePicker2], which shows a dialog containing a Material Design
///    date picker.
///
class AlternativeYearPicker extends StatefulWidget {
  /// Creates an alternative year picker.
  const AlternativeYearPicker({
    required this.config,
    required this.selectedDates,
    required this.onChanged,
    required this.initialMonth,
    this.dragStartBehavior = DragStartBehavior.start,
    Key? key,
  }) : super(key: key);

  /// The calendar configurations
  final CalendarDatePicker2Config config;

  /// The currently selected dates.
  ///
  /// Selected dates are highlighted in the picker.
  final List<DateTime?> selectedDates;

  /// Called when the user picks a year.
  final ValueChanged<DateTime> onChanged;

  /// The initial month to display.
  final DateTime initialMonth;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  State<AlternativeYearPicker> createState() => _AlternativeYearPickerState();
}

class _AlternativeYearPickerState extends State<AlternativeYearPicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final scrollOffset =
        widget.selectedDates.isNotEmpty && widget.selectedDates[0] != null
            ? _getScrollOffsetForYear(widget.selectedDates[0]!)
            : _getScrollOffsetForYear(DateUtils.dateOnly(DateTime.now()));
    _scrollController = widget.config.yearViewController ??
        ScrollController(initialScrollOffset: scrollOffset);
  }

  @override
  void didUpdateWidget(AlternativeYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDates != oldWidget.selectedDates) {
      final scrollOffset =
          widget.selectedDates.isNotEmpty && widget.selectedDates[0] != null
              ? _getScrollOffsetForYear(widget.selectedDates[0]!)
              : _getScrollOffsetForYear(DateUtils.dateOnly(DateTime.now()));
      _scrollController.jumpTo(scrollOffset);
    }
  }

  double _getScrollOffsetForYear(DateTime date) {
    // This method will be implemented to calculate scroll position for selected year
    // For now, return 0 as a placeholder
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Return an empty Container as placeholder for the implementation
    // This will be replaced with the actual implementation in the future
    return Column(
      children: <Widget>[
        Divider(
          color: widget.config.hideYearPickerDividers == true
              ? Colors.transparent
              : null,
        ),
        Expanded(
          child: Center(
            child: Text(
              'Alternative Year Picker',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        Divider(
          color: widget.config.hideYearPickerDividers == true
              ? Colors.transparent
              : null,
        ),
      ],
    );
  }
}
