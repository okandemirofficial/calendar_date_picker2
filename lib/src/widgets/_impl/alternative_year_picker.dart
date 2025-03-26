part of '../calendar_date_picker2.dart';

/// An alternative year picker that offers a different UI for selecting years.
///
/// This widget provides an alternative to the default YearPicker for use in
/// CalendarDatePicker2.
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
  int _currentDecade = 0;

  @override
  void initState() {
    super.initState();
    final initialYear =
        widget.selectedDates.isNotEmpty && widget.selectedDates[0] != null
            ? widget.selectedDates[0]!.year
            : widget.initialMonth.year;
    _currentDecade = (initialYear ~/ 10) * 10;
    _scrollController = widget.config.yearViewController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.config.yearViewController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  bool _isYearEnabled(int year) {
    final yearSelectableFromPredicate =
        widget.config.selectableYearPredicate?.call(year) ?? true;
    return year >= widget.config.firstDate.year &&
        year <= widget.config.lastDate.year &&
        yearSelectableFromPredicate;
  }

  Widget _buildYearButton(int year) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool isSelected = widget.selectedDates.any((d) => d?.year == year);
    final bool isCurrentYear = year == widget.config.currentDate.year;
    final bool isEnabled = _isYearEnabled(year);

    final Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else if (!isEnabled) {
      textColor = colorScheme.onSurface.withOpacity(0.38);
    } else if (isCurrentYear) {
      textColor =
          widget.config.selectedDayHighlightColor ?? colorScheme.primary;
    } else {
      textColor = colorScheme.onSurface.withOpacity(0.87);
    }

    TextStyle? itemStyle = widget.config.yearTextStyle ??
        textTheme.bodyLarge?.copyWith(color: textColor);
    if (!isEnabled) {
      itemStyle = widget.config.disabledYearTextStyle ?? itemStyle;
    }
    if (isSelected) {
      itemStyle = widget.config.selectedYearTextStyle ?? itemStyle;
    }

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: widget.config.selectedDayHighlightColor ?? colorScheme.primary,
        borderRadius:
            widget.config.yearBorderRadius ?? BorderRadius.circular(18.0),
      );
    } else if (isCurrentYear && isEnabled) {
      decoration = BoxDecoration(
        border: Border.all(
          color: widget.config.selectedDayHighlightColor ?? colorScheme.primary,
        ),
        borderRadius:
            widget.config.yearBorderRadius ?? BorderRadius.circular(18.0),
      );
    }

    Widget yearButton = widget.config.yearBuilder?.call(
          year: year,
          textStyle: itemStyle,
          decoration: decoration,
          isSelected: isSelected,
          isDisabled: !isEnabled,
          isCurrentYear: isCurrentYear,
        ) ??
        Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            year.toString(),
            style: itemStyle,
            textAlign: TextAlign.center,
          ),
        );

    if (!isEnabled) {
      return ExcludeSemantics(
        child: yearButton,
      );
    }

    return InkWell(
      onTap: () => widget.onChanged(
        DateTime(
          year,
          widget.initialMonth.month,
        ),
      ),
      borderRadius:
          widget.config.yearBorderRadius ?? BorderRadius.circular(18.0),
      child: Semantics(
        selected: isSelected,
        button: true,
        child: yearButton,
      ),
    );
  }

  void _handlePreviousDecade() {
    setState(() {
      _currentDecade -= 10;
    });
  }

  void _handleNextDecade() {
    setState(() {
      _currentDecade += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canSelectPreviousDecade =
        _currentDecade > widget.config.firstDate.year;
    final bool canSelectNextDecade =
        _currentDecade + 9 < widget.config.lastDate.year;

    return Column(
      children: <Widget>[
        Divider(
          color: widget.config.hideYearPickerDividers == true
              ? Colors.transparent
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    canSelectPreviousDecade ? _handlePreviousDecade : null,
                tooltip: canSelectPreviousDecade ? 'Previous decade' : null,
              ),
              Text(
                '${_currentDecade} - ${_currentDecade + 9}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: canSelectNextDecade ? _handleNextDecade : null,
                tooltip: canSelectNextDecade ? 'Next decade' : null,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.0,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
            ),
            itemCount: 10,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (BuildContext context, int index) {
              final int year = _currentDecade + index;
              return _buildYearButton(year);
            },
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
