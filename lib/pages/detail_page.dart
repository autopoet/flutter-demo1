import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/video_item.dart';
import '../stores/like_store.dart';

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
          // ─────────────────────────────────────────────
          // 【对比：响应式布局】
          //
          // Vue: 用 CSS Media Queries (如 @media (min-width: 800px)) 
          //      或者 Tailwind 的 md:flex 等原子类来控制。
          // 
          // Flutter: 用 LayoutBuilder。它在运行时给你当前组件可以占用的宽度和高度，
          //          你可以用 if/else 返回完全不同的 Widget 结构。
          //          比如这里：当宽度 > 800 认为是电脑端，使用左右排列（Row）；
          //          否则认为是手机端，使用上下排列（Column）。
          // ─────────────────────────────────────────────
          final isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            // PC / Web 端样式：左右分栏结构
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左侧：大型视频封面区
                      Expanded(
                        flex: 6,
                        child: _buildCover(context),
                      ),
                      const SizedBox(width: 48),
                      // 右侧：信息与交互区
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 32),
                              _buildAuthorInfo(context),
                              const Divider(height: 64, thickness: 1, color: Colors.black12),
                              _buildDescription(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // 移动端/竖屏样式：居中 + 上下结构
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCover(context),
                      const SizedBox(height: 32),
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildAuthorInfo(context),
                      const Divider(height: 48, thickness: 1, color: Colors.black12),
                      _buildDescription(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 封面的复用组件
  Widget _buildCover(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(item.colorValue).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Hero(
          tag: 'video-${item.id}',
          child: item.imageUrl.startsWith('http') 
            ? Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Color(item.colorValue).withOpacity(0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, url, error) => Container(
                  color: Color(item.colorValue).withOpacity(0.3),
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.white, size: 48),
                  ),
                ),
              )
            : Image.asset(
                item.imageUrl,
                fit: BoxFit.cover,
              ),
        ),
      ),
    );
  }

  // 标题和点赞的复用组件
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Consumer<LikeStore>(
            builder: (context, store, _) {
              final liked = store.isLiked(item.id);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: IconButton(
                  key: ValueKey(liked),
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.pinkAccent : Colors.black54,
                  ),
                  iconSize: 28,
                  onPressed: () {
                    store.toggleLike(item.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 作者信息的复用组件
  Widget _buildAuthorInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(item.colorValue),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.author,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.likeCount} 粉丝',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text('关注', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // 正文的复用组件
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(item.colorValue).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(item.colorValue).withOpacity(0.2)),
          ),
          child: Text(
            '“${item.quote}”',
            style: TextStyle(
              fontSize: 18,
              height: 1.8,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
