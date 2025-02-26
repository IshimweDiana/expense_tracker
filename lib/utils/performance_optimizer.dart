import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PerformanceOptimizer {
  static void enableHighPerformanceMode() {
    if (!kIsWeb) {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  static Widget cacheWidget(Widget child) {
    return RepaintBoundary(child: child);
  }

  static Widget optimizeListView({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  static void disposeControllers(List<dynamic> controllers) {
    for (var controller in controllers) {
      if (controller is ChangeNotifier) {
        controller.dispose();
      }
    }
  }

  static void optimizeMemory() {
    imageCache.clear();
    imageCache.maximumSize = 100;
  }
}
