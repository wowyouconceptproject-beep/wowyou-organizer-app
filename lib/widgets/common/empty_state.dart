import "package:flutter/material.dart";

class EmptyState extends StatelessWidget {
  final String title;

  final String message;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(32),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              const Color(
            0xffE5E7EB,
          ),
        ),
      ),

      child: Column(
        children: [

          Text(
            title,
            style:
                const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 15,
              color:
                  Color(
                0xff6B7280,
              ),
            ),
          ),
        ],
      ),
    );
  }
}