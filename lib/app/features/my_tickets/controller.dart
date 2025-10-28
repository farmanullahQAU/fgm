import 'package:fmac/models/purchased_ticket.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class MyTicketsController extends GetxController {
  final ApiService _apiService = Get.find();

  final RxList<PurchasedTicket> tickets = <PurchasedTicket>[].obs;
  final RxBool isLoading = false.obs;

  // Track expanded state for each date
  final RxMap<DateTime, bool> expandedDates = <DateTime, bool>{}.obs;

  int currentPage = 1;
  int totalPages = 1;
  bool hasMore = true;

  // Group tickets by date
  Map<DateTime, List<PurchasedTicket>> get groupedTickets {
    final Map<DateTime, List<PurchasedTicket>> grouped = {};
    for (final ticket in tickets) {
      for (final dateStr in ticket.selectedDates) {
        try {
          final date = DateTime.parse(dateStr);
          final dayOnly = DateTime(date.year, date.month, date.day);
          if (!grouped.containsKey(dayOnly)) {
            grouped[dayOnly] = [];
          }
          grouped[dayOnly]!.add(ticket);
        } catch (e) {
          // Skip invalid dates
        }
      }
    }
    return grouped;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMyTickets();
  }

  Future<void> fetchMyTickets() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getMyTickets();
      tickets.value = response.data;
      currentPage = response.pagination.currentPage;
      totalPages = response.pagination.totalPages;
      hasMore = currentPage < totalPages;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tickets: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void refresh() {
    currentPage = 1;
    fetchMyTickets();
  }

  void downloadTicket(PurchasedTicket ticket) {
    // TODO: Implement ticket download
    Get.snackbar('Info', 'Downloading ticket for ${ticket.event.name}');
  }

  void toggleExpanded(DateTime date) {
    expandedDates[date] = !(expandedDates[date] ?? true);
  }

  bool isExpanded(DateTime date) {
    return expandedDates[date] ?? true;
  }
}

