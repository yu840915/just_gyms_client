import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:where_gym/location_search.dart/location_search.dart';
import 'package:where_gym/main_menu.dart';
import 'package:where_gym/shared_appearances.dart';

class LocationSearchView extends StatefulWidget {
  final Function showList;
  final LocationSearch locationSearch;
  LocationSearchView({@required this.showList, @required this.locationSearch});

  @override
  _LocationSearchViewState createState() => _LocationSearchViewState();
}

class _LocationSearchViewState extends State<LocationSearchView> {
  FloatingSearchBarController controller;
  LocationSearch get locationSearch => widget.locationSearch;

  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSelectItem(BuildContext context, AddressSearchResultItem item) {
    controller.close();
    locationSearch.selectAddress(item);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: controller,
      hint: '輸入地址...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      width: 600,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        locationSearch.updateQuery(query);
      },
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
            onPressed: widget.showList,
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
            child: StreamBuilder<AddressSearchResult>(
              stream: locationSearch.onResult,
              builder: (context, snapshot) {
                return _buildResultView(context, snapshot.data);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultView(BuildContext context, AddressSearchResult result) {
    if (result == null) {
      return Container();
    }
    return Column(
      children: result.items
          .map(
            (e) => _Cell(
              item: e,
              onSelect: () => _onSelectItem(context, e),
            ),
          )
          .toList(),
    );
  }
}

class _Cell extends StatelessWidget {
  final AddressSearchResultItem item;
  final Function onSelect;
  _Cell({@required this.item, @required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Row(
        children: [
          Text(
            item.address,
            style: TextStyles.large.detail,
          ),
          Spacer()
        ],
      ),
      onPressed: onSelect,
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}
