// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NewsModelAdapter extends TypeAdapter<NewsModel> {
  @override
  final int typeId = 0;

  @override
  NewsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      content: fields[3] as String?,
      url: fields[4] as String?,
      imageUrl: fields[5] as String?,
      source: fields[6] as String?,
      publishedAt: fields[7] as DateTime,
      category: fields[8] as String?,
      symbol: fields[9] as String?,
      cachedAt: fields[10] as DateTime,
      vulgarizedContent: fields[11] as String?,
      vulgarizedAt: fields[12] as DateTime?,
      sentimentScore: fields[13] as double?,
      relatedSymbols: (fields[14] as List?)?.cast<String>(),
      snippet: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NewsModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.source)
      ..writeByte(7)
      ..write(obj.publishedAt)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.symbol)
      ..writeByte(10)
      ..write(obj.cachedAt)
      ..writeByte(11)
      ..write(obj.vulgarizedContent)
      ..writeByte(12)
      ..write(obj.vulgarizedAt)
      ..writeByte(13)
      ..write(obj.sentimentScore)
      ..writeByte(14)
      ..write(obj.relatedSymbols)
      ..writeByte(15)
      ..write(obj.snippet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
