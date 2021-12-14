import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/user/avatar_button.dart';

class MyProfilePane extends StatefulWidget {
  @override
  State<MyProfilePane> createState() => _MyProfilePaneState();
}

class _MyProfilePaneState extends State<MyProfilePane> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      color: Colors.transparent,
      height: 120,
      width: double.infinity,
      child: Column(
        children: [
          _buildAvatarButton(context),
        ],
      ),
    );
  }

  Widget _buildAvatarButton(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return AvatarButton(
      userId: bloc.userRef!.id,
      action: () {},
    );
  }
}
