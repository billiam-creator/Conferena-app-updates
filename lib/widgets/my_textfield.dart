import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.autofillHints,
    this.hasError = false,
    this.onChanged,
  });

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {

  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscured,
        autofillHints: widget.autofillHints,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.hasError
                  ? Colors.red.shade400
                  : (isDark ? Colors.grey.shade700 : Colors.white),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.hasError ? Colors.red.shade500 : Colors.grey.shade400,
              width: widget.hasError ? 1.5 : 1.0,
            ),
          ),
          fillColor: widget.hasError
              ? (isDark ? Colors.red.shade900.withOpacity(0.25) : Colors.red.shade50)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500]),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                )
              : null,
        ),
      ),
    );
  }
}