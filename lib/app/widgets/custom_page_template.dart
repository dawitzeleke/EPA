import 'package:flutter/material.dart';

class CustomPage extends StatelessWidget {
  final PreferredSizeWidget appBar;
final Widget bodyContent;

  const CustomPage({super.key, required this.appBar, required this.bodyContent});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: bodyContent,
      ),
    );
  }
}