import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/app_bloc.dart';

class IntroPage extends StatelessWidget {
  void _nextStep(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    bloc.setIntroFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.shrinkedAppBar(),
      body: _buildBody(context),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBody(BuildContext context) {
    final style = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w300,
    );
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Spacer(flex: 1),
          Row(
            children: [
              Spacer(),
              Text('找一個不受打擾的場地', style: style),
              SizedBox(width: 50),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Spacer(),
              SizedBox(width: 50),
              Text('專心一意做好訓練', style: style),
              Spacer(),
            ],
          ),
          Spacer(flex: 1),
          _buildGoButton(context),
          SizedBox(height: 12),
          _buildPolicy(context),
          SafeArea(top: false, child: SizedBox(height: 24)),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 0.8],
            colors: [Colors.transparent, Colors.black54]),
      ),
    );
  }

  Widget _buildGoButton(BuildContext context) {
    AppBloc bloc = BlocProvider.of(context);
    return Row(
      children: [
        Spacer(),
        TextButton(
          onPressed: () => _nextStep(context),
          child: StreamBuilder<bool>(
            stream: bloc.permissionChecker.onHasUnfinishedItems,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }
              return Text(snapshot.data ? '下一步' : '開始使用');
            },
          ),
          style: TextButton.styleFrom(primary: Colors.white),
        ),
        SizedBox(width: 32),
      ],
    );
  }

  Widget _buildPolicy(BuildContext context) {
    final normal = TextStyle(
      fontSize: 12,
      color: Colors.white70,
      fontWeight: FontWeight.w300,
    );
    final link = normal.copyWith(
        color: Colors.white, decorationStyle: TextDecorationStyle.solid);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RichText(
          text: TextSpan(children: [
        TextSpan(text: '請先詳細閱讀', style: normal),
        TextSpan(text: '服務條款', style: link, recognizer: TapGestureRecognizer()),
        TextSpan(text: '及', style: normal),
        TextSpan(
            text: '隱私權政策', style: link, recognizer: TapGestureRecognizer()),
        TextSpan(text: '。開始使用即代表閣下已同意上述政策。', style: normal),
      ])),
    );
  }
}
