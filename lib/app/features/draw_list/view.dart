import 'package:flutter/material.dart';
import 'package:fmac/models/draw_list.dart';
import 'package:fmac/widgets/back_button.dart';
import 'package:fmac/widgets/event_list_item.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller.dart';

class DrawListView extends StatelessWidget {
  const DrawListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DrawListController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Draw List'),
        leading: const BackButtonWidget(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refresh(),
        child: Obx(() {
          if (controller.isLoading.value && controller.events.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.events.isEmpty) {
            return Center(child: Text('No draw lists available'));
          }

          final groupedEvents = controller.groupedEvents;
          final sortedDates = groupedEvents.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final events = groupedEvents[date]!;

              return Obx(() {
                final isExpanded = controller.isExpanded(date);
                return _buildDateSection(
                  context,
                  date,
                  events,
                  controller,
                  isExpanded: isExpanded,
                );
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    DateTime date,
    List<DrawList> events,
    DrawListController controller, {
    required bool isExpanded,
  }) {
    final dayOfMonth = date.day;
    final monthYear = DateFormat('MMMM yyyy').format(date);
    final dayName = DateFormat('EEEE').format(date);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header - Clickable to expand/collapse
          InkWell(
            onTap: () => controller.toggleExpanded(date),
            child: Row(
              children: [
                // Large day number
                Text(
                  dayOfMonth.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 12),

                // Month, year, and day
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthYear,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                Spacer(),

                // Event count
                Text(
                  isExpanded
                      ? 'See all ${events.length} Events'
                      : '${events.length} Events',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),

          // Event List - Only show when expanded
          if (isExpanded) ...[
            SizedBox(height: 16),
            ...events.map((event) {
              return EventListItem(
                time: event.time,
                title: event.title,
                pdfUrl: event.pdfUrl,
                onDownloadTap: () => controller.downloadPdf(event.pdfUrl),
              );
            }),
          ],
        ],
      ),
    );
  }
}
