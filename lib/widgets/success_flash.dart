import "package:flutter/material.dart";

class SuccessFlash
    extends StatelessWidget {
  final bool visible;

  const SuccessFlash({
    super.key,
    required this.visible,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity:
            visible ? 1 : 0,

        duration:
            const Duration(
          milliseconds: 180,
        ),

        child: Container(
          color: Colors.green
              .withValues(alpha: 0.25),
        ),
      ),
    );
  }
}