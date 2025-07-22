// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SchoolClassAdapter extends TypeAdapter<SchoolClass> {
  @override
  final int typeId = 2;

  @override
  SchoolClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SchoolClass(
      name: fields[0] as String,
      totalStudents: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SchoolClass obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.totalStudents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
