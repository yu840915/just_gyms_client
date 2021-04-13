import 'package:flutter/material.dart';
import 'package:where_gym/shared_appearances.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuItem>(
      itemBuilder: (context) {
        return [
          _buildItem('服務條款', _MenuItem.tos),
          _buildItem('隱私權政策', _MenuItem.pp),
          _buildItem('聯絡我們', _MenuItem.contactUs),
        ];
      },
      icon: Container(
        child: Icon(
          Icons.menu,
          color: AppColors.theme,
          size: 30,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        width: 40,
        height: 40,
      ),
      iconSize: 40,
    );
  }

  PopupMenuItem<_MenuItem> _buildItem(String title, _MenuItem value) {
    return PopupMenuItem(
      child: Text(title),
      value: value,
    );
  }
}

enum _MenuItem {
  tos,
  pp,
  contactUs,
}
