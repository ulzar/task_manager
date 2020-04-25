import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  CustomRaisedButton({
    this.child,
    this.color,
    this.borderRadius: 4.0,
    this.onPressed,
    this.height: 50.0,
  });
  final Widget child;
  final Color color;
  final double borderRadius;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: RaisedButton(
        child: child,
        onPressed: onPressed,
        disabledColor: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        color: color,
      ),
      height: height,
    );
  }
}
