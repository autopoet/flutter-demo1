import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/video_item.dart';
import 'pages/feed_page.dart';
import 'pages/detail_page.dart';
import 'pages/main_layout.dart';
import 'stores/like_store.dart';

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
    ShellRoute(
      builder: (context, state, child) {
        // 全局套用 响应式骨架 (NavigationRail / BottomNavigationBar)
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const FeedPage(),
        ),
      ],
    ),
    
    // 详情页跳出 ShellRoute（像 B站/YouTube 一样，播放页是沉浸式的新窗口或全屏覆盖）
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
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
    // 【对比：全局状态注入】
    //
    // Vue: createApp(App).use(createPinia())
    // 
    // Flutter: 使用 [ChangeNotifierProvider] 包裹组件树，
    //          这就让所有子组件都能通过 context.watch / context.read 访问到 LikeStore。
    //          这本质上是利用了 Flutter 极其强大的 [InheritedWidget] (也就是 Vue 的 provide/inject)
    // ─────────────────────────────────────────────
    return ChangeNotifierProvider(
      create: (_) => LikeStore(),
      child: MaterialApp.router(
        title: 'Flutter Feed Demo',
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFE91E63),
          fontFamily: 'PingFang SC, Microsoft YaHei, Roboto, sans-serif', // 彻底修复 CanvasKit 中文乱码/方块/奇怪字母
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
