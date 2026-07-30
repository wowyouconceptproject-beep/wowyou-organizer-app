import "package:flutter/material.dart";

class AppTextField extends StatelessWidget {
  final String label;

  final String? hint;

  final TextEditingController controller;

  final TextInputType keyboardType;

  final bool obscure;

  final bool enabled;

  final bool readOnly;

  final bool autofocus;

  final TextCapitalization textCapitalization;

  final TextInputAction textInputAction;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onSubmitted;

  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w600,
            color: Color(0xff111111),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        SizedBox(
          height: 56,
          child: TextFormField(
            controller: controller,

            keyboardType:
                keyboardType,

            obscureText:
                obscure,

            enabled:
                enabled,

            readOnly:
                readOnly,

            autofocus:
                autofocus,

            validator:
                validator,

            textCapitalization:
                textCapitalization,

            textInputAction:
                textInputAction,

            onChanged:
                onChanged,

            onFieldSubmitted: (_) {
              onSubmitted?.call();
            },

            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w500,
              color:
                  Color(0xff111111),
            ),

            decoration:
                InputDecoration(
              hintText: hint,

              hintStyle:
                  const TextStyle(
                color:
                    Color(0xff9CA3AF),
                fontSize: 16,
              ),

              filled: true,

              fillColor:
                  Colors.white,

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        12),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xffE5E7EB),
                ),
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        12),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xffE5E7EB),
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        12),
                borderSide:
                    const BorderSide(
                  color:
                      Colors.black,
                  width: 1.5,
                ),
              ),

              errorBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        12),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xffDC2626),
                ),
              ),

              focusedErrorBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                        12),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xffDC2626),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}