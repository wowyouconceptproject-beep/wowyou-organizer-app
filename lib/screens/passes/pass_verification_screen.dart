import "dart:convert";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../services/pass_service.dart";

class PassVerificationScreen extends StatefulWidget {
  const PassVerificationScreen({super.key});

  @override
  State<PassVerificationScreen> createState() =>
      _PassVerificationScreenState();
}

class _PassVerificationScreenState
    extends State<PassVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passService = PassService();

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verifyPass() async {
    final auth = context.read<AuthProvider>();

    if (!auth.canVerifyPass) {
      setState(() {
        _error = "You do not have permission to verify passes.";
        _result = null;
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    try {
      final response = await _passService.verifyPass(
        _tokenController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _result = response;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst("Exception: ", "")
        .trim();
  }

  String _formatValue(dynamic value) {
    if (value == null) return "Not provided";

    if (value is Map || value is List) {
      return const JsonEncoder.withIndent("  ").convert(value);
    }

    if (value is bool) {
      return value ? "Yes" : "No";
    }

    return value.toString();
  }

  bool? _successValue() {
    final result = _result;
    if (result == null) return null;

    final value = result["success"];

    if (value is bool) return value;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.canVerifyPass) {
      return Scaffold(
        appBar: AppBar(title: const Text("Verify Pass")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "You do not have permission to verify attendee passes.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Pass"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              "Attendee Pass Verification",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter the attendee's pass token to check its status with the server.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _tokenController,
                    enabled: !_loading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_loading) _verifyPass();
                    },
                    decoration: InputDecoration(
                      labelText: "Pass token",
                      hintText: "Enter or paste the pass token",
                      prefixIcon: const Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Enter a pass token.";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loading ? null : _verifyPass,
                    icon: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: Text(
                      _loading ? "Verifying..." : "Verify Pass",
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              _MessagePanel(
                icon: Icons.error_outline,
                title: "Verification failed",
                message: _error!,
                color: Colors.red,
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              _VerificationResult(
                result: _result!,
                success: _successValue(),
                formatValue: _formatValue,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerificationResult extends StatelessWidget {
  final Map<String, dynamic> result;
  final bool? success;
  final String Function(dynamic) formatValue;

  const _VerificationResult({
    required this.result,
    required this.success,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final color = success == true
        ? Colors.green
        : success == false
            ? Colors.red
            : Colors.blueGrey;

    final title = success == true
        ? "Verification successful"
        : success == false
            ? "Pass not verified"
            : "Server response";

    final message = result["message"]?.toString();

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success == true
                      ? Icons.check_circle_outline
                      : success == false
                          ? Icons.cancel_outlined
                          : Icons.info_outline,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (message != null && message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(message),
            ],
            const Divider(height: 28),
            const Text(
              "Server response details",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SelectableText(
              formatValue(result),
              style: const TextStyle(
                fontSize: 12,
                fontFamily: "monospace",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}