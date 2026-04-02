// ─────────────────────────────────────────────
// 数据模型：VideoItem
//
// 【对比】
// Vue: 通常是一个普通 JS 对象或 TypeScript interface，无需特殊声明
//      interface VideoItem { id: number; height: number; title: string; }
//
// Flutter/Dart: 需要显式定义 class，Dart 是强类型静态语言，
//              类似 TypeScript 中用 class 而非 interface（因为有构造函数逻辑）
//
// 关键区别：Dart 是强类型静态语言，
// 想要从 API 返回的 JSON (Map<String, dynamic>) 中读取数据，
// 通常写一个 [factory fromJson] 构造函数进行解析，
// 类比 TypeScript 的 Class Constructor 或接口转换函数。
// ─────────────────────────────────────────────

class VideoItem {
  final int id;
  final double height;
  final String title;
  final String author;
  final String imageUrl;
  final String quote; // 新增：金句/台词
  final int likeCount;
  final int colorValue;

  const VideoItem({
    required this.id,
    required this.height,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.quote,
    required this.likeCount,
    required this.colorValue,
  });

  // 类比 Vue 里的接口数据转换
  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as int,
      height: json['height'] as double,
      title: json['title'] as String,
      author: json['author'] as String,
      imageUrl: json['imageUrl'] as String,
      quote: json['quote'] as String,
      likeCount: json['likeCount'] as int,
      colorValue: json['colorValue'] as int,
    );
  }
}
