import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import "../../config/api.dart";
import "../../utils/storage.dart";

class EventPulseScreen extends StatefulWidget {
  const EventPulseScreen({super.key});

  @override
  State<EventPulseScreen> createState() =>
      _EventPulseScreenState();
}

class _EventPulseScreenState
    extends State<EventPulseScreen> {
  static const Color _background = Color(0xFFF5F7FA);
  static const Color _primary = Color(0xFF4338CA);
  static const Color _textPrimary = Color(0xFF172033);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final _zoneController = TextEditingController();
  final _noteController = TextEditingController();

  String? _crowdLevel;
  String? _safetyStatus;
  String? _sentiment;

  bool _isSubmitting = false;

  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _zoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitObservation() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_crowdLevel == null ||
        _safetyStatus == null ||
        _sentiment == null) {
      setState(() {
        _errorMessage =
            'Complete all observation categories before submitting.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final token = await Storage.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(
          'Your operations session has expired. Please log in again.',
        );
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/operations/pulse',
      );

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'zone': _zoneController.text.trim(),
              'crowdLevel': _crowdLevel,
              'safetyStatus': _safetyStatus,
              'sentiment': _sentiment,
              'note': _noteController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic> body;

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw const FormatException(
            'Invalid server response.',
          );
        }

        body = decoded;
      } on FormatException {
        throw Exception(
          'The server returned an invalid response.',
        );
      }

      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        throw Exception(
          body['message']?.toString() ??
              'Your session is not authorized to submit observations.',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['success'] != true) {
        throw Exception(
          body['message']?.toString() ??
              'Unable to submit the observation.',
        );
      }

      if (!mounted) return;

      setState(() {
        _successMessage =
            'Observation submitted successfully.';
        _zoneController.clear();
        _noteController.clear();
        _crowdLevel = null;
        _safetyStatus = null;
        _sentiment = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _readableError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _readableError(Object error) {
    final message = error
        .toString()
        .replaceFirst('Exception: ', '');

    if (message.contains('TimeoutException')) {
      return 'The request timed out. Check your connection and try again.';
    }

    if (message.contains('SocketException')) {
      return 'Unable to connect to the server. Check your internet connection.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _textPrimary,
          ),
        ),
        title: const Text(
          'Event Pulse',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              32,
            ),
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildZoneField(),
              const SizedBox(height: 22),
              _buildCrowdSection(),
              const SizedBox(height: 22),
              _buildSafetySection(),
              const SizedBox(height: 22),
              _buildSentimentSection(),
              const SizedBox(height: 22),
              _buildNotesField(),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                _buildMessage(
                  message: _errorMessage!,
                  isError: true,
                ),
                const SizedBox(height: 14),
              ],
              if (_successMessage != null) ...[
                _buildMessage(
                  message: _successMessage!,
                  isError: false,
                ),
                const SizedBox(height: 14),
              ],
              _buildSubmitButton(),
              const SizedBox(height: 14),
              const Text(
                'Reports are shared with event operations to support '
                'situational awareness and response.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3730A3),
            Color(0xFF6366F1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live field intelligence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Help your team understand conditions on the ground.',
                      style: TextStyle(
                        color: Color(0xFFE0E7FF),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(
            color: Color(0x55FFFFFF),
            height: 1,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 17,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Submit an observation from your assigned event area.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneField() {
    return _sectionCard(
      icon: Icons.location_on_outlined,
      title: 'Observation zone',
      subtitle: 'Where are you reporting from?',
      child: TextFormField(
        controller: _zoneController,
        textCapitalization: TextCapitalization.words,
        maxLength: 100,
        decoration: _inputDecoration(
          hint: 'e.g. Main Entrance, Hall A, VIP Area',
          prefixIcon: Icons.place_outlined,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Enter the zone you are reporting from.';
          }

          if (value.trim().length > 100) {
            return 'Zone must not exceed 100 characters.';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildCrowdSection() {
    return _sectionCard(
      icon: Icons.groups_rounded,
      title: 'Crowd conditions',
      subtitle: 'How busy is this area right now?',
      child: Column(
        children: [
          _choiceTile(
            title: 'Low',
            description: 'Open space and minimal queues',
            icon: Icons.people_outline_rounded,
            value: 'LOW',
            selectedValue: _crowdLevel,
            color: const Color(0xFF16A34A),
            onTap: (value) {
              setState(() {
                _crowdLevel = value;
              });
            },
          ),
          _choiceTile(
            title: 'Moderate',
            description: 'Steady activity and manageable queues',
            icon: Icons.groups_outlined,
            value: 'MODERATE',
            selectedValue: _crowdLevel,
            color: const Color(0xFFCA8A04),
            onTap: (value) {
              setState(() {
                _crowdLevel = value;
              });
            },
          ),
          _choiceTile(
            title: 'High',
            description: 'Dense crowd or growing queues',
            icon: Icons.groups_rounded,
            value: 'HIGH',
            selectedValue: _crowdLevel,
            color: const Color(0xFFEA580C),
            onTap: (value) {
              setState(() {
                _crowdLevel = value;
              });
            },
          ),
          _choiceTile(
            title: 'Critical',
            description: 'Severe crowd pressure requiring assessment',
            icon: Icons.warning_amber_rounded,
            value: 'CRITICAL',
            selectedValue: _crowdLevel,
            color: const Color(0xFFDC2626),
            onTap: (value) {
              setState(() {
                _crowdLevel = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSafetySection() {
    return _sectionCard(
      icon: Icons.shield_outlined,
      title: 'Safety status',
      subtitle: 'Report the current safety situation.',
      child: Column(
        children: [
          _choiceTile(
            title: 'Normal',
            description: 'No issue observed',
            icon: Icons.check_circle_outline_rounded,
            value: 'NORMAL',
            selectedValue: _safetyStatus,
            color: const Color(0xFF16A34A),
            onTap: (value) {
              setState(() {
                _safetyStatus = value;
              });
            },
          ),
          _choiceTile(
            title: 'Caution',
            description: 'A condition requires attention',
            icon: Icons.visibility_outlined,
            value: 'CAUTION',
            selectedValue: _safetyStatus,
            color: const Color(0xFFCA8A04),
            onTap: (value) {
              setState(() {
                _safetyStatus = value;
              });
            },
          ),
          _choiceTile(
            title: 'Incident',
            description: 'A safety incident has been observed',
            icon: Icons.report_outlined,
            value: 'INCIDENT',
            selectedValue: _safetyStatus,
            color: const Color(0xFFEA580C),
            onTap: (value) {
              setState(() {
                _safetyStatus = value;
              });
            },
          ),
          _choiceTile(
            title: 'Emergency',
            description: 'An urgent situation needs immediate assessment',
            icon: Icons.emergency_outlined,
            value: 'EMERGENCY',
            selectedValue: _safetyStatus,
            color: const Color(0xFFDC2626),
            onTap: (value) {
              setState(() {
                _safetyStatus = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentSection() {
    return _sectionCard(
      icon: Icons.mood_outlined,
      title: 'Attendee sentiment',
      subtitle: 'How do attendees appear to be responding?',
      child: Column(
        children: [
          _choiceTile(
            title: 'Very positive',
            description: 'Strongly positive atmosphere',
            icon: Icons.sentiment_very_satisfied_rounded,
            value: 'VERY_POSITIVE',
            selectedValue: _sentiment,
            color: const Color(0xFF15803D),
            onTap: (value) {
              setState(() {
                _sentiment = value;
              });
            },
          ),
          _choiceTile(
            title: 'Positive',
            description: 'Generally happy and engaged',
            icon: Icons.sentiment_satisfied_alt_rounded,
            value: 'POSITIVE',
            selectedValue: _sentiment,
            color: const Color(0xFF16A34A),
            onTap: (value) {
              setState(() {
                _sentiment = value;
              });
            },
          ),
          _choiceTile(
            title: 'Neutral',
            description: 'No strong positive or negative signals',
            icon: Icons.sentiment_neutral_rounded,
            value: 'NEUTRAL',
            selectedValue: _sentiment,
            color: const Color(0xFF64748B),
            onTap: (value) {
              setState(() {
                _sentiment = value;
              });
            },
          ),
          _choiceTile(
            title: 'Negative',
            description: 'Signs of frustration or dissatisfaction',
            icon: Icons.sentiment_dissatisfied_rounded,
            value: 'NEGATIVE',
            selectedValue: _sentiment,
            color: const Color(0xFFEA580C),
            onTap: (value) {
              setState(() {
                _sentiment = value;
              });
            },
          ),
          _choiceTile(
            title: 'Very negative',
            description: 'Strong dissatisfaction or distress',
            icon: Icons.sentiment_very_dissatisfied_rounded,
            value: 'VERY_NEGATIVE',
            selectedValue: _sentiment,
            color: const Color(0xFFDC2626),
            onTap: (value) {
              setState(() {
                _sentiment = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return _sectionCard(
      icon: Icons.notes_rounded,
      title: 'Additional notes',
      subtitle: 'Describe anything the operations team should know.',
      child: TextFormField(
        controller: _noteController,
        minLines: 3,
        maxLines: 5,
        maxLength: 1000,
        textCapitalization: TextCapitalization.sentences,
        decoration: _inputDecoration(
          hint:
              'Describe queues, incidents, attendee concerns, '
              'or other relevant observations...',
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed:
            _isSubmitting ? null : _submitObservation,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor:
              _primary.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 23,
                width: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 19),
                  SizedBox(width: 10),
                  Text(
                    'Submit observation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMessage({
    required String message,
    required bool isError,
  }) {
    final color = isError
        ? const Color(0xFFB91C1C)
        : const Color(0xFF15803D);

    final background = isError
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF0FDF4);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _choiceTile({
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required String? selectedValue,
    required Color color,
    required ValueChanged<String> onTap,
  }) {
    final selected = value == selectedValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.07)
            : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => onTap(value),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : _border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? color : const Color(0xFFCBD5E1),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon == null
          ? null
          : Icon(
              prefixIcon,
              color: _textSecondary,
              size: 20,
            ),
      alignLabelWithHint: alignLabelWithHint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFDC2626),
          width: 1.5,
        ),
      ),
    );
  }
}