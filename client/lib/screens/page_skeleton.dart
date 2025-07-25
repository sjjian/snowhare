import 'package:client/screens/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

class PageSkeleton extends StatelessWidget {
  final Widget? topBar;
  final Widget? bottomBar;
  final Widget child;
  final Widget? drawer;

  const PageSkeleton(
      {Key? key, this.topBar, this.bottomBar, this.drawer, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavRail(
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer, // 全局背景色
        child: Column(children: [
          Container(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest, // header 背景色
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: MoveWindow(
                      // todo: MoveWindow 存在延迟, 看后续如何优化, 参考: https://github.com/bitsdojo/bitsdojo_window/issues/187
                      child: topBar,
                    ),
                  ),
                  if (!kIsWeb) const WindowButtons(),
                ],
              )),
          Expanded(
            child: child,
          ),
          Container(
            height: 40,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest, // bottom 背景色
            child: bottomBar,
          )
        ]),
      ),
    );
  }
}
