// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_digest_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyDigestModelAdapter extends TypeAdapter<DailyDigestModel> {
  @override
  final int typeId = 2;

  @override
  DailyDigestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyDigestModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      summary: fields[2] as String,
      topNewsIds: (fields[3] as List).cast<String>(),
      suggestionIds: (fields[4] as List).cast<String>(),
      marketSummary: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      cachedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyDigestModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.topNewsIds)
      ..writeByte(4)
      ..write(obj.suggestionIds)
      ..writeByte(5)
      ..write(obj.marketSummary)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyDigestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
