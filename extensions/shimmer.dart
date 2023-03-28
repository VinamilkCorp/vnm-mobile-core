import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

extension ShimmerWidget on Widget {
  Widget get shimmer => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: IgnorePointer(
          child: Container(
            child: this,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
