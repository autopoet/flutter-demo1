import 'package:flutter/material.dart';
import '../models/video_item.dart';

class DetailPage extends StatelessWidget {
  final int id;
  final VideoItem item;

  const DetailPage({
    super.key,
    required this.id,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────
    // 【对比：详情页详情显示】
    //
    // Vue: 接收 props 或从 route.params 获取 id，通过 API 请求数据
    // 
    // Flutter: 构造函数接收参数。整个页面也是一个 Widget，
    //          Scaffold 提供了标准页面布局（AppBar + Body）
    // ─────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: const Text('详情'),
        // AppBar 自动提供返回按钮，逻辑类似于 router.back()
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 大尺寸视频封面
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Color(item.colorValue).withOpacity(0.4),
                child: Icon(
                  Icons.play_circle_fill,
                  size: 80,
                  color: Color(item.colorValue),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      // 这里的点赞按钮目前还是独立的，第二阶段我们将实现全局同步
                      const Icon(Icons.favorite_border, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(item.colorValue),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.author,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  Text(
                    '这是个视频详情预览页面。每一个细节都展示了 Flutter UI 组件化的魅力。'
                    '你可以点击顶部的播放按钮（模拟）或下方的作者头像。',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
