import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:iQuotes/constants/constants.dart';
import '../components/AppBarTitle.dart';
import 'FavouriteSection.dart';
import 'ProfileSection.dart';
import 'RandomSection.dart';
import 'TodaySection.dart';

class MainBody extends StatefulWidget {
  const MainBody({super.key});

  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  String __quote = "Loading...";
  String __authName = "Loading...";
  int __currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await setData();
  }

  Future<void> setData() async {
    try {
      final uri = Uri.parse(QuoteOfTheDayURL);
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quote = data[0]['q'];
        final author = data[0]['a'];

        if (!mounted) return;

        setState(() {
          __quote = quote;
          __authName = author;
        });
      } else {
        throw Exception("Failed to load quote");
      }
    } catch (e) {
      print("Error fetching quote: $e");
      if (!mounted) return;
      setState(() {
        __quote = "Error loading quote";
        __authName = "Please try again later";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: AppBarTitle(),
        backgroundColor: Colors.white,
      ),
      body: IndexedStack( // Replace existing body with IndexedStack
        index: __currentPageIndex,
        children: [
          TodaySection(quote: __quote, authName: __authName),
          const RandomQuoteSection(),
          const FavourtieSection(),
          const ProfileSection(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: GNav(
          tabs: const [
            GButton(icon: Icons.today, gap: 10, text: "Today"),
            GButton(icon: Icons.swap_horiz_outlined, gap: 10, text: "Random"),
            GButton(icon: Icons.favorite, gap: 10, text: "Favourites"),
            GButton(icon: Icons.account_circle, gap: 10, text: "Profile"),
          ],
          onTabChange: (index) {
            setState(() {
              __currentPageIndex = index;
            });
          },
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          padding: const EdgeInsets.all(15),
          backgroundColor: Colors.white,
          selectedIndex: __currentPageIndex,
          color: Colors.grey,
          activeColor: Colors.black,
          rippleColor: Colors.grey,
          tabBackgroundColor: Colors.grey,
        ),
      ),
    );
  }
}
