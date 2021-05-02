import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/intro/permission_checker.dart';

class PermissionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBarFactory.shrinkedAppBar(),
      body: _buildBody(context, bloc.permissionChecker.items),
    );
  }

  Widget _buildBody(
      BuildContext context, List<PermissionItem> permissionItems) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 40),
        itemBuilder: (context, idx) => _buildRow(context, permissionItems[idx]),
        separatorBuilder: (context, idx) => SizedBox(height: 12),
        itemCount: permissionItems.length);
  }

  Widget _buildRow(BuildContext context, PermissionItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          item.icon,
          Expanded(child: Text(item.message, style: TextStyle(),)),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
