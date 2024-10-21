import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String userName; // Add a field for the user name

  const FullScreenImage({
    Key? key,
    required this.imageUrl,
    required this.userName, // Require the user name
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName), // Display the user name in the AppBar
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained, // Allow zooming out
          maxScale: PhotoViewComputedScale.covered * 2, // Allow zooming in
        ),
      ),
    );
  }
}
