import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/appointment/user_appointments_page.dart';
import 'package:where_gym/configs.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/login/authenticators.dart';
import 'package:where_gym/me/favorite_list_page.dart';
import 'package:where_gym/shared_appearances.dart';

class MainMenu extends StatelessWidget {
  void _logout(BuildContext context) async {
    try {
      final logout = await showDialog(
        context: context,
        builder: (context) => AlertFactory.actionAlert(
          context,
          title: '是否要登出？',
          actions: [
            PlatformDialogAction(
              child: Text('登出'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        ),
      );
      if (logout != null && logout) {
        await Authenticators.logOut();
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (builder) => AlertFactory.errorAlert(context, error: e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return StreamBuilder<List<Gym>>(
        stream: bloc.adminGymList.onGyms,
        builder: (context, snapshot) {
          return PopupMenuButton<_MenuItem>(
            itemBuilder: (context) {
              return [
                _buildItem('收藏', _MenuItem.favorites),
                _buildItem('我的預約', _MenuItem.myAppointments),
                if (snapshot.hasData && snapshot.data.isNotEmpty)
                  _buildItem('場租管理', _MenuItem.adminGyms),
                _buildItem('服務條款', _MenuItem.tos),
                _buildItem('隱私權政策', _MenuItem.pp),
                _buildItem('聯絡我們', _MenuItem.contactUs),
                if (bloc.isLoggedIn) _buildItem('登出', _MenuItem.logOut),
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
            onSelected: (item) async {
              switch (item) {
                case _MenuItem.favorites:
                  _showFavorites(context);
                  break;
                case _MenuItem.myAppointments:
                  _showMyAppointments(context);
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
                case _MenuItem.adminGyms:
                  //TODO show admin gym list
                  break;
                case _MenuItem.logOut:
                  _logout(context);
                  break;
              }
            },
          );
        });
  }

  void _showFavorites(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FavoriteListPage()));
  }

  void _showMyAppointments(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UserAppointmentsPage()));
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
  logOut,
  myAppointments,
  adminGyms,
}
