import 'package:hive/hive.dart';

part 'vote.g.dart';

@HiveType(typeId: 0)
class Vote {
  @HiveField(0)
  final String studentId;

  @HiveField(1)
  final String className;

  @HiveField(2)
  final String position;

  @HiveField(3)
  final String candidateName;

  @HiveField(4)
  final DateTime timestamp;

  Vote({
    required this.studentId,
    required this.className,
    required this.position,
    required this.candidateName,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'Vote(studentId: $studentId, className: $className, position: $position, candidateName: $candidateName, timestamp: $timestamp)';
  }
}
