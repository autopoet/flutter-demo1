import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';
import '../stores/like_store.dart';

class DetailPage extends StatefulWidget {
  final int id;
  final VideoItem item;

  const DetailPage({
    super.key,
    required this.id,
    required this.item,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.videoUrl != null) {
      _controller = VideoPlayerController.asset(widget.item.videoUrl!)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _controller?.play();
            _controller?.setLooping(true);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '视频预览',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          if (isDesktop) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左侧主视频和信息 (70% width)
                      Expanded(
                        flex: 7,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildVideoPlayer(context, isDesktop: true),
                              const SizedBox(height: 20),
                              _buildVideoTitle(context),
                              const SizedBox(height: 12),
                              _buildAuthorAndActionsRow(context),
                              const SizedBox(height: 20),
                              _buildDescriptionBox(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // 右侧推荐列表 (30% width)
                      Expanded(
                        flex: 3,
                        child: _buildRelatedVideos(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // 移动端布局
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVideoPlayer(context, isDesktop: false),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoTitle(context),
                      const SizedBox(height: 12),
                      _buildAuthorAndActionsRow(context, isMobile: true),
                      const SizedBox(height: 16),
                      _buildDescriptionBox(),
                      const Divider(height: 40),
                      const Text('接下来播放', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildRelatedVideos(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, {required bool isDesktop}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: isDesktop ? BorderRadius.circular(16) : BorderRadius.zero,
        boxShadow: isDesktop ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Hero(
          tag: 'video-${widget.item.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!_isInitialized)
                widget.item.imageUrl.startsWith('http')
                    ? Image.network(widget.item.imageUrl, fit: BoxFit.cover)
                    : Image.asset(widget.item.imageUrl, fit: BoxFit.cover),
              
              if (_isInitialized && _controller != null)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              
              if (!_isInitialized && widget.item.videoUrl != null)
                const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoTitle(BuildContext context) {
    return Text(
      widget.item.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            height: 1.3,
            color: Colors.black87,
          ),
    );
  }

  Widget _buildAuthorAndActionsRow(BuildContext context, {bool isMobile = false}) {
    final authorSection = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Color(widget.item.colorValue),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.author, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${widget.item.likeCount} 粉丝', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            minimumSize: const Size(60, 36),
          ),
          child: const Text('关注', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );

    final actionSection = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
          child: Consumer<LikeStore>(
            builder: (context, store, _) {
              final liked = store.isLiked(widget.item.id);
              return Row(
                children: [
                  IconButton(
                    icon: Icon(liked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 18, color: liked ? Colors.black87 : Colors.black54),
                    onPressed: () => store.toggleLike(widget.item.id),
                  ),
                  Container(width: 1, height: 20, color: Colors.black12),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_outlined, size: 18, color: Colors.black54),
                    onPressed: () {},
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [Icon(Icons.share_outlined, size: 18), SizedBox(width: 6), Text('分享', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          authorSection,
          const SizedBox(height: 12),
          actionSection,
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        authorSection,
        actionSection,
      ],
    );
  }

  Widget _buildDescriptionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.item.likeCount * 8} 次观看  •  2026年4月',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            '这里是名台词鉴赏：“${widget.item.quote}”\n在这个史诗级的重构版本中，我们模拟了如同顶端流媒体般的内容简介排版。',
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedVideos() {
    // 渲染一串模拟的“接下来播放”列表
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(8, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/anime${index + 2}.jpg',
                  width: 160,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => Container(width:160, height:90, color: Colors.grey[300]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '推荐动漫短片/高燃剪辑 AMV - 第 ${index + 1} 期',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('知名UP主_${index}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text('${(index+1)*3}万次观看', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
