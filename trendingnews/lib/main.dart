import 'package:flutter/material.dart';
import '/widgets/FavouritesUpdate.dart';
import 'package:provider/provider.dart';
import 'widgets/CountryNews.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavouritesStore(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "News App",
        home: AllNews(),
      ),
    ));
}
