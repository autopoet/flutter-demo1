import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/video_item.dart';
import 'pages/feed_page.dart';
import 'pages/detail_page.dart';
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
