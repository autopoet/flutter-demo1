import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  // 从真实二次元源（Jikan MAL API）获取【日本热门番】数据！
  // 使用硬编码的高清 TMDB CDN 资源（完美支持 CORS 与 Flutter Web CanvasKit）
  Future<List<VideoItem>> fetchVideos() async {
    // 模拟一下网络响应延迟
    await Future.delayed(const Duration(milliseconds: 600));

    // 零网裂图的终极杀招：我们直接使用了已经下载在本地的高清动漫资源资产
    // 这些是从 Bilibili/TMDB 上精选的热门番剧原画背景图，由于是本地 Asset，不受任何 CORS 或网络影响，秒开100%成功！
    final List<Map<String, String>> localAnimeAssets = [
      {
        'title': '未闻花名',
        'url': 'assets/images/anime0.jpg'
      },
      {
        'title': '某科学的超电磁炮',
        'url': 'assets/images/anime1.jpg'
      },
      {
        'title': '进击的巨人',
        'url': 'assets/images/anime2.jpg'
      },
      {
        'title': '笨蛋、测验、召唤兽',
        'url': 'assets/images/anime3.jpg'
      },
      {
        'title': '崖上的波妞',
        'url': 'assets/images/anime4.jpg'
      },
      {
        'title': '鬼灯的冷彻',
        'url': 'assets/images/anime5.jpg'
      }
    ];

    final List<String> quotes = [
      "只要不失去你的崇高，整个世界都会向你敞开。",
      "错的不是我，是这个世界。",
      "世界上只有一种真正的英雄主义，那就是认清生活的真相后依然热爱它。",
      "如果奇迹有颜色，那一定是橙色的！",
      "即使是在这虚伪的世界当中，也总有一些真实的东西。",
      "我命由我不由天！",
      "无论在哪里遇到你，我都会喜欢上你。",
      "不要悲伤，不要心急！忧郁的日子里须要镇静。",
      "你的名字，是我听过最短的情诗。",
      "愿你有一天，能和你最重要的人相逢。",
      "你指尖跃动的电光，是我此生不灭的信仰！",
      "既然选择了远方，便只顾风雨兼程。",
      "我们一路奋战，不是为了改变世界，而是为了不让世界改变我们。",
      "背山倒海，剑指苍穹！"
    ];

    final List<String> nicknames = [
      "云深不知处", "千寻の缘", "路过的假面骑士", "萤火里的森", "指尖跳动的电光",
      "三笠的小迷弟", "某不科学的某人", "极地大侦探", "追逐繁星的少年", "龙猫家守门人",
      "进击的社畜", "银魂永不完结", "夏目之友", "木叶村编外人员", "全职猎人停刊日"
    ];

    List<VideoItem> fetched = [];
    
    // 生成大概 30 张卡片，循环使用我们的本地精品库
    for (int i = 0; i < 30; i++) {
        final anime = localAnimeAssets[i % localAnimeAssets.length];
        
        fetched.add(VideoItem(
        id: i,
        // 这里精心调整了高度让它看上去像真正的瀑布流卡片
        height: 250.0 + (i % 3) * 60,
        title: anime['title']!,
        author: nicknames[i % nicknames.length],
        imageUrl: anime['url']!,
        quote: quotes[i % quotes.length],
        likeCount: (i * 99 + 888) % 3000,
        colorValue: Colors.primaries[i % Colors.primaries.length].value,
      ));
    }
    
    return fetched;
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
        backgroundColor: Colors.white.withOpacity(0.65),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _videoFuture = fetchVideos();
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
                return _buildShimmerGrid();
              } else if (snapshot.hasError) {
                return Center(child: Text('出错了: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('暂无数据'));
              }

              final items = snapshot.data!;
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  if (constraints.maxWidth > 700) crossAxisCount = 3;
                  if (constraints.maxWidth > 1000) crossAxisCount = 4;

                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: MasonryGridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return VideoCard(item: items[index]);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(24),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            height: index.isEven ? 200 : 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
    return Material(
      color: Colors.transparent, // 提供 Material 组件上下文，防止有些点击波纹或主题元素找不到而爆红
      child: InkWell(
        onTap: () => context.push('/detail/${item.id}', extra: item),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: item.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(item.colorValue).withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 第一层：背景图片。去掉 Positioned.fill，让它作为主撑开 Stack 的组件。
                item.imageUrl.startsWith('http')
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity, // 强制填满宽度
                        height: item.height,    // 显式高度保证卡片比例
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: item.height,
                            color: Color(item.colorValue).withOpacity(0.1),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (context, url, error) => Container(
                          height: item.height,
                          color: Color(item.colorValue).withOpacity(0.2),
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 40),
                          ),
                        ),
                      )
                    : Image.asset(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: item.height,
                      ),
                // 第二层：强化深色渐变蒙层。从透明到更深的黑色。
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.0), // 顶部浅透明
                          Colors.black.withOpacity(0.4), // 中间平滑过度
                          Colors.black.withOpacity(0.85), // 底部极深，保护文本
                        ],
                        stops: const [0.3, 0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                // 第三层：底部排版矩阵
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.quote,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: 0.5,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Color(item.colorValue),
                                  child: const Icon(Icons.person, size: 14, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.author,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white, // 改为纯白
                                      fontWeight: FontWeight.w700,
                                      shadows: [
                                        Shadow(color: Colors.black87, blurRadius: 4),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Consumer<LikeStore>(
                            builder: (context, store, _) {
                              final liked = store.isLiked(item.id);
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: IconButton(
                                  key: ValueKey(liked),
                                  icon: Icon(
                                    liked ? Icons.favorite : Icons.favorite_border,
                                    size: 24,
                                    color: liked ? Colors.pinkAccent : Colors.white,
                                  ),
                                  onPressed: () => store.toggleLike(item.id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 20,
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
        ),
      ),
    );
  }
}
