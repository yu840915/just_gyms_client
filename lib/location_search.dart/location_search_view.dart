import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:where_gym/main_menu.dart';
import 'package:where_gym/shared_appearances.dart';

class LocationSearchView extends StatelessWidget {
  final Function showList;
  LocationSearchView({this.showList});

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: '搜尋地點...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      width: 600,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: MainMenu(),
        ),
        FloatingSearchBarAction.back(
          color: AppColors.theme,
        ),
      ],
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: TextButton(
            child: Text(
              '列表',
            ),
            style: TextButton.styleFrom(
                textStyle: TextStyles.large.action,
                primary: AppColors.theme,
                padding: EdgeInsets.zero),
            onPressed: showList,
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (BuildContext context, Animation<double> transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((color) {
                return Container(height: 112, color: color);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
