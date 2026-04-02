import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../stores/like_store.dart';

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
        title: const Text(
          '发现动态',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false, // 现代 App 倾向于标题靠左，显得更有设计感
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9), // 略微透明，模拟磨砂质感
        surfaceTintColor: Colors.white,
        actions: [
          // 添加搜索图标
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
            tooltip: '搜索',
          ),
          // 添加个人中心入口
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
              tooltip: '个人中心',
            ),
          ),
        ],
      ),
      // 使用 Center + ConstrainedBox 限制整页宽度，防止宽屏显示下过于凌乱
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 重新调整列数：手机端 2 列，桌面端最多 3-4 列
              // 对于瀑布流来说，3-4 列是人类视觉最舒适的极限，6 列确实太杂乱了
              int crossAxisCount = 2; 
              if (constraints.maxWidth > 700) {
                crossAxisCount = 3; 
              }
              if (constraints.maxWidth > 1000) {
                crossAxisCount = 4;
              }

              return MasonryGridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return VideoCard(item: items[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoItem item;
  const VideoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────
    // 【对比：质感 UI 构建】
    // 
    // Vue/CSS: 通过 box-shadow, border-radius, background-image: linear-gradient() 实现
    // 
    // Flutter: Decoration 系统 (BoxDecoration) 是核心。
    //          我们将 BoxDecoration 设计得像详情页一样精致，包含弥散阴影和渐变蒙层。
    // ─────────────────────────────────────────────
    return InkWell(
      onTap: () => context.push('/detail/${item.id}', extra: item),
      // 圆角需与容器保持一致
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面：使用渐变蒙层增加呼吸感
            Container(
              height: item.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(item.colorValue).withOpacity(0.5),
                    Color(item.colorValue).withOpacity(0.2),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.play_arrow_rounded,
                size: 40,
                color: Color(item.colorValue).withOpacity(0.8),
              ),
            ),
            // 底部内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 作者栏
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Color(item.colorValue),
                              child: const Icon(Icons.person, size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.author,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 点赞交互
                      Consumer<LikeStore>(
                        builder: (context, store, _) {
                          final liked = store.isLiked(item.id);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: IconButton(
                              icon: Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: liked ? Colors.pinkAccent : Colors.grey[400],
                              ),
                              onPressed: () => store.toggleLike(item.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 18,
                            ),
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
