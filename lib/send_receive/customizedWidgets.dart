import 'package:flutter/material.dart';

class OneTapElevatedButton extends StatefulWidget {
  @override
  _OneTapElevatedButtonState createState() => _OneTapElevatedButtonState();

  final onPressed;
  final child1;
  final child2;

  OneTapElevatedButton({this.onPressed, this.child1, this.child2});
}

class _OneTapElevatedButtonState extends State<OneTapElevatedButton> {
  var disabled = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.resolveWith((states) => disabled ? Colors.grey : Colors.blue)),
        onPressed: () {
          if (!disabled) {
            widget.onPressed();
            setState(() {
              disabled = true;
            });
          }
        },
        child: disabled ? widget.child2 : widget.child1);
  }
}

class OneTapIconButton extends StatefulWidget {
  @override
  _OneTapIconButtonState createState() => _OneTapIconButtonState();

  final onPressed;
  final icon;

  OneTapIconButton({this.onPressed, this.icon});
}

class _OneTapIconButtonState extends State<OneTapIconButton> {
  var disabled = false;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (!disabled) {
          widget.onPressed();
          setState(() {
            disabled = true;
          });
        }
      },
      icon: widget.icon,
    );
  }
}
