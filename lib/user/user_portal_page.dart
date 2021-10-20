import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:where_gym/admin_gym_list_page.dart';
import 'package:where_gym/alert_factory.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/appointment/user_appointments_page.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/login/authenticators.dart';
import 'package:where_gym/me/favorite_list_page.dart';
import 'package:where_gym/shared_appearances.dart';

class UserPortalPage extends StatelessWidget {
  void _showFavorites(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FavoriteListPage()));
  }

  void _showMyAppointments(BuildContext context) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UserAppointmentsPage()));
  }

  void _showAdminGymList(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminGymListPage(bloc.adminGymList),
      ),
    );
  }

  void _copyId(BuildContext context) async {
    AppBloc bloc = BlocProvider.of(context);
    await Clipboard.setData(ClipboardData(text: bloc.userRef!.id));
    await Fluttertoast.showToast(msg: '已複製使用者ID');
  }

  void _requestAccountDeletion(BuildContext context) async {}

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
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBarFactory.appBar(
        title: Text(
          '我的',
          style: TextStyles.large.title,
        ),
      ) as PreferredSizeWidget?,
      body: StreamBuilder<List<Gym>>(
          stream: bloc.adminGymList?.onGyms,
          builder: (context, snapshot) {
            return _buildBody(
              context,
              shouldShowAdminUi:
                  snapshot.data != null && snapshot.data!.isNotEmpty,
            );
          }),
    );
  }

  Widget _buildBody(BuildContext context, {required bool shouldShowAdminUi}) {
    AppBloc bloc = BlocProvider.of(context);
    return Column(
      children: [
        _Row(
          title: '使用者ID： ${bloc.userRef!.id}',
          style: TextStyles.large.action,
          action: () => _copyId(context),
        ),
        Divider(height: 1),
        _Row(
          title: '預約',
          style: TextStyles.large.action,
          hasDetail: true,
          action: () => _showMyAppointments(context),
        ),
        Divider(height: 1),
        _Row(
          title: '收藏',
          style: TextStyles.large.action,
          hasDetail: true,
          action: () => _showFavorites(context),
        ),
        Divider(height: 1),
        if (shouldShowAdminUi) ...[
          _Row(
            title: '場租管理',
            style: TextStyles.large.action,
            hasDetail: true,
            action: () => _showAdminGymList(context),
          ),
          Divider(height: 1),
        ],
        _Row(
          title: '登出',
          style: TextStyles.large.action,
          action: () => _logout(context),
        ),
        if (Platform.isIOS) ...[
          Divider(height: 1),
          _Row(
            title: '刪除帳號',
            style: TextStyles.small.action.copyWith(color: Colors.redAccent),
            action: () => _requestAccountDeletion(context),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final Function action;
  final bool hasDetail;
  _Row(
      {required this.title,
      this.style,
      required this.action,
      this.hasDetail = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action as void Function()?,
      child: Container(
        child: Row(
          children: [
            Text(title, style: style),
            Spacer(),
            if (hasDetail)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
              ),
          ],
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 60,
      ),
    );
  }
}
