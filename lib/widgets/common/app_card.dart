import "package:flutter/material.dart";

class AppCard extends StatelessWidget {
  final Widget child;

  final EdgeInsets? padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          padding ??
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              const Color(
            0xffE5E7EB,
          ),
        ),
      ),

      child: child,
    );
  }
}