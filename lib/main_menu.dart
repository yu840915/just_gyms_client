import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/configs.dart';
import 'package:where_gym/me/favorite_list_page.dart';
import 'package:where_gym/shared_appearances.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuItem>(
      itemBuilder: (context) {
        return [
          _buildItem('收藏', _MenuItem.favorites),
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
      onSelected: (item) {
        switch (item) {
          case _MenuItem.favorites:
            _showFavorites(context);
            break;
          case _MenuItem.tos:
            launch(Configs.instance.tosLink, forceWebView: true);
            break;
          case _MenuItem.pp:
            launch(Configs.instance.ppLink, forceWebView: true);
            break;
          case _MenuItem.contactUs:
            launch(Configs.instance.contactLink, forceWebView: false);
            break;
        }
      },
    );
  }

  void _showFavorites(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FavoriteListPage()));
  }

  PopupMenuItem<_MenuItem> _buildItem(String title, _MenuItem value) {
    return PopupMenuItem(
      child: Text(title),
      value: value,
    );
  }
}

enum _MenuItem {
  favorites,
  tos,
  pp,
  contactUs,
}
