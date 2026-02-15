import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class Constant {
  static const String forMe = 'for_me';
  static const String forFamily = 'for_family';
  
  static const List<String> educationLevels = [
    'Elementary',
    'Junior High School',
    'Senior High School',
    'College',
    'Graduate School',
  ];
  
  static const Map<String, List<String>> yearLevelMap = {
    'Elementary': [
      'Grade 1',
      'Grade 2',
      'Grade 3',
      'Grade 4',
      'Grade 5',
      'Grade 6',
    ],
    'Junior High School': ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'],
    'Senior High School': ['Grade 11', 'Grade 12'],
    'College': ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'],
    'Graduate School': ['1st Year', '2nd Year', '3rd Year'],
  };
  
  static final nagaCityCenter = GeoPoint(
    latitude: 13.6218,
    longitude: 123.1948,
  );
  
  static final nagaBoundingBox = BoundingBox(
    north: 14.5,
    south: 12.0,
    east: 124.5,
    west: 122.5,
  );
  
  static const List<String> monthsShort = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  
  static String formatDateRange(DateTime start, DateTime end) {
    return '${monthsShort[start.month]} ${start.day} - ${monthsShort[end.month]} ${end.day}, ${end.year}';
  }
}