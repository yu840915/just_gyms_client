import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

Future<T> showLoadingOverlayOnTask<T>(BuildContext context,
    {@required Future<T> task}) async {
  try {
    context.loaderOverlay.show();
    return await task;
  } finally {
    context.loaderOverlay.hide();
  }
}
