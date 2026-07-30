import "package:flutter/material.dart";

class ScannerControls extends StatelessWidget {
  final bool torchOn;

  final VoidCallback onTorch;

  final VoidCallback onManualSearch;

  const ScannerControls({
    super.key,
    required this.torchOn,
    required this.onTorch,
    required this.onManualSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTorch,
            icon: Icon(
              torchOn
                  ? Icons.flashlight_off
                  : Icons.flashlight_on,
            ),
            label: Text(
              torchOn
                  ? "Torch Off"
                  : "Torch On",
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                56,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onManualSearch,
            icon: const Icon(
              Icons.search,
            ),
            label: const Text(
              "Manual Search",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(
                double.infinity,
                56,
              ),
            ),
          ),
        ),
      ],
    );
  }
}