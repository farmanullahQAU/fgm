import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A generic event item widget that can be used for both Random Weigh Ins and Draw Lists
class EventListItem extends StatelessWidget {
  final String time;
  final String title;
  final String? pdfUrl;
  final VoidCallback? onDownloadTap;

  const EventListItem({
    super.key,
    required this.time,
    required this.title,
    this.pdfUrl,
    this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Time on the left
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(width: 16),

          // Title in the middle
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Download Button on the right
          InkWell(
            onTap: onDownloadTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.file_download,
                  size: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(width: 4),
                Text(
                  'Download PDF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A date section widget that groups events by date
class DateSection extends StatelessWidget {
  final DateTime date;
  final List<Widget> children;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const DateSection({
    super.key,
    required this.date,
    required this.children,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final dayOfMonth = date.day;
    final monthYear = DateFormat('MMMM yyyy').format(date);
    final dayName = DateFormat('EEEE').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                // Day Number
                Text(
                  dayOfMonth.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8),

                // Month and Year
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthYear,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                Spacer(),

                // Expand/Collapse or Count
                if (onToggle != null)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black54,
                  ),
              ],
            ),
          ),
        ),

        // Events or Collapsed State
        if (isExpanded)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(children: children),
          ),
      ],
    );
  }
}
