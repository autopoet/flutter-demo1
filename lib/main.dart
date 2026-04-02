import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/video_item.dart';
import 'pages/feed_page.dart';
import 'pages/detail_page.dart';

// ─────────────────────────────────────────────
// 【对比：路由入口】
//
// Vue:  main.ts 中 app.use(router)，路由由 createRouter() 单独创建
// Flutter: main.dart 中将 GoRouter 实例直接传给 MaterialApp.router
//          两者都是"先声明路由表，再挂载到 App"的思路
// ─────────────────────────────────────────────

/// 全局路由配置
/// 类比 vue-router 的 createRouter({ routes: [...] })
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // 主路由：瀑布流首页
    // Vue: { path: '/', component: FeedPage }
    GoRoute(
      path: '/',
      builder: (context, state) => const FeedPage(),
    ),

    // 详情页路由，带动态参数 :id
    // Vue: { path: '/detail/:id', component: DetailPage }
    //      在 Vue 中用 useRoute().params.id 获取参数
    //      在 Flutter 中用 state.pathParameters['id'] 获取
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        // 从路由参数里解析 id
        final id = int.parse(state.pathParameters['id']!);
        // 通过 extra 传递完整的数据对象（类比 vue-router 的 state）
        final item = state.extra as VideoItem;
        return DetailPage(id: id, item: item);
      },
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────
    // 【对比：全局主题配置】
    //
    // Vue/CSS: :root { --color-primary: #e91e63; --color-secondary: #ff5722; }
    //          全局 CSS 变量，所有组件通过 var(--color-primary) 访问
    //
    // Flutter: ThemeData 通过 Widget 树向下传递（InheritedWidget 机制）
    //          子组件用 Theme.of(context).colorScheme.primary 访问
    //          两者思路相同，都是"定义在顶层，全局可用"，
    //          但 Flutter 是运行时对象传递，CSS 变量是静态字符串替换
    // ─────────────────────────────────────────────
    return MaterialApp.router(
      title: 'Flutter Feed Demo',
      // 使用 MaterialApp.router 代替 MaterialApp，接入 go_router
      // 类比 Vue 中的 <RouterView /> / createApp(App).use(router)
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // colorSchemeSeed 类似于 CSS 里设置一个主色调，
        // Flutter 会自动生成一整套和谐的配色方案（primary/secondary/surface等）
        colorSchemeSeed: const Color(0xFFE91E63), // 玫瑰粉作为种子色

        // 自定义 AppBar 主题
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),

        // 卡片主题
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
