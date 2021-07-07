import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
}
