double convertWeight(double kg, bool imperial) =>
    imperial ? kg / 0.45359237 : kg;
double convertLength(double cm, bool imperial) => imperial ? cm / 2.54 : cm;
String formatMeasurementDate(DateTime date) =>
    '${_month(date.month)} ${date.day}, ${date.year}';
String formatShortMonthDay(DateTime date) =>
    '${_month(date.month).substring(0, 3)} ${date.day}';
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _month(int month) => _monthNames[month - 1];
