import 'dart:convert'; // 用于 jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // dio 同等作用，类比 axios
import 'package:shimmer/shimmer.dart'; // 骨架屏
import '../models/video_item.dart';
import '../stores/like_store.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // ─────────────────────────────────────────────
  // 【对比：异步请求机制】
  //
  // Vue: 通常在 onMounted 中调用 axios.get()，
  //      然后把数据保存到 list.value 里通过 v-for 渲染。
  // 
  // Flutter: 有两种常见方式：
  //    1. 类似 Vue：在 initState 中请求，setState(list = data)，
  //    2. 推荐方案：使用 [FutureBuilder]。它是 Flutter 内置的一个神奇组件，
  //       可以直接监听一个异步方法的状态（进行中、成功、失败）。
  //       这就像 Vue3 的 [Suspense] + [async setup()]。
  // ─────────────────────────────────────────────

  late Future<List<VideoItem>> _videoFuture;

  @override
  void initState() {
    super.initState();
    _videoFuture = fetchVideos();
  }

  // 模拟 API 请求函数
  // 类比: const fetchVideos = async () => { ... }
  Future<List<VideoItem>> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos?_limit=30'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // 类比: return data.map(item => new VideoItem(item))
        return data.map((json) => VideoItem.fromJson(json)).toList();
      } else {
        throw Exception('加载失败');
      }
    } catch (e) {
      throw Exception('网络错误');
    }
  }

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
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _videoFuture = fetchVideos(); // 手动触发刷新，类比 window.location.reload()
            }),
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FutureBuilder<List<VideoItem>>(
            future: _videoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // 加载中，显示骨架屏
                return _buildShimmerGrid();
              } else if (snapshot.hasError) {
                // 错误处理
                return Center(child: Text('出错了: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('暂无数据'));
              }

              // 成功渲染
              final items = snapshot.data!;
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  if (constraints.maxWidth > 700) crossAxisCount = 3;
                  if (constraints.maxWidth > 1000) crossAxisCount = 4;

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
              );
            },
          ),
        ),
      ),
    );
  }

  // 构建骨架屏，类比 Vue 中实现的 Skeleton.vue
  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(24),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            height: index.isEven ? 200 : 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
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
            // 封面：从网络加载真实图片，类比 <img> 标签的懒加载
            Image.network(
              item.imageUrl,
              height: item.height,
              fit: BoxFit.cover,
              // 加载中的占位，相当于 <img> 的 placeholder
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: item.height,
                  color: Color(item.colorValue).withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
              errorBuilder: (context, url, error) => Container(
                height: item.height,
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline),
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
