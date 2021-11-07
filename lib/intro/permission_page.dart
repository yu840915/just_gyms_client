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
      )) as PreferredSizeWidget?,
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
    try {
      await item.startPermissionRequest(context);
    } catch (e, s) {
      print('$e, $s');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: item.onUpdate,
      builder: (context, snapshot) {
        return _buildContent(context, snapshot.data as GrantStatus?);
      },
    );
  }

  Widget _buildContent(BuildContext context, GrantStatus? status) {
    if (status == GrantStatus.denied) {
      return SizedBox.shrink();
    }
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
          _buildAction(context, status),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _buildAction(BuildContext context, GrantStatus? status) {
    if (status == null) {
      return Container(
        height: 44,
        child: Text(
          '檢查中...',
          style: TextStyles.large.action.copyWith(color: AppColors.progressing),
        ),
      );
    }
    switch (status) {
      case GrantStatus.undecided:
        return _buildPermitButton(context);
      case GrantStatus.denied:
        return SizedBox.shrink();
      case GrantStatus.granted:
        return Container(
          height: 44,
          child: Text(
            '已完成',
            style: TextStyles.large.action.copyWith(color: Colors.black),
          ),
        );
    }
  }

  Widget _buildPermitButton(BuildContext context) {
    return TextButton(
      onPressed: () => _permit(context),
      child: Text('設定'),
      style: TextButton.styleFrom(
        primary: AppColors.theme,
        textStyle: TextStyles.large.action,
        fixedSize: Size.fromHeight(44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
