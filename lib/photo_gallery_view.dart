import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:where_gym/shared_appearances.dart';

class PhotoGalleryView extends StatefulWidget {
  final List<String> urls;
  PhotoGalleryView(this.urls);

  @override
  _PhotoGalleryViewState createState() => _PhotoGalleryViewState();
}

class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  PageController? pageController;
  List<String> get urls => widget.urls;
  BehaviorSubject<_PageInfo>? _pageInfoSubject;

  void _handlePageChanged(int idx) {
    _pageInfoSubject!.add(_PageInfo(idx, urls.length));
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: urls.length * 30);
    _pageInfoSubject = BehaviorSubject<_PageInfo>();
    _handlePageChanged(0);
  }

  @override
  void dispose() {
    pageController!.dispose();
    _pageInfoSubject!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (urls == null || urls.isEmpty) {
      return Container(
        height: 100,
        color: Colors.grey,
      );
    }
    if (urls.length == 1) {
      return _PhotoGalleryLeaf(urls.first);
    }
    return Container(
      height: 0.6 * MediaQuery.of(context).size.width +
          MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemBuilder: (context, idx) =>
                _PhotoGalleryLeaf(urls[idx % urls.length]),
            onPageChanged: (idx) => {_handlePageChanged(idx % urls.length)},
          ),
          StreamBuilder<_PageInfo>(
            stream: _pageInfoSubject,
            builder: (context, snapshot) {
              return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildPageIndicator(snapshot.data),
                  ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(_PageInfo? info) {
    if (info == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${info.current + 1}/${info.total}',
        style: TextStyles.small.detail!.copyWith(color: Colors.white),
      ),
    );
  }
}

class _PageInfo {
  final int current;
  final int total;
  _PageInfo(this.current, this.total);
}

class _PhotoGalleryLeaf extends StatelessWidget {
  final String url;
  _PhotoGalleryLeaf(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      height: 0.6 * MediaQuery.of(context).size.width +
          MediaQuery.of(context).padding.top,
      width: double.infinity,
    );
  }
}
