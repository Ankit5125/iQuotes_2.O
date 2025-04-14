import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/constants.dart';

class MyImageCarousle extends StatefulWidget {
  final Function(int) onPageChanged;
  const MyImageCarousle({super.key, required this.onPageChanged});

  @override
  State<MyImageCarousle> createState() => _MyImageCarousleState();
}

class _MyImageCarousleState extends State<MyImageCarousle> {
  List<UnsplashImage> _images = [];
  bool _isLoading = true;
  bool _showRefreshButton = false;
  int _currentIndex = 0;
  int _loadedImages = 0;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _showRefreshButton = false;
      _loadedImages = 0;
    });

    try {
      List<UnsplashImage> images = [];
      for (int i = 0; i < 10; i++) {
        final response = await http.get(Uri.parse(UnsplashURL));
        if (response.statusCode == 200) {
          final imageData = UnsplashImage.fromJson(jsonDecode(response.body));
          images.add(imageData);
          setState(() {
            _loadedImages = i + 1;
          });
          print(response.body);
        }
      }
      setState(() {
        _images = images;
        _isLoading = false;
        _currentIndex = 0;
      });
    } catch (e) {
      print('Error loading images: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
      _showRefreshButton = index == 9;
    });
    widget.onPageChanged(index);
  }

  Widget _buildLoadingIndicator(double height) {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.black,
            size: 50,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Images $_loadedImages/10',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _loadedImages / 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(double height) {
    return Container(
      height: height - 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 100;

    if (_isLoading) {
      return _buildLoadingIndicator(height);
    }

    if (_images.isEmpty) {
      return _buildErrorState(height);
    }

    return Stack(
      children: [
        FlutterCarousel(
          items: _images
              .map(
                (image) => Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          image.regularUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: LoadingAnimationWidget.discreteCircle(
                                color: Colors.black,
                                size: 40,
                                secondRingColor: Colors.grey,
                                thirdRingColor: Colors.grey.withOpacity(
                                  0.5,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Photo by ${image.photographerName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _launchUrl,
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
          options: FlutterCarouselOptions(
            height: height - 400,
            autoPlay: false,
            enlargeCenterPage: true,
            showIndicator: false,
            onPageChanged: (index, reason) => _handlePageChange(index),
          ),
        ),
        if (_showRefreshButton)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _loadImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Load New Images'),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(_images[_currentIndex].downloadUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
