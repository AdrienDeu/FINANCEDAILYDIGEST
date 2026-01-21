// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SuggestionModelAdapter extends TypeAdapter<SuggestionModel> {
  @override
  final int typeId = 1;

  @override
  SuggestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SuggestionModel(
      id: fields[0] as String,
      ticker: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as String,
      reasoning: fields[4] as String,
      risk: fields[5] as String,
      peaEligible: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      cachedAt: fields[8] as DateTime,
      relatedNewsId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SuggestionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ticker)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.reasoning)
      ..writeByte(5)
      ..write(obj.risk)
      ..writeByte(6)
      ..write(obj.peaEligible)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.cachedAt)
      ..writeByte(9)
      ..write(obj.relatedNewsId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
