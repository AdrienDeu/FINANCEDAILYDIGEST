// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntityStatsModelAdapter extends TypeAdapter<EntityStatsModel> {
  @override
  final int typeId = 4;

  @override
  EntityStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntityStatsModel(
      symbol: fields[0] as String,
      date: fields[1] as DateTime,
      totalDocuments: fields[2] as int,
      sentimentAvg: fields[3] as double,
      cachedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EntityStatsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalDocuments)
      ..writeByte(3)
      ..write(obj.sentimentAvg)
      ..writeByte(4)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
