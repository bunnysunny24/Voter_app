import 'package:hive/hive.dart';

part 'candidate.g.dart';

@HiveType(typeId: 1)
class Candidate {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String position;

  @HiveField(2)
  final String className;

  @HiveField(3)
  final String description;

  Candidate({
    required this.name,
    required this.position,
    required this.className,
    required this.description,
  });

  @override
  String toString() {
    return 'Candidate(name: $name, position: $position, className: $className, description: $description)';
  }
}
