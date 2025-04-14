import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iQuotes/constants/constants.dart';
import '../components/LoadingScreen.dart';
import 'dart:async';

class FavourtieSection extends StatefulWidget {
  const FavourtieSection({super.key});

  @override
  State<FavourtieSection> createState() => _FavourtieSectionState();
}

class _FavourtieSectionState extends State<FavourtieSection> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> favourites = [];
  bool _isLoading = true;
  late StreamSubscription<DocumentSnapshot> _favouritesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeFavourites();
  }

  void _initializeFavourites() {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        favourites = [];
        _isLoading = false;
      });
      return;
    }
    
    // Listen to real-time updates
    _favouritesSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _updateFavouritesFromSnapshot(snapshot);
      } else {
        setState(() {
          favourites = [];
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error in favorites stream: $error');
      setState(() => _isLoading = false);
    });
  }

  Future<void> _removeFromFavourites(String key) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore.collection('users').doc(user.uid);
      
      // Use set with merge option instead of update
      await docRef.set({
        'favourited': {
          key: FieldValue.delete()
        }
      }, SetOptions(merge: true));

      // Notify other sections about the removal
      quoteRemovedController.add(key);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote removed from favorites'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error removing favourite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _updateFavouritesFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    if (data != null && data['favourited'] != null) {
      final favouritedData = Map<String, dynamic>.from(data['favourited']);
      List<Map<String, dynamic>> tempFavourites = [];
      
      favouritedData.forEach((key, value) {
        tempFavourites.add({
          'key': key,
          'quote': value['quote'],
          'author': value['author'],
          'timestamp': value['timestamp'],
        });
      });

      // Sort by timestamp, newest first
      tempFavourites.sort((a, b) {
        final aTimestamp = (a['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTimestamp = (b['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTimestamp.compareTo(aTimestamp);
      });

      setState(() {
        favourites = tempFavourites;
        _isLoading = false;
      });
    } else {
      setState(() {
        favourites = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        favourites = [];
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch the latest data manually when user pulls to refresh
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _updateFavouritesFromSnapshot(doc);
      } else {
        setState(() {
          favourites = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error refreshing favourites: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    if (_auth.currentUser != null) {
      _favouritesSubscription.cancel();
    }
    super.dispose();
  }

  // Add refresh controller
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(message: 'Loading your favorites...');
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(15),
      child: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _handleRefresh,
        color: Colors.black,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        displacement: 40,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Favorites',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${favourites.length} quotes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (favourites.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = favourites[index];
                    return Card(
                      elevation: 2,
                      color: Colors.grey[100],
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${item['quote']}"',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '- ${item['author']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    final fullQuote = "${item['quote']}\n- ${item['author']}";
                                    await Clipboard.setData(ClipboardData(text: fullQuote));
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Quote copied to clipboard!'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.copy, color: Colors.black54),
                                ),
                                IconButton(
                                  onPressed: () => _removeFromFavourites(item['key']),
                                  icon: const Icon(Icons.delete_outline, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: favourites.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
