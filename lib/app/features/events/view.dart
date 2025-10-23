import 'package:flutter/material.dart';
import 'package:fmac/app/tickets/view.dart';
import 'package:fmac/models/event.dart';
import 'package:fmac/services/api_services.dart';
import 'package:fmac/widgets/back_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventsController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  var events = <Event>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;
  var hasMoreData = true.obs;

  var currentPage = 1;
  var totalPages = 1.obs;

  final scrollController = ScrollController();
  final int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchEvents({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
      currentPage = 1;
      hasMoreData.value = true;
    } else if (currentPage == 1) {
      isLoading.value = true;
    }

    try {
      final response = await apiService.getEvents(page: currentPage);

      if (refresh || currentPage == 1) {
        events.assignAll(response.data);
      } else {
        events.addAll(response.data);
      }

      totalPages.value = response.pagination.totalPages;
      hasMoreData.value = currentPage < totalPages.value;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    currentPage++;
    await fetchEvents();
  }

  @override
  Future<void> refresh() async {
    await fetchEvents(refresh: true);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMoreData.value) {
        loadMore();
      }
    }
  }
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EventsController controller = Get.put(EventsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: true,
        leading: BackButtonIos(),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.events.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: Get.theme.primaryColor),
          );
        }

        if (controller.events.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Get.theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(height: 16),
                Text(
                  'No events available',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: Get.theme.primaryColor,
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount:
                controller.events.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.events.length) {
                return _buildLoadingMore();
              }

              final event = controller.events[index];
              return _buildEventCard(event);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(event.id),
          // ClipRRect(
          //   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          //   child: Image.network(
          //     event.image,
          //     height: 86,
          //     width: double.infinity,
          //     fit: BoxFit.cover,
          //     loadingBuilder: (context, child, loadingProgress) {
          //       if (loadingProgress == null) return child;
          //       return Container(
          //         height: 86,
          //         color: Get.theme.dividerColor,
          //         child: Center(
          //           child: CircularProgressIndicator(
          //             value: loadingProgress.expectedTotalBytes != null
          //                 ? loadingProgress.cumulativeBytesLoaded /
          //                       loadingProgress.expectedTotalBytes!
          //                 : null,
          //             color: Get.theme.primaryColor,
          //           ),
          //         ),
          //       );
          //     },
          //     errorBuilder: (context, error, stackTrace) {
          //       return Container(
          //         height: 86,
          //         color: Get.theme.dividerColor,
          //         child: Icon(
          //           Icons.broken_image,
          //           size: 48,
          //           color: Get.theme.textTheme.bodySmall?.color,
          //         ),
          //       );
          //     },
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: Get.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Get.theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('yyyy-MM-dd').format(DateTime.parse(event.startDate))} - ${DateFormat('yyyy-MM-dd').format(DateTime.parse(event.endDate))}',
                            style: Get.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Get.theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              style: Get.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => MainTicketScreen(), arguments: event.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Buy Tickets',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Get.theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading more events...',
              style: Get.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
