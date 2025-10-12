import 'package:flutter/material.dart';
import 'package:fmac/app/features/schedule/controller.dart';
import 'package:fmac/models/schedule.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatelessWidget {
  SchedulePage({super.key});

  final ScheduleController controller = Get.put(ScheduleController());

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
          'Schedule',
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
            await controller.refreshSchedules();
          },
          child: _buildScheduleList(theme),
        );
      }),
    );
  }

  Widget _buildScheduleList(ThemeData theme) {
    if (controller.isLoading.value && controller.schedules.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (controller.schedules.isEmpty && !controller.isLoading.value) {
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
              'No schedules available',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => controller.refreshSchedules(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Group schedules by date
    final schedulesByDate = <DateTime, List<Schedule>>{};
    for (var schedule in controller.schedules) {
      final date = DateTime(
        schedule.date.year,
        schedule.date.month,
        schedule.date.day,
      );
      if (!schedulesByDate.containsKey(date)) {
        schedulesByDate[date] = [];
      }
      schedulesByDate[date]!.add(schedule);
    }

    final dates = schedulesByDate.keys.toList()..sort((a, b) => a.compareTo(b));

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final metrics = scrollNotification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 100 &&
              !controller.isLoading.value &&
              controller.hasMore.value) {
            controller.loadMoreSchedules();
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
          final schedules = schedulesByDate[date]!;

          return Obx(() {
            final isExpanded = controller.expandedDateIndices.contains(index);

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  bottom: BorderSide(
                    width: 0.1,
                    color: theme.dividerColor.withOpacity(0.15),
                  ),
                ),
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
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.6),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (!isExpanded)
                              Text(
                                "See all ${schedules.length} Events",
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
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.dividerColor.withOpacity(0.15),
                      indent: 0,
                      endIndent: 0,
                    ),
                    if (schedules.isEmpty)
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
                      ...List.generate(schedules.length, (i) {
                        final schedule = schedules[i];

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      schedule.time,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Description
                                  Expanded(
                                    child: Text(
                                      schedule.description ?? schedule.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            theme.textTheme.bodyMedium?.color,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Get directions
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // Handle navigation
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.green[700],
                                              size: 14,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              'Get directions',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.green[700],
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
                            if (i < schedules.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16,
                                color: theme.dividerColor.withOpacity(0.15),
                              ),
                          ],
                        );
                      }),

                    // See all button at bottom
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
