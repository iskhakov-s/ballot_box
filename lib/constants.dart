import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WidgetContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;

  const WidgetContainer({
    Key? key,
    this.height,
    this.width,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: child,
    );
  }
}

class TextContainer extends StatelessWidget {
  final bool? obscureText;
  final String labelText;
  final TextEditingController controller;

  const TextContainer(
      {Key? key,
      this.obscureText,
      required this.controller,
      required this.labelText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
        ),
        obscureText: obscureText ?? false,
      ),
    );
  }
}

class TextFormContainer extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Icon? icon;
  final double? height;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  const TextFormContainer(
      {Key? key,
      this.keyboardType,
      this.validator,
      this.obscureText = false,
      this.textInputAction,
      this.height,
      this.icon,
      this.suffixIcon,
      required this.controller,
      required this.labelText})
      : super(key: key);

  @override
  State<TextFormContainer> createState() => _TextFormContainerState();
}

class _TextFormContainerState extends State<TextFormContainer> {
  bool _textIsObscured = true;

  @override
  void initState() {
    _textIsObscured = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      height: widget.height,
      child: TextFormField(
        autofocus: false,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _textIsObscured,
        onSaved: (value) {
          widget.controller.text = value!;
        },
        validator: widget.validator,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: widget.icon,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          labelText: widget.labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          suffixIcon: _buildSuffixIcon(),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _textIsObscured ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(
            () {
              _textIsObscured = !_textIsObscured;
            },
          );
        },
      );
    }
    return null;
  }
}

void toast(String message, {bool isLongDuration = true}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: isLongDuration ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    webPosition: 'center',
    fontSize: 16.0,
  );
}

void snackbar(BuildContext context, String message, {int ms = 2500}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: ms),
    ),
  );
}

class ListViewScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const ListViewScaffold(
      {Key? key, required this.title, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: children,
        ),
      ),
    );
  }
}
