import "package:flutter/material.dart";

import "../../constants/app_text.dart";
import "../../constants/app_spacing.dart";

class PageHeader extends StatelessWidget {
  final String title;

  final String? subtitle;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style:
              AppText.pageTitle,
        ),

        if (subtitle != null) ...[
          AppSpacing.small,

          Text(
            subtitle!,
            style:
                AppText.secondary,
          ),
        ],
      ],
    );
  }
}