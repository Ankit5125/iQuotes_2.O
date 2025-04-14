import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../components/LoadingScreen.dart';
import '../components/MyImageCarousle.dart';
import '../constants/constants.dart';

class RandomQuoteSection extends StatefulWidget {
  const RandomQuoteSection({super.key});

  @override
  State<RandomQuoteSection> createState() => _RandomQuoteSectionState();
}

class _RandomQuoteSectionState extends State<RandomQuoteSection>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  String __quote = "Loading...";
  String __authName = "Loading...";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<RandomQuote> _quotesCache = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isLiked = false;
  bool _likeStatusLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<String> _quoteRemovedSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _preloadQuotes();

    // Listen for quote removals
    _quoteRemovedSubscription = quoteRemovedController.stream.listen((removedKey) {
      final currentKey = "$__quote - $__authName";
      if (removedKey == currentKey && mounted) {
        setState(() {
          _isLiked = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteRemovedSubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _preloadQuotes() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final uri = Uri.parse("$RandomQuoteURL");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _quotesCache = data.map((e) => RandomQuote.fromJson(e)).toList();

        if (_quotesCache.isNotEmpty) {
          setState(() {
            __quote = _quotesCache[0].quote;
            __authName = _quotesCache[0].author;
          });
          _checkIfLiked(_quotesCache[0]);
          _animationController.forward();
        }
      }
    } catch (e) {
      print('Error preloading quotes: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _checkIfLiked(RandomQuote quote) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _likeStatusLoading = true;
    });

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    bool isLiked = false;
    if (data != null && data['favourited'] != null) {
      final Map<String, dynamic> favourited = Map<String, dynamic>.from(data['favourited']);
      for (final item in favourited.values) {
        if (item is Map<String, dynamic>) {
          if (item['quote'] == quote.quote && item['author'] == quote.author) {
            isLiked = true;
            break;
          }
        }
      }
    }

    setState(() {
      _isLiked = isLiked;
      _likeStatusLoading = false;
    });
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user signed in");
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final key = "$__quote - $__authName";

    try {
      setState(() {
        _isLiked = !_isLiked;
      });

      if (_isLiked) {
        // Add the quote to the favourited map
        await docRef.set({
          'favourited': {
            key: {
              "quote": __quote,
              "author": __authName,
              "likedAt": FieldValue.serverTimestamp(),
            }
          }
        }, SetOptions(merge: true));
      } else {
        // Remove the quote by deleting the specific field
        await docRef.set({
          'favourited': {
            key: FieldValue.delete(),
          }
        }, SetOptions(merge: true));
      }

      print("Quote ${_isLiked ? 'saved' : 'removed'} successfully.");
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  // Add this variable to track if all quotes have been viewed
  bool _allQuotesViewed = false;

  @override
  bool get wantKeepAlive => true; // Keep the state alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    double height = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return const LoadingScreen(message: 'Finding an inspiring quote...');
    }

    return Container(
      height: height,
      color: Colors.white,
      child: Column(
        children: [
          // Add reload button row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_allQuotesViewed || _quotesCache.isEmpty)
                  TextButton.icon(
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _quotesCache.clear();
                        _currentIndex = 0;
                        _allQuotesViewed = false;
                      });
                      _preloadQuotes();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load New Quotes'),
                  ),
              ],
            ),
          ),
          Expanded(  // Use Expanded instead of fixed height
            flex: 1,
            child: MyImageCarousle(
              onPageChanged: (index) {
                _handlePageChange(index);
              },
            ),
          ),
          Expanded(  // Use Expanded for quote section
            flex: 1,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(  // Keep this ScrollView for long quotes
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 1,
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "'' $__quote",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "- $__authName",
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _likeStatusLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : IconButton(
                                      onPressed: _isLoading ? null : _toggleLike,
                                      icon: Icon(
                                        _isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: _isLiked ? Colors.red : null,
                                      ),
                                    ),
                              IconButton(
                                onPressed: () async {
                                  final fullQuote = "$__quote\n- $__authName";
                                  await Clipboard.setData(ClipboardData(text: fullQuote));
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Quote copied to clipboard!"),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.copy),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modify _handlePageChange to track viewed quotes
  void _handlePageChange(int index) {
    if (_quotesCache.isEmpty) {
      _preloadQuotes();
      return;
    }

    _currentIndex = index % _quotesCache.length;
    _animationController.reverse().then((_) {
      setState(() {
        __quote = _quotesCache[_currentIndex].quote;
        __authName = _quotesCache[_currentIndex].author;
        _isLiked = false;
        
        // Set allQuotesViewed if we've seen all quotes
        if (_currentIndex == _quotesCache.length - 1) {
          _allQuotesViewed = true;
        }
      });
      _checkIfLiked(_quotesCache[_currentIndex]);
      _animationController.forward();
    });

    // Only preload more quotes if we're running low and haven't viewed all
    if (_currentIndex >= _quotesCache.length - 3 && !_allQuotesViewed) {
      _preloadQuotes();
    }
  }
}
