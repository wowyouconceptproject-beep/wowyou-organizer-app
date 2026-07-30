import "package:flutter/material.dart";

class AppButton extends StatelessWidget {
  final String text;

  final VoidCallback? onPressed;

  final bool loading;

  final bool secondary;

  final bool expanded;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.secondary = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              secondary
                  ? Colors.white
                  : Colors.black,
          foregroundColor:
              secondary
                  ? Colors.black
                  : Colors.white,
          side: secondary
              ? const BorderSide(
                  color: Color(0xffE5E7EB),
                )
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
      ),
    );

    if (!expanded) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}