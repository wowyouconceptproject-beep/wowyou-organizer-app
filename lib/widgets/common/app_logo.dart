import "package:flutter/material.dart";

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [

        Text(
          "WOWYOU",
          style: TextStyle(
            fontSize: 42,
            fontWeight:
                FontWeight.w900,
            letterSpacing: -2,
          ),
        ),

        SizedBox(height: 4),

        Text(
          "OPERATIONS",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            letterSpacing: 4,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }
}