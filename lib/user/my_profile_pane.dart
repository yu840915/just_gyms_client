import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bloc.dart';
import 'package:where_gym/user/avatar_button.dart';

class MyProfilePane extends StatefulWidget {
  @override
  State<MyProfilePane> createState() => _MyProfilePaneState();
}

class _MyProfilePaneState extends State<MyProfilePane> {
  void _changeAvatar(BuildContext context) {}

  void _changeName(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      color: Colors.transparent,
      height: 120,
      width: double.infinity,
      child: Column(
        children: [
          _buildAvatarButton(context, bloc),
          StreamBuilder<Object?>(
              stream: bloc.userRef!.snapshots().map((event) => null),
              builder: (context, snapshot) {
                return _buildNameButton(bloc);
              }),
        ],
      ),
    );
  }

  Widget _buildAvatarButton(BuildContext context, AppBloc bloc) {
    return AvatarButton(
      userId: bloc.userRef!.id,
      action: () => _changeAvatar(context),
    );
  }

  Widget _buildNameButton(dynamic profile) {
    return Container();
  }
}
