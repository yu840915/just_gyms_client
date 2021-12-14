import 'package:flutter/material.dart';
import 'package:where_gym/user/avatar_uri_factory.dart';

class AvatarButton extends StatelessWidget {
  final void Function()? action;
  final String userId;
  final double size;
  AvatarButton({required this.userId, this.action, this.size = 80, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: action,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: StadiumBorder(),
      ),
      child: Ink(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          image: DecorationImage(
            image: NetworkImage(
              AvatarUriFactory.uriForUserId(userId).toString(),
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: null,
      ),
    );
  }
}
