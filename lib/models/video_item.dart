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
// 关键区别：Dart 的 final 字段 = TS 的 readonly，确保数据不可变
// ─────────────────────────────────────────────

class VideoItem {
  final int id;
  final double height;
  final String title;
  final String author;
  final int likeCount;
  // 封面用颜色值模拟（实际项目中这里应该是图片 URL）
  final int colorValue;

  const VideoItem({
    required this.id,
    required this.height,
    required this.title,
    required this.author,
    required this.likeCount,
    required this.colorValue,
  });
}
