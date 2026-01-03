import 'package:flutter/material.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  const CustomFutureBuilder({
    super.key,
    required this.futureData,
    required this.builder,
    required this.defaultValue,
  });

  final Future<T> futureData;
  final Widget Function(BuildContext, T) builder;
  final T defaultValue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final futureData = (snapshot.data ?? defaultValue);
        return builder(context, futureData);
      },
    );
  }
}
