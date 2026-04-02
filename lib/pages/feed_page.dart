import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  // 使用硬编码的高清本地资源（20张不重复），完美支持 CORS 与 Flutter Web CanvasKit
  Future<List<VideoItem>> fetchVideos() async {
    // 模拟一下网络响应延迟
    await Future.delayed(const Duration(milliseconds: 600));

    // 零网裂图的终极杀招：我们直接使用了已经下载在本地的高清动漫资源资产
    // 这里扩展到 20 张不重复的高清大图，每一张都是精选热门番剧。
    final List<Map<String, String>> localAnimeAssets = [
      {'title': '我们仍未知道那天所看见的花的名字', 'url': 'assets/images/anime0.jpg'},
      {'title': '某科学的超电磁炮', 'url': 'assets/images/anime1.jpg'},
      {'title': '加速世界', 'url': 'assets/images/anime2.jpg'},
      {'title': '笨蛋、测验、召唤兽', 'url': 'assets/images/anime3.jpg'},
      {'title': '问题儿童都来自异世界？', 'url': 'assets/images/anime4.jpg'},
      {'title': '鬼灯的冷彻', 'url': 'assets/images/anime5.jpg'},
      {'title': '刀剑神域', 'url': 'assets/images/anime6.jpg'},
      {'title': '约会大作战', 'url': 'assets/images/anime7.jpg'},
      {'title': '神的记事本', 'url': 'assets/images/anime8.jpg'},
      {'title': '影之诗', 'url': 'assets/images/anime9.jpg'},
      {'title': '笨蛋、测验、召唤兽 第二季', 'url': 'assets/images/anime10.jpg'},
      {'title': '物语系列', 'url': 'assets/images/anime11.jpg'},
      {'title': '干物妹！小埋', 'url': 'assets/images/anime12.jpg'},
      {'title': '攻壳机动队', 'url': 'assets/images/anime13.jpg'},
      {'title': '传说中勇者的传说', 'url': 'assets/images/anime14.jpg'},
      {'title': '纯白交响曲', 'url': 'assets/images/anime15.jpg'},
      {'title': '夏洛特 SP', 'url': 'assets/images/anime16.jpg'},
      {'title': '某科学的一方通行', 'url': 'assets/images/anime17.jpg'},
      {'title': '全职高手', 'url': 'assets/images/anime18.jpg'},
      {'title': '斗罗大陆', 'url': 'assets/images/anime19.jpg'},
    ];

    final List<String> quotes = [
      "只要不失去你的崇高，整个世界都会向你敞开。",
      "错的不是我，是这个世界。",
      "无论在哪里遇到你，我都会喜欢上你。",
      "如果奇迹有颜色，那一定是橙色的！",
      "即使是在这虚伪的世界当中，也总有一些真实的东西。",
      "我命由我不由天！",
      "隐藏着黑暗力量的钥匙啊，在我面前显示你真正的力量！",
      "不要悲伤，不要心急！忧郁的日子里须要镇静。",
      "你的名字，是我听过最短的情诗。",
      "愿你有一天，能和你最重要的人相逢。",
      "你指尖跃动的电光，是我此生不灭的信仰！",
      "已经没什么好害怕的了，因为我不再是孤单一人了。",
      "如果不战斗，就无法赢！",
      "所谓觉悟，就是在漆黑的荒野中开辟出一条理应前行的道路。",
      "在这个世界上，弱者只有被支配的份。",
      "即便只有百分之一的希望，也要付出百分之百的努力。",
      "真正重要的东西，总是没有办法一眼看穿的。",
      "人如果不牺牲些什么的话，就什么也得不到。",
      "不管前方的路有多苦，只要走的方向正确，不管多么崎岖不平，都比站在原地更接近幸福。",
      "立于浮华之世，奏响天籁之音。"
    ];

    final List<String> nicknames = [
      "云深不知处", "千寻の缘", "路过的假面骑士", "萤火里的森", "指尖跳动的电光",
      "三笠的小迷弟", "某不科学的某人", "极地大侦探", "追逐繁星的少年", "龙猫家守门人",
      "进击的社畜", "银魂永不完结", "夏目之友", "木叶村编外人员", "全职猎人停刊日"
    ];

    // 满足一半一半的比例：20个本地番剧名场面，其中10个为Live动态视频（绝无重复，10个完全独立的高清短视频动画）
    final List<String?> videoPool = [
      'assets/videos/anime0.mp4', null,
      'assets/videos/anime1.mp4', null,
      'assets/videos/anime2.mp4', null,
      'assets/videos/anime3.mp4', null,
      'assets/videos/anime4.mp4', null,
      'assets/videos/anime5.mp4', null,
      'assets/videos/anime6.mp4', null,
      'assets/videos/anime7.mp4', null,
      'assets/videos/anime8.mp4', null,
      'assets/videos/anime9.mp4', null,
    ];

    List<VideoItem> fetched = [];
    
    // 生成正好 20 张卡片，绝无重复项！
    for (int i = 0; i < localAnimeAssets.length; i++) {
        final anime = localAnimeAssets[i];
        final videoUrl = i < videoPool.length ? videoPool[i] : null;
        
        fetched.add(VideoItem(
        id: i,
        // 这里精心调整了高度让它看上去像真正的瀑布流卡片
        height: 250.0 + (i % 4) * 50,
        title: anime['title']!,
        author: nicknames[i % nicknames.length],
        imageUrl: anime['url']!,
        videoUrl: videoUrl, // 挂载视频地址
        quote: quotes[i % quotes.length],
        likeCount: (i * 123 + 555) % 3000,
        colorValue: Colors.primaries[i % Colors.primaries.length].value,
      ));
    }
    
    return fetched;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.deepPurpleAccent]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  '发现动态',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        centerTitle: false,
        elevation: 0,
          backgroundColor: Colors.white.withOpacity(0.85),
          surfaceTintColor: Colors.transparent,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(color: Colors.transparent),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: Colors.pinkAccent,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.pinkAccent,
                unselectedLabelColor: Colors.black54,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: '推荐'),
                  Tab(text: '追番'),
                  Tab(text: '直播'),
                  Tab(text: '专区'),
                ],
              ),
            ),
          ),
          actions: [
            const PremiumSearchBar(),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => setState(() {
                _videoFuture = fetchVideos();
              }),
              icon: const Icon(Icons.refresh_rounded, color: Colors.black87, size: 22),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle_outlined, color: Colors.black87, size: 24),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          // 第一屏：推荐（包含 Banner + 瀑布流）
          Center(
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

                      return CustomScrollView(
                        slivers: [
                          // 顶部大屏 Banner 轮播 (Hero)
                          SliverToBoxAdapter(
                            child: AspectRatio(
                              aspectRatio: 21 / 9, // 21:9 超宽比例，完美适配 4K 火影背景，极具电影感
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset('assets/images/banner.jpg', fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      bottom: 20,
                                      left: 24,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('年度力荐', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2)),
                                          SizedBox(height: 4),
                                          Text('全球动漫新番预告', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
                                          Text('实时更新 • 感受跨越次元的视听盛宴', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 瀑布流内容区
                        SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            sliver: SliverMasonryGrid.count(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childCount: items.length,
                              itemBuilder: (context, index) {
                                return VideoCard(item: items[index]);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // 其他 Mock 屏
          const Center(child: Text('【追番】内容尚未实装', style: TextStyle(fontSize: 18, color: Colors.black54))),
          const Center(child: Text('【直播】内容尚未实装', style: TextStyle(fontSize: 18, color: Colors.black54))),
          const Center(child: Text('【专区】内容尚未实装', style: TextStyle(fontSize: 18, color: Colors.black54))),
        ],
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

class VideoCard extends StatefulWidget {
  final VideoItem item;
  const VideoCard({super.key, required this.item});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.videoUrl != null) {
      // 彻底解决跨域问题：直接加载本地高清视频资源
      _controller = VideoPlayerController.asset(widget.item.videoUrl!)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _controller?.setLooping(true);
            _controller?.setVolume(0); // 默认静音预览，提升体验
            _controller?.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/detail/${widget.item.id}', extra: widget.item),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: widget.item.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(widget.item.colorValue).withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 背景层与视频层：采用逻辑切换
                Positioned.fill(
                  child: _isInitialized && _controller != null
                      ? FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      : widget.item.imageUrl.startsWith('http')
                          ? Image.network(
                              widget.item.imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                ),

                // 第三层：更细腻的渐变蒙层，强化高级感
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.4, 0.6, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // 第四层：信息排版与毛玻璃标签
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.item.videoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_fill, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Text(
                        widget.item.quote,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFFF0F0F0),
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1))],
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
                                  backgroundColor: Color(widget.item.colorValue),
                                  child: const Icon(Icons.person, size: 14, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.item.author,
                                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Consumer<LikeStore>(
                            builder: (context, store, _) {
                              final liked = store.isLiked(widget.item.id);
                              return Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: liked ? Colors.pinkAccent : Colors.white,
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

class PremiumSearchBar extends StatefulWidget {
  const PremiumSearchBar({super.key});

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar> {
  bool _isHovered = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = _isHovered || _focusNode.hasFocus;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) {
        if (!_focusNode.hasFocus && _controller.text.isEmpty) {
          setState(() => _isHovered = false);
        }
      },
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutExpo,
          width: isActive ? 280 : 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? Colors.grey.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive ? Colors.pinkAccent.withOpacity(0.08) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon wrapped in GestureDetector to trigger focus
              GestureDetector(
                onTap: () {
                  setState(() => _isHovered = true);
                  _focusNode.requestFocus();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isActive ? Icons.search_rounded : Icons.search_outlined,
                      key: ValueKey(isActive),
                      color: isActive ? Colors.pinkAccent : Colors.black87,
                      size: isActive ? 22 : 24,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isActive ? 1.0 : 0.0,
                  curve: Curves.easeIn,
                  child: isActive
                      ? TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5, // 避免某些字体拥挤产生奇怪连字
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintText: '搜索 高分神作...',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
                            border: InputBorder.none,
                            isCollapsed: true, // 极其重要：防止内部 padding 产生奇怪的溢出字母或黑块
                          ),
                          onTapOutside: (_) {
                            _focusNode.unfocus();
                            if (_controller.text.isEmpty) {
                              setState(() => _isHovered = false);
                            }
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

