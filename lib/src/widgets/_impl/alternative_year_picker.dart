part of '../calendar_date_picker2.dart';

/// An alternative view for the year picker using Cupertino style.
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
  late DateTime _selectedDate;
  late int _currentYear;
  late int _minYear;
  late int _maxYear;

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

    // Set the selected date if available, otherwise use the initial month
    _selectedDate =
        widget.selectedDates.isNotEmpty && widget.selectedDates[0] != null
            ? widget.selectedDates[0]!
            : widget.initialMonth;

    // Determine available years range
    _minYear =
        alternativeConfig?.minAvailableYear ?? widget.config.firstDate.year;
    _maxYear =
        alternativeConfig?.maxAvailableYear ?? widget.config.lastDate.year;

    // Ensure selected date is within available years
    if (_selectedDate.year < _minYear) {
      _selectedDate =
          DateTime(_minYear, _selectedDate.month, _selectedDate.day);
    } else if (_selectedDate.year > _maxYear) {
      _selectedDate =
          DateTime(_maxYear, _selectedDate.month, _selectedDate.day);
    }
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

    // Calculate picker height
    final pickerHeight = alternativeConfig?.height ?? 180.0;

    // Get background color
    final backgroundColor = alternativeConfig?.backgroundColor;

    return Column(
      children: <Widget>[
        Divider(
          color: widget.config.hideYearPickerDividers == true
              ? Colors.transparent
              : null,
        ),
        Expanded(
          child: Container(
            height: pickerHeight,
            color: backgroundColor,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: alternativeConfig?.yearTextStyle ??
                      widget.config.yearTextStyle ??
                      theme.textTheme.bodyLarge,
                ),
                primaryColor: theme.colorScheme.primary,
              ),
              child: CupertinoPicker(
                scrollController: widget.config.yearViewController
                        as FixedExtentScrollController? ??
                    FixedExtentScrollController(
                      initialItem: _selectedDate.year - _minYear,
                    ),
                magnification:
                    (alternativeConfig?.magnification ?? 1.2).toDouble(),
                squeeze: (alternativeConfig?.squeeze ?? 1.0).toDouble(),
                diameterRatio:
                    (alternativeConfig?.diameterRatio ?? 1.5).toDouble(),
                offAxisFraction:
                    (alternativeConfig?.offAxisFraction ?? 0.0).toDouble(),
                itemExtent: (alternativeConfig?.itemExtent ?? 40.0).toDouble(),
                backgroundColor: Colors.transparent,
                selectionOverlay: _buildSelectionOverlay(alternativeConfig),
                onSelectedItemChanged: (index) {
                  final year = _minYear + index;

                  // Check if year is selectable
                  final isSelectable =
                      widget.config.selectableYearPredicate == null ||
                          widget.config.selectableYearPredicate!(year);

                  if (isSelectable) {
                    // Create new date with selected year
                    final newDate = DateTime(
                      year,
                      _selectedDate.month,
                      _selectedDate.day,
                    );

                    setState(() {
                      _selectedDate = newDate;
                    });

                    // Call onChanged with keepYearMode: true to prevent switching to day view
                    if (widget.onChanged is Function(DateTime,
                        {bool keepYearMode})) {
                      (widget.onChanged as dynamic)(newDate,
                          keepYearMode: true);
                    } else {
                      widget.onChanged(newDate);
                    }
                  }
                },
                children: List<Widget>.generate(
                  _maxYear - _minYear + 1,
                  (index) {
                    final year = _minYear + index;
                    final isSelected = year == _selectedDate.year;
                    final isCurrentYear = year == _currentYear;
                    final isDisabled =
                        widget.config.selectableYearPredicate != null &&
                            !widget.config.selectableYearPredicate!(year);

                    // Use custom builder if provided
                    if (widget.config.yearBuilder != null) {
                      final customWidget = widget.config.yearBuilder!(
                        year: year,
                        textStyle: isDisabled
                            ? widget.config.disabledYearTextStyle ??
                                theme.textTheme.bodyLarge
                                    ?.copyWith(color: theme.disabledColor)
                            : (isSelected
                                ? widget.config.selectedYearTextStyle ??
                                    theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.colorScheme.primary)
                                : widget.config.yearTextStyle ??
                                    theme.textTheme.bodyLarge),
                        decoration: isSelected &&
                                alternativeConfig?.selectedBackgroundColor !=
                                    null
                            ? BoxDecoration(
                                color:
                                    alternativeConfig!.selectedBackgroundColor,
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
                      child: Text(
                        year.toString(),
                        style: isDisabled
                            ? (alternativeConfig?.disabledYearTextStyle ??
                                widget.config.disabledYearTextStyle ??
                                theme.textTheme.bodyLarge
                                    ?.copyWith(color: theme.disabledColor))
                            : (isSelected
                                ? (alternativeConfig?.selectedYearTextStyle ??
                                    widget.config.selectedYearTextStyle ??
                                    theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.colorScheme.primary))
                                : (alternativeConfig?.yearTextStyle ??
                                    widget.config.yearTextStyle ??
                                    theme.textTheme.bodyLarge)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
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

  Widget? _buildSelectionOverlay(
      AlternativeYearPickerConfig? alternativeConfig) {
    final selectedColor = alternativeConfig?.selectedBackgroundColor;

    if (selectedColor != null) {
      return Container(
        decoration: BoxDecoration(
          color: selectedColor.withOpacity(0.1),
          borderRadius:
              widget.config.yearBorderRadius ?? BorderRadius.circular(8),
          border: Border.all(
            color: selectedColor,
            width: 1.0,
          ),
        ),
      );
    }
    return CupertinoPickerDefaultSelectionOverlay(
      background: Colors.transparent,
    );
  }
}
