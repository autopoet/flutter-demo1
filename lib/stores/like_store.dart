import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// 【对比：状态管理方案】
//
// Vue: Pinia
//      export const useLikeStore = defineStore('like', () => { ... })
// 
// Flutter: ChangeNotifier + Provider (本教程采用最经典、最接近 Vue 开发体验的方案)
//
// 1. ChangeNotifier: 相当于一个带有通知能力的 Reactive State
// 2. notifyListeners(): 类似于 Vue 的响应式追踪，但它是显式调用的。
//                      在 Vue 中，你直接 `state.count++`，依赖它的组件就会自动重新渲染；
//                      在 Flutter 中，你通过调用 `notifyListeners()` 来告知订阅者数据变了。
// ─────────────────────────────────────────────

class LikeStore extends ChangeNotifier {
  // 定义内部数据，类比 Pinia 的 state
  final Map<int, bool> _likes = {};

  // 获取某个 ID 的点赞状态
  // 类比 Vue 的 Computed 或 普通 Getter
  bool isLiked(int id) => _likes[id] ?? false;

  // 切换点赞状态
  // 类比 Pinia 的 Action
  void toggleLike(int id) {
    if (_likes.containsKey(id)) {
      _likes[id] = !_likes[id]!;
    } else {
      _likes[id] = true;
    }
    
    // 关键！手动发出通知，类比触发 Vue 的 Effect 更新
    notifyListeners();
  }
}
