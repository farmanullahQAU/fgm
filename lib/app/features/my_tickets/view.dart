import 'package:flutter/material.dart';
import 'package:fmac/models/purchased_ticket.dart';
import 'package:fmac/widgets/event_list_item.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller.dart';

class MyTicketsView extends StatelessWidget {
  const MyTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyTicketsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refresh(),
        child: Obx(() {
          if (controller.isLoading.value && controller.tickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.tickets.isEmpty) {
            return const Center(child: Text('No tickets available'));
          }

          final groupedTickets = controller.groupedTickets;
          final sortedDates = groupedTickets.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final tickets = groupedTickets[date]!;

              return Obx(() {
                final isExpanded = controller.isExpanded(date);
                return _buildDateSection(
                  context,
                  date,
                  tickets,
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
    List<PurchasedTicket> tickets,
    MyTicketsController controller, {
    required bool isExpanded,
  }) {
    final dayOfMonth = date.day;
    final monthYear = DateFormat('MMMM yyyy').format(date);
    final dayName = DateFormat('EEEE').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                const SizedBox(width: 12),

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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Event count
                Text(
                  isExpanded
                      ? 'See all ${tickets.length} Tickets'
                      : '${tickets.length} Tickets',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
              ],
            ),
          ),

          // Ticket List - Only show when expanded
          if (isExpanded) ...[
            const SizedBox(height: 16),
            ...tickets.map((ticket) {
              // Create a unique title for each ticket including event name and day
              final dateStr = DateFormat('HH:mm').format(DateTime.parse(ticket.selectedDates.first));
              final title = '${ticket.event.name} - Day ${ticket.numberOfDays}';
              
              return EventListItem(
                time: dateStr,
                title: title,
                pdfUrl: ticket.event.image, // Using event image as placeholder for PDF URL
                onDownloadTap: () => controller.downloadTicket(ticket),
              );
            }),
          ],
        ],
      ),
    );
  }
}

