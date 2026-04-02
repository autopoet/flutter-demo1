import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../models/video_item.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // 生成模拟数据
  // Vue: data() { return { items: [] } }
  // Flutter: 在 State 类中定义变量，类比 Vue 的响应式数据（但不是自动代理的）
  final List<VideoItem> items = List.generate(50, (index) {
    return VideoItem(
      id: index,
      height: 150.0 + Random().nextInt(150),
      title: '瀑布流内容 $index',
      author: '创作者 @user_$index',
      likeCount: Random().nextInt(10000),
      colorValue: Colors.primaries[index % Colors.primaries.length].value,
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
      ),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return VideoCard(item: items[index]);
        },
      ),
    );
  }
}

class VideoCard extends StatefulWidget {
  final VideoItem item;
  const VideoCard({super.key, required this.item});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isLiked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────
    // 【对比：导航跳转】
    //
    // Vue: <router-link :to="{ path: '/detail/' + item.id }"> 或 router.push()
    // 
    // Flutter: GestureDetector 或 InkWell（带波纹效果）包裹组件
    //          使用 context.push() (来自 go_router) 进行跳转
    //          注意：这里使用了 extra 传递对象，类比 Vue 的 route state
    // ─────────────────────────────────────────────
    return InkWell(
      onTap: () => context.push('/detail/${widget.item.id}', extra: widget.item),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面图
            Container(
              height: widget.item.height,
              color: Color(widget.item.colorValue).withOpacity(0.3),
              alignment: Alignment.center,
              child: Icon(
                Icons.play_circle_outline,
                size: 40,
                color: Color(widget.item.colorValue),
              ),
            ),
            // 底部内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.author,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isLiked,
                        builder: (context, liked, _) {
                          return IconButton(
                            icon: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: liked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => isLiked.value = !isLiked.value,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          );
                        },
                      ),
                    ],
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
