import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iQuotes/constants/constants.dart';
import '../components/LoadingScreen.dart';
import 'dart:async';

class TodaySection extends StatefulWidget {
  final String quote;
  final String authName;

  const TodaySection({
    super.key,
    required this.quote,
    required this.authName,
  });

  @override
  State<TodaySection> createState() => _TodaySectionState();
}

class _TodaySectionState extends State<TodaySection> {
  bool _isLiked = false;
  bool _likeStatusLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final String _key;

  late StreamSubscription<String> _quoteRemovedSubscription;

  @override
  void initState() {
    super.initState();
    _key = "${widget.quote} - ${widget.authName}";
    _checkInitialLikeStatus();
    
    // Listen for quote removals
    _quoteRemovedSubscription = quoteRemovedController.stream.listen((removedKey) {
      if (removedKey == _key && mounted) {
        setState(() {
          _isLiked = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteRemovedSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialLikeStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      setState(() {
        _isLiked = data?['favourited']?[_key] != null;
      });
    } catch (e) {
      print("Error checking like status: $e");
    }
  }

  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _likeStatusLoading = true);

    final docRef = _firestore.collection('users').doc(user.uid);

    try {
      if (_isLiked) {
        // Delete the specific quote
        await docRef.set({
          'favourited': {
            _key: FieldValue.delete()
          }
        }, SetOptions(merge: true));
        
        print("Attempting to delete quote: $_key");
      } else {
        // Add to favorites
        await docRef.set({
          'favourited': {
            _key: {
              'quote': widget.quote,
              'author': widget.authName,
              'timestamp': FieldValue.serverTimestamp(),
            }
          }
        }, SetOptions(merge: true));
      }

      setState(() {
        _isLiked = !_isLiked;
        _likeStatusLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? "Added to favorites" : "Removed from favorites"),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print("Error toggling like: $e");
      setState(() => _likeStatusLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update favorites"),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_likeStatusLoading) {
      return const LoadingScreen(message: 'Loading today\'s quote...');
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 2,
            color: Colors.white70,
            child: Container(
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minHeight: 200),
              width: width - 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "'' ${widget.quote}",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "- ${widget.authName}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_auth.currentUser != null)
                        _likeStatusLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : IconButton(
                          onPressed: _toggleLike,
                          icon: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
