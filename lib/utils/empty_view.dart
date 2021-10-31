import 'package:flutter/material.dart';
import 'package:where_gym/shared_appearances.dart';

class EmptyView extends StatelessWidget {
  final String message;
  EmptyView({this.message = '還沒有內容喔'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyles.large.title.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      width: double.infinity,
    );
  }
}
