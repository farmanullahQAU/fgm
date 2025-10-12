import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class BackButtonIos extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonIos({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IconButton.filledTonal(
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: context.theme.highlightColor,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        icon: const Icon(Icons.arrow_back_ios),
      ),
    );
  }
}
