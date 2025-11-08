import 'package:flutter/material.dart';

class AppPageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final double maxContentWidth;

  const AppPageContainer({
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = false,
    this.maxContentWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox(
      width: double.infinity,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > maxContentWidth
            ? maxContentWidth
            : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: content,
          ),
        );
      },
    );
  }
}
