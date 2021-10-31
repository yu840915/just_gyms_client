import 'package:flutter/material.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/shared_appearances.dart';

class ErrorView extends StatelessWidget {
  final dynamic error;
  final RecoveryAction? action;

  ErrorView(this.error, {this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded),
          SizedBox(height: 12),
          Text(
            error.toString(),
            style: TextStyles.large.title,
          ),
          if (action != null) ...[
            SizedBox(height: 12),
            _buildAction(),
          ],
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      width: double.infinity,
    );
  }

  Widget _buildAction() {
    return TextButton(
      child: Text(
        action!.title,
      ),
      style: TextButton.styleFrom(
        textStyle: TextStyles.large.action,
        primary: AppColors.theme,
      ),
      onPressed: action!.action as void Function()?,
    );
  }
}

class ErrorPage extends StatelessWidget {
  final dynamic error;
  final RecoveryAction? action;

  ErrorPage(this.error, {this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.shrinkedAppBar() as PreferredSizeWidget?,
      body: Column(
        children: [
          Spacer(flex: 1),
          ErrorView(error, action: action),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class RecoveryAction {
  final String title;
  final Function action;
  RecoveryAction({required this.title, required this.action});
}
