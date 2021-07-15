import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:where_gym/api_services/api_services.dart';

class AlertFactory {
  static Widget actionAlert(BuildContext context,
      {String title, String message, @required List<Widget> actions}) {
    return PlatformAlertDialog(
      title: title != null ? Text(title) : null,
      content: message != null ? Text(message) : null,
      actions: [
        PlatformDialogAction(
          child: Text('取消'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        if (actions != null) ...actions
      ],
    );
  }

  static Widget errorAlert(BuildContext context,
      {@required dynamic error, String title, Widget recoverAction}) {
    return actionAlert(
      context,
      title: title ?? '無法完成',
      message: stringFromError(error),
      actions: [if (recoverAction != null) recoverAction],
    );
  }

  static String stringFromError(dynamic error) {
    if (error is ServiceError) {
      return error.info.toString();
    }
    return error.toString();
  }
}
