import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Date Picker2 Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalendarDatePicker2Demo(title: 'Calendar Date Picker2 Demo'),
    );
  }
}

class CalendarDatePicker2Demo extends StatefulWidget {
  const CalendarDatePicker2Demo({super.key, required this.title});

  final String title;

  @override
  State<CalendarDatePicker2Demo> createState() =>
      _CalendarDatePicker2DemoState();
}

class _CalendarDatePicker2DemoState extends State<CalendarDatePicker2Demo> {
  List<DateTime?> _singleDatePickerValueWithDefaultValue = [DateTime.now()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlternateYearPickerTestPage(),
                    ),
                  );
                },
                child: const Text('Open Alternate Year Picker Test Page'),
              ),
              const SizedBox(height: 20),
              _buildAlternativeYearPickerExample(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeYearPickerExample() {
    // Configure the calendar
    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.multi,
      calendarViewMode: CalendarDatePicker2Mode.year,
      yearPickerMode: YearPickerMode.alternative,
      selectedDayHighlightColor: Colors.blue,
      weekdayLabelTextStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      controlsTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      // Configure the alternative year picker
      alternativeYearPickerConfig: AlternativeYearPickerConfig(
        height: 50.0,
        itemExtent: 50.0,
        magnification: 1.0,
        selectedBackgroundColor: Color(0xFFF44336).withValues(alpha: 0.1),
        maxAvailableYear: 2025,
        minAvailableYear: 2020,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alternative Year Picker',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CalendarDatePicker2(
            config: config,
            value: _singleDatePickerValueWithDefaultValue,
            onValueChanged:
                (dates) => setState(() {
                  _singleDatePickerValueWithDefaultValue = dates;
                }),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Selected value: ${_getValueText(_singleDatePickerValueWithDefaultValue)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  String _getValueText(List<DateTime?> dates) {
    if (dates.isEmpty) {
      return 'None';
    }

    final formatter = customDateFormatter();
    if (dates.length == 1) {
      return formatter.format(dates.first!);
    } else if (dates.length == 2) {
      return '${formatter.format(dates[0]!)} - ${formatter.format(dates[1]!)}';
    } else {
      return dates.map((date) => formatter.format(date!)).join(', ');
    }
  }

  DateFormat customDateFormatter() {
    return DateFormat('MMM dd, yyyy');
  }
}

class AlternateYearPickerTestPage extends StatefulWidget {
  const AlternateYearPickerTestPage({super.key});

  @override
  State<AlternateYearPickerTestPage> createState() =>
      _AlternateYearPickerTestPageState();
}

class _AlternateYearPickerTestPageState
    extends State<AlternateYearPickerTestPage> {
  List<DateTime?> _selectedDate = [DateTime.now()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AlternateYearPicker Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AlternateYearPicker Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'The AlternateYearPicker provides a wheel-style year selection experience.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            _buildStandardAlternateYearPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardAlternateYearPicker() {
    // Standard configuration
    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.single,
      calendarViewMode: CalendarDatePicker2Mode.year,
      yearPickerMode: YearPickerMode.alternative,
      selectedDayHighlightColor: Colors.blue,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Standard AlternateYearPicker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CalendarDatePicker2(
              config: config,
              value: _selectedDate,
              onValueChanged:
                  (dates) => setState(() {
                    _selectedDate = dates;
                  }),
            ),
            const SizedBox(height: 10),
            Text(
              'Selected date: ${_formatDate(_selectedDate.first)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'None';
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
