import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

SvgPicture svgAsset(String path, {Color? color}) {
  return SvgPicture.asset(
    path,
    colorFilter:
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
  );
}