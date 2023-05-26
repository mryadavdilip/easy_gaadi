import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  const Background({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16213E),
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fill,
              color: Colors.yellow,
              colorBlendMode: BlendMode.srcOut,
            ),
            child,
          ],
        ),
      ),
    );
  }
}
