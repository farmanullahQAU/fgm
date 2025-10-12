import 'package:flutter/material.dart';
import 'package:fmac/app/features/results/controller.dart';
import 'package:fmac/models/result.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ResultsPage extends StatelessWidget {
  ResultsPage({super.key});

  final ResultsController controller = Get.put(ResultsController());

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Results',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: () async {
            await controller.refreshResults();
          },
          child: _buildResultList(theme),
        );
      }),
    );
  }

  Widget _buildResultList(ThemeData theme) {
    if (controller.isLoading.value && controller.results.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (controller.results.isEmpty && !controller.isLoading.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results available',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => controller.refreshResults(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Group results by date
    final resultsByDate = <DateTime, List<Result>>{};
    for (var result in controller.results) {
      final date = DateTime(
        result.date.year,
        result.date.month,
        result.date.day,
      );
      if (!resultsByDate.containsKey(date)) {
        resultsByDate[date] = [];
      }
      resultsByDate[date]!.add(result);
    }

    final dates = resultsByDate.keys.toList()..sort((a, b) => a.compareTo(b));

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final metrics = scrollNotification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 100 &&
              !controller.isLoading.value &&
              controller.hasMore.value) {
            controller.loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount:
            dates.length +
            (controller.isLoading.value && controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator for pagination
          if (index >= dates.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          }

          final date = dates[index];
          final results = resultsByDate[date]!;

          return Obx(() {
            final isExpanded = controller.expandedDateIndices.contains(index);

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border(bottom: BorderSide(width: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.toggleDateExpansion(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Day number
                            Text(
                              '${date.day}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Month, year and day name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_getMonthName(date.month)} ${date.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                  Text(
                                    DateTime.now().year == date.year &&
                                            DateTime.now().month ==
                                                date.month &&
                                            DateTime.now().day == date.day
                                        ? 'Today'
                                        : DateFormat('EEEE').format(date),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.6),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (!isExpanded)
                              Text(
                                "See all ${results.length} Events",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            // Arrow icon
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: theme.iconTheme.color,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Expandable content
                  if (isExpanded) ...[
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'No Events',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(results.length, (i) {
                        final result = results[i];

                        return Container(
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.15),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Time
                                    SizedBox(
                                      width: 50,
                                      child: Text(
                                        result.time,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color:
                                              theme.textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Description
                                    Expanded(
                                      child: Text(
                                        result.description ?? result.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Download PDF
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          controller.downloadPdf(result.pdfUrl);
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.download,
                                                color: theme.iconTheme.color,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Download PDF',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ],
              ),
            );
          });
        },
      ),
    );
  }
}
