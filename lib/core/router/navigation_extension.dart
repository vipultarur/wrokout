import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// NavigationX extension on BuildContext for clean typed navigation calls.
extension NavigationX on BuildContext {
  /// Navigate to target route.
  void goTo(String location, {Object? extra}) {
    go(location, extra: extra);
  }

  /// Push target route onto current stack.
  void pushRoute(String location, {Object? extra}) {
    push(location, extra: extra);
  }

  /// Pop current route off navigation stack.
  void goBack() {
    pop();
  }

  /// Replace current route with target route.
  void goReplace(String location, {Object? extra}) {
    pushReplacement(location, extra: extra);
  }

  /// Clear entire navigation stack and go to home route.
  void goAndClear(String location) {
    while (canPop()) {
      pop();
    }
    go(location);
  }
}
