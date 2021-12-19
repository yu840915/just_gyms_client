import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/user/avatar_uri_factory.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AvatarButton extends StatelessWidget {
  final void Function()? action;
  final String userId;
  final double size;
  final Color? themeColor;
  Color get _themeColor => themeColor ?? Colors.grey.shade400;
  AvatarButton(
      {required this.userId,
      this.action,
      this.size = 80,
      this.themeColor,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: action,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: StadiumBorder(),
        shadowColor: AppColors.theme,
      ),
      child: Ink(
        height: size,
        width: size,
        decoration: BoxDecoration(
          border: Border.all(color: _themeColor),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: CachedNetworkImage(
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) {
            FLog.info(text: error.toString());
            return _buildPlaceholder();
          },
          imageUrl: AvatarUriFactory.uriForUserId(userId).toString(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.person,
      color: _themeColor,
      size: size - 8,
    );
  }
}
