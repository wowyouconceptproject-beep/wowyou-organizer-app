import "package:flutter/material.dart";

class AppErrorCard extends StatelessWidget {
  final String title;

  final String description;

  const AppErrorCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xffFEF2F2),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0xffFECACA),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xffDC2626),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color:
                  Color(0xff7F1D1D),
            ),
          ),
        ],
      ),
    );
  }
}