import 'package:flutter/material.dart';

class PhotoGalleryView extends StatefulWidget {
  final List<String> urls;
  PhotoGalleryView(this.urls);

  @override
  _PhotoGalleryViewState createState() => _PhotoGalleryViewState();
}

class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  PageController pageController;
  List<String> get urls => widget.urls;

  void _handlePageChanged(int idx) {}

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
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
    return PageView.builder(
      controller: pageController,
      itemBuilder: (context, idx) => _PhotoGalleryLeaf(urls[idx % urls.length]),
      onPageChanged: (idx) => {_handlePageChanged(idx % urls.length)},
    );
  }
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
