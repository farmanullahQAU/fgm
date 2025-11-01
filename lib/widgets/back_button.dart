import 'package:flutter/material.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:get/get.dart';

/// Reusable back button widget matching the exact design from UI
/// Simple left-pointing arrow icon positioned on the far left
class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.color,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonColor =
        color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          iconSize: size,
        ),
        icon: Icon(Icons.arrow_back_ios, size: size, color: buttonColor),
        onPressed: onPressed ?? () => Get.back(),
      ),
    );
  }
}

/// Legacy class name for backward compatibility
@Deprecated('Use BackButtonWidget instead')
class BackButtonIos extends BackButtonWidget {
  const BackButtonIos({
    super.key,
    super.onPressed,
    super.color,
    super.size = 24,
  });
}
