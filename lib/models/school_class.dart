import 'package:hive/hive.dart';

part 'school_class.g.dart';

@HiveType(typeId: 2)
class SchoolClass {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int totalStudents;

  SchoolClass({
    required this.name,
    required this.totalStudents,
  });

  @override
  String toString() {
    return 'SchoolClass(name: $name, totalStudents: $totalStudents)';
  }
}
