import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/intro/permission_checker.dart';
import 'package:where_gym/shared_appearances.dart';

class PermissionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBarFactory.appBar(
          title: Text(
        '使用者授權',
        style: TextStyles.large.header.copyWith(color: Colors.black),
      )),
      body: _buildBody(context, bloc.permissionChecker.items),
    );
  }

  Widget _buildBody(
      BuildContext context, List<PermissionItem> permissionItems) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 40),
        itemBuilder: (context, idx) =>
            PermissionCheckerRow(permissionItems[idx]),
        separatorBuilder: (context, idx) => SizedBox(height: 12),
        itemCount: permissionItems.length);
  }
}

class PermissionCheckerRow extends StatelessWidget {
  final PermissionItem item;
  PermissionCheckerRow(this.item);

  void _permit(BuildContext context) async {
    await item.startPermissionRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          item.icon,
          SizedBox(height: 8),
          Text(
            item.message,
            style: TextStyles.large.title,
          ),
          SizedBox(height: 8),
          _buildPermitButton(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _buildPermitButton(BuildContext context) {
    return TextButton(
      onPressed: () => _permit(context),
      child: Text('設定'),
      style: TextButton.styleFrom(
        primary: AppColors.theme,
        textStyle: TextStyles.large.action,
      ),
    );
  }
}
