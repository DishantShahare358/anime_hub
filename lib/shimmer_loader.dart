import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shape;

  const ShimmerLoader.rectangular({
    this.width = double.infinity,
    required this.height,
    this.shape = const RoundedRectangleBorder(),
  });

  const ShimmerLoader.circular({
    required this.width,
    required this.height,
    this.shape = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[800]!,
          shape: shape,
        ),
      ),
    );
  }
}

class ShimmerListLoader extends StatelessWidget {
  final int itemCount;
  final bool isHorizontal;

  const ShimmerListLoader({
    super.key,
    this.itemCount = 5,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              const ShimmerLoader.rectangular(width: 170, height: 250),
              const SizedBox(height: 8),
              const ShimmerLoader.rectangular(width: 150, height: 20),
            ],
          ),
        ),
      ),
    )
        : ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ShimmerLoader.rectangular(height: 100),
      ),
    );
  }
}