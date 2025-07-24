// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guardian_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuardianModelAdapter extends TypeAdapter<GuardianModel> {
  @override
  final int typeId = 0;

  @override
  GuardianModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuardianModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      address: fields[4] as String?,
      profession: fields[5] as String?,
      emergencyContact: fields[6] as String?,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GuardianModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.profession)
      ..writeByte(6)
      ..write(obj.emergencyContact)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuardianModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
