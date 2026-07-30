import "package:flutter/material.dart";

class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [

          const SizedBox(
            width: 28,
            height: 28,
            child:
                CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          ),

          if (message != null) ...[
            const SizedBox(
              height: 16,
            ),

            Text(
              message!,
              style:
                  const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}