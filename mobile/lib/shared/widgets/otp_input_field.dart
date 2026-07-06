// mobile/lib/shared/widgets/otp_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autoFocus;
  final bool obscureText;
  final InputDecoration? decoration;
  final Widget Function(BuildContext context, Widget child)? inputDecorationBuilder;
  final double fieldWidth;
  final double spacing;

  const OtpInputField({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
    this.controller,
    this.autoFocus = true,
    this.obscureText = false,
    this.decoration,
    this.inputDecorationBuilder,
    this.fieldWidth = 55,
    this.spacing = 10,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  String get _otp => _controllers.map((e) => e.text).join();

  @override
  void initState() {
    super.initState();

    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes.first.requestFocus();
      });
    }

    // Sync external controller if provided
    widget.controller?.addListener(_handleExternalChange);
  }

  void _handleExternalChange() {
    final text = widget.controller!.text;
    if (text.length == widget.length) {
      for (int i = 0; i < widget.length; i++) {
        _controllers[i].text = text[i];
      }
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) node.dispose();
    for (var ctrl in _controllers) ctrl.dispose();
    widget.controller?.removeListener(_handleExternalChange);
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Handle paste (full OTP)
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    widget.onChanged?.call(_otp);

    if (_otp.length == widget.length) {
      widget.onCompleted(_otp);
    }
  }

  void _handlePaste(String pasted) {
    final clean = pasted.replaceAll(RegExp(r'[^0-9]'), '');

    for (int i = 0; i < widget.length; i++) {
      if (i < clean.length) {
        _controllers[i].text = clean[i];
      } else {
        _controllers[i].clear();
      }
    }

    widget.onChanged?.call(_otp);

    if (clean.length == widget.length) {
      widget.onCompleted(clean);
      _focusNodes.last.unfocus();
    }
  }

  void _onKeyPress(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  InputDecoration _buildDecoration(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isFilled = _controllers[index].text.isNotEmpty;
    final borderColor = isFilled
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor.withOpacity(0.6), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.2),
      ),
      filled: true,
      fillColor: isFilled
          ? theme.colorScheme.primary.withOpacity(0.08)
          : theme.colorScheme.surfaceVariant.withOpacity(0.08),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (index) {
          return Container(
            width: widget.fieldWidth,
            margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) => _onKeyPress(event, index),
              child: Builder(
                builder: (context) {
                  final field = TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    autofocus: index == 0 && widget.autoFocus,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 1,
                    obscureText: widget.obscureText,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: widget.decoration ?? _buildDecoration(context, index),
                    onChanged: (value) => _onChanged(value, index),
                  );

                  return widget.inputDecorationBuilder?.call(context, field) ?? field;
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}