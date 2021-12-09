import 'package:flutter/material.dart';

class AvatarButton extends StatelessWidget {
  final void Function()? action;
  AvatarButton({this.action, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: action, child: CircleAvatar());
  }
}
