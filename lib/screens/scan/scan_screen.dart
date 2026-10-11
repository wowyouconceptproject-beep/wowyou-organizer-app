import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../providers/scan_provider.dart";

import "../../widgets/camera_overlay.dart";
import "../../widgets/error_flash.dart";
import "../../widgets/scan_beep.dart";
import "../../widgets/success_flash.dart";
import "../../widgets/scanner_controls.dart";
import "../../widgets/scanner_status_bar.dart";

import "qr_camera.dart";
import "scan_result_card.dart";

class ScanScreen extends StatelessWidget {
  const ScanScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const _ScanView();
  }
}

class _ScanView extends StatefulWidget {
  const _ScanView();

  @override
  State<_ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<_ScanView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (!mounted) return;

        final auth = context.read<AuthProvider>();
        final scan = context.read<ScanProvider>();

        final staffId = auth.staffId;

        if (staffId != null && staffId.isNotEmpty) {
          scan.setStaffId(staffId);
        }

        if (auth.event != null) {
          await scan.connectSocket(auth.event!.id);
        }

        if (!mounted) return;

        await scan.startNfcListener();
      },
    );
  }

  @override
  void dispose() {
    final scan = context.read<ScanProvider>();

    scan.disconnectSocket();
    scan.stopNfcListener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.canScanQr) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            "You do not have permission to scan attendee passes.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final scan = context.watch<ScanProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Scan Pass",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (auth.event != null)
              Text(
                auth.event!.title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: QRCamera(
                        controller: scan.camera,
                        enabled: !scan.busy,
                        onScanned: (token) async {
                          HapticFeedback.lightImpact();

                          await scan.scanQr(token);

                          if (!mounted) return;

                          if (scan.result != null) {
                            await ScanBeep.success();
                          } else {
                            await ScanBeep.error();
                          }
                        },
                      ),
                    ),
                    const Positioned.fill(
                      child: CameraOverlay(),
                    ),
                    Positioned.fill(
                      child: SuccessFlash(
                        visible: scan.result != null,
                      ),
                    ),
                    Positioned.fill(
                      child: ErrorFlash(
                        visible: scan.error != null,
                      ),
                    ),
                    ScanResultCard(
                      result: scan.result,
                      error: scan.error,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xffECECEC),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.nfc,
                          color: scan.busy
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            scan.busy
                                ? "Scanning..."
                                : "NFC Ready • Hold pass near device",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ScannerStatusBar(
                    busy: scan.busy,
                    error: scan.error,
                  ),
                  const SizedBox(height: 16),
                  ScannerControls(
                    torchOn: scan.torchOn,
                    onTorch: scan.toggleTorch,
                    onManualSearch: () {
                      // Existing manual-search behavior remains unchanged.
                    },
                  ),
                  if (scan.result != null &&
                      scan.result!.alreadyCheckedIn) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF4E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Attendee already checked in.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (scan.capacity != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Live Capacity",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${scan.capacity!.currentOccupancy} / "
                            "${scan.capacity!.capacity}",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${scan.capacity!.occupancyPercentage.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}