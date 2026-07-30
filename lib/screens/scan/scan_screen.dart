import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../providers/scan_provider.dart";

import "../../widgets/camera_overlay.dart";
import "../../widgets/error_flash.dart";
import "../../widgets/scan_beep.dart";
import "../../widgets/scanner_controls.dart";
import "../../widgets/scanner_status_bar.dart";
import "../../widgets/success_flash.dart";

import "qr_camera.dart";
import "scan_result_card.dart";

class ScanScreen extends StatelessWidget {
  const ScanScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return const _ScanView();
  }
}

class _ScanView
    extends StatelessWidget {
  const _ScanView();

  @override
  Widget build(
    BuildContext context,
  ) {
    final auth =
        context.watch<AuthProvider>();

    final scan =
        context.watch<ScanProvider>();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor:
            Colors.white,
        elevation: 0,
        titleSpacing: 16,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Scan Pass",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            if (auth.event != null)
              Text(
                auth.event!.title,
                style:
                    const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w500,
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
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Stack(
                  children: [

                    Positioned.fill(
                      child: QRCamera(
                        controller:
                            scan.camera,

                        enabled:
                            !scan.busy,

                        onScanned:
                            (token) async {

                          HapticFeedback
                              .lightImpact();

                          await scan.scan(
                            token,
                          );

                          if (scan.result !=
                              null) {
                            await ScanBeep
                                .success();
                          } else {
                            await ScanBeep
                                .error();
                          }
                        },
                      ),
                    ),

                    const Positioned.fill(
                      child:
                          CameraOverlay(),
                    ),

                    Positioned.fill(
                      child: SuccessFlash(
                        visible:
                            scan.result !=
                                null,
                      ),
                    ),

                    Positioned.fill(
                      child: ErrorFlash(
                        visible:
                            scan.error !=
                                null,
                      ),
                    ),

                    ScanResultCard(
                      result:
                          scan.result,

                      error:
                          scan.error,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  const BoxDecoration(
                color: Colors.white,

                border: Border(
                  top: BorderSide(
                    color: Color(
                      0xffECECEC,
                    ),
                  ),
                ),
              ),

              child: Column(
                children: [

                  ScannerStatusBar(
                    busy: scan.busy,
                    error: scan.error,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  ScannerControls(
                    torchOn:
                        scan.torchOn,

                    onTorch:
                        scan.toggleTorch,

                    onManualSearch:
                        () {

                      // TODO
                      // Navigator.pushNamed(
                      //   context,
                      //   "/manual-search",
                      // );

                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  if (scan.result !=
                      null)

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffF7F7F7,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          const Text(
                            "Attendance",
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            "${scan.result!.attendance} / ${scan.result!.totalTickets}",
                            style:
                                const TextStyle(
                              fontSize: 30,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}