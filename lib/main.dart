import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Performance Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FeedPage(),
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // 生成一些模拟数据
  final List<VideoItem> items = List.generate(50, (index) {
    return VideoItem(
      id: index,
      // 随机生成不同的高度来模拟瀑布流效果
      height: 150.0 + Random().nextInt(150),
      title: '视频封面 $index',
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('瀑布流性能优化 Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return VideoCard(item: items[index]);
        },
      ),
    );
  }
}

// 模拟视频数据模型
class VideoItem {
  final int id;
  final double height;
  final String title;
  
  VideoItem({
    required this.id,
    required this.height,
    required this.title,
  });
}

class VideoCard extends StatefulWidget {
  final VideoItem item;

  const VideoCard({super.key, required this.item});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  // 使用 ValueNotifier 实现局部状态管理
  // 
  // 【深入对比：Flutter ValueNotifier vs Vue3 ref】
  //
  // 1. Flutter 的 ValueNotifier 机制：
  //    - 显式订阅模式：在 Flutter 中，UI 组件必须通过 ValueListenableBuilder 显式地包裹组件，
  //      将其作为 listener 注册到 ValueNotifier 的内部列表中。
  //    - 手动触发：当 notifier.value 修改时，它会遍历内部所有的 listeners 列表依次调用更新回调，
  //      触发 ValueListenableBuilder 内部的局部 setState 机制，仅重绘自身子节点。
  //    - 不会自动追踪依赖：如果你在 build 方法里直接访问 notifier.value，Flutter 不会自动记住
  //      这个依赖。你必须使用 ValueListenableBuilder/ListenableBuilder 或者手动 addListener。
  //    - 数据局限性：对于复杂对象或集合的内部属性改变（例如修改 List 里的某个元素），
  //      只要对象引用地址没有变，ValueNotifier 就不会触发更新。需要手动调用 notifyListeners()。
  //
  // 2. Vue3 的 ref() & Proxy 响应式机制：
  //    - 隐式依赖收集（依赖追踪）：在 Vue3 setup() 执行或 render 函数执行期间，Vue 全局会有一个
  //      "activeEffect" 的概念。当我们在模板里访问 `ref.value` 或 Proxy 代理的 state 属性时，
  //      会自动触发 getter 拦截，Vue 在此时"自动记录"该组件/effect 依赖了这个数据。
  //    - 自动触发渲染：当数据修改时，触发 setter，Vue 会把收集到的所有依赖（组件级渲染 Effect）推入队列
  //      并异步执行。
  //    - 深层响应：通过 Proxy，Vue3 可以实现对象属性深层监听（reactive），即使修改了对象深处的一个字段，
  //      也能被拦截并触发精确的高效更新。
  //
  // 总结：
  //    - 从 DX (开发者体验) 上讲，Vue3 更"魔法"且省心，心智负担低，开发者不需要手动写 Builder 或挂载监听。
  //    - 从架构上讲，Flutter 是基于不可变的 Widget 树和命令式的监听器，需要明确告知引擎"在这里订阅这部分数据"
  //      以实现局部刷新。这就要求我们在此处 (视频卡片点赞按钮) ，为了不调用外层 Scaffold 的 setState（导致
  //      整个瀑布流的重绘卡顿），必须用 ValueNotifier 配合 ValueListenableBuilder 将重排重绘限制在按钮的层级。
  final ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isLiked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 视频封面区域
          Container(
            height: widget.item.height,
            decoration: BoxDecoration(
              color: Colors.primaries[widget.item.id % Colors.primaries.length].shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          // 底部信息与点赞交互按钮区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '精彩内容',
                  style: TextStyle(fontSize: 14),
                ),
                // 使用 ValueListenableBuilder 进行极致的局部刷新
                // 点击时只会重绘当前的 Icon 组件，整个 VideoCard 以及 FeedPage 都不会重绘，
                // 极大地优化了极其复杂的瀑布流页面的滚动和交互性能！
                ValueListenableBuilder<bool>(
                  valueListenable: isLiked,
                  builder: (context, liked, child) {
                    return IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        // 改变点赞状态，自动触发本层 Builder 的局部重绘
                        isLiked.value = !isLiked.value;
                      },
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // 缩小点击热区
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
