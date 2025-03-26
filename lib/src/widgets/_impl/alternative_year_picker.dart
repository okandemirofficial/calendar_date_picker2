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
  late FixedExtentScrollController _scrollController;
  late List<int> _availableYears;
  late int _selectedYear;
  late int _currentYear;

  @override
  void initState() {
    super.initState();
    _initializeYearPicker();
  }

  void _initializeYearPicker() {
    final config = widget.config;
    final alternativeConfig = config.alternativeYearPickerConfig;

    // Get current year for highlighting
    _currentYear = DateUtils.dateOnly(DateTime.now()).year;

    // Set the selected year if available, otherwise use the current year
    _selectedYear =
        widget.selectedDates.isNotEmpty && widget.selectedDates[0] != null
            ? widget.selectedDates[0]!.year
            : _currentYear;

    // Determine available years
    final firstYear =
        alternativeConfig?.minAvailableYear ?? widget.config.firstDate.year;
    final lastYear =
        alternativeConfig?.maxAvailableYear ?? widget.config.lastDate.year;

    // Create the list of available years
    _availableYears = List.generate(
      lastYear - firstYear + 1,
      (index) => firstYear + index,
    );

    // Check if the selected year is within the available years
    // If not, select the closest available year
    if (!_availableYears.contains(_selectedYear)) {
      _selectedYear = _selectedYear < firstYear ? firstYear : lastYear;
    }

    // Find the index of the selected year to calculate the scroll offset
    final selectedIndex = _availableYears.indexOf(_selectedYear);

    // Initialize the scroll controller
    _scrollController =
        widget.config.yearViewController as FixedExtentScrollController? ??
            FixedExtentScrollController(initialItem: selectedIndex);
  }

  @override
  void didUpdateWidget(AlternativeYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDates != oldWidget.selectedDates ||
        widget.config != oldWidget.config) {
      _initializeYearPicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alternativeConfig = widget.config.alternativeYearPickerConfig;
    final theme = Theme.of(context);

    // Default text styles based on theme
    final defaultYearTextStyle =
        widget.config.yearTextStyle ?? theme.textTheme.bodyLarge;
    final defaultSelectedYearTextStyle = widget.config.selectedYearTextStyle ??
        theme.textTheme.headlineSmall
            ?.copyWith(color: theme.colorScheme.primary);
    final defaultDisabledYearTextStyle = widget.config.disabledYearTextStyle ??
        theme.textTheme.bodyLarge?.copyWith(color: theme.disabledColor);

    return Column(
      children: <Widget>[
        Divider(
          color: widget.config.hideYearPickerDividers == true
              ? Colors.transparent
              : null,
        ),
        Expanded(
          child: Container(
            height: alternativeConfig?.height ?? 180.0,
            color: alternativeConfig?.backgroundColor,
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: alternativeConfig?.diameterRatio ?? 1.5,
              perspective: alternativeConfig?.perspective ?? 0.01,
              offAxisFraction: alternativeConfig?.offAxisFraction ?? 0.0,
              squeeze: alternativeConfig?.squeeze ?? 1.0,
              magnification: alternativeConfig?.magnification ?? 1.2,
              itemExtent: alternativeConfig?.itemExtent ?? 40.0,
              onSelectedItemChanged: (index) {
                if (index >= 0 && index < _availableYears.length) {
                  final year = _availableYears[index];
                  if (_selectedYear != year) {
                    setState(() {
                      _selectedYear = year;
                    });

                    // Create a new date based on the selected year
                    // and the current selected date
                    final currentDate = widget.selectedDates.isNotEmpty &&
                            widget.selectedDates[0] != null
                        ? widget.selectedDates[0]!
                        : widget.initialMonth;

                    // Update the date maintaining the month and day
                    final newDate = DateTime(
                      year,
                      currentDate.month,
                      currentDate.day,
                    );

                    // Call onChanged with keepYearMode: true to prevent switching to day view
                    if (widget.onChanged is Function(DateTime,
                        {bool keepYearMode})) {
                      (widget.onChanged as dynamic)(newDate,
                          keepYearMode: true);
                    } else {
                      widget.onChanged(newDate);
                    }
                  }
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _availableYears.length,
                builder: (context, index) {
                  final year = _availableYears[index];
                  final isSelected = year == _selectedYear;
                  final isCurrentYear = year == _currentYear;

                  // Check if year is selectable
                  final isDisabled =
                      widget.config.selectableYearPredicate != null &&
                          !widget.config.selectableYearPredicate!(year);

                  // Use custom builder if provided
                  if (widget.config.yearBuilder != null) {
                    final customWidget = widget.config.yearBuilder!(
                      year: year,
                      textStyle: isDisabled
                          ? defaultDisabledYearTextStyle
                          : (isSelected
                              ? defaultSelectedYearTextStyle
                              : defaultYearTextStyle),
                      decoration: isSelected &&
                              alternativeConfig?.selectedBackgroundColor != null
                          ? BoxDecoration(
                              color: alternativeConfig!.selectedBackgroundColor,
                              borderRadius: widget.config.yearBorderRadius ??
                                  BorderRadius.circular(8),
                            )
                          : null,
                      isSelected: isSelected,
                      isDisabled: isDisabled,
                      isCurrentYear: isCurrentYear,
                    );

                    if (customWidget != null) {
                      return customWidget;
                    }
                  }

                  // Default year item widget
                  return Center(
                    child: Container(
                      decoration: isSelected &&
                              alternativeConfig?.selectedBackgroundColor != null
                          ? BoxDecoration(
                              color: alternativeConfig!.selectedBackgroundColor,
                              borderRadius: widget.config.yearBorderRadius ??
                                  BorderRadius.circular(8),
                            )
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        year.toString(),
                        style: isDisabled
                            ? (alternativeConfig?.disabledYearTextStyle ??
                                defaultDisabledYearTextStyle)
                            : (isSelected
                                ? (alternativeConfig?.selectedYearTextStyle ??
                                    defaultSelectedYearTextStyle)
                                : (alternativeConfig?.yearTextStyle ??
                                    defaultYearTextStyle)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
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
