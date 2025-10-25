// // ==================== MODELS ====================
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:fmac/models/event.dart';
import 'package:fmac/models/ticket.dart';
import 'package:fmac/services/api_services.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:fmac/services/stripe_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class DayModel {
  final String id;
  final String label;
  final String date;
  final String weekday;

  DayModel({
    required this.id,
    required this.label,
    required this.date,
    required this.weekday,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      id: json['id'],
      label: json['label'],
      date: json['date'],
      weekday: json['weekday'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'date': date,
    'weekday': weekday,
  };
}

class TicketController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final Rx<Event?> currentEvent = Rx<Event?>(null);
  final RxBool isLoading = false.obs;
  final RxInt currentStep = 0.obs;
  final Logger _logger = Logger();

  // Actual backend tickets (created on dialog confirm)
  final RxList<Ticket> actualTickets = <Ticket>[].obs;

  // Dynamically set based on event
  final RxList<DayModel> availableDays = <DayModel>[].obs;
  final Rxn<DayModel> selectedDay = Rxn<DayModel>();

  @override
  void onInit() {
    super.onInit();
    final eventId = Get.arguments; // Dynamic ID from route
    _loadEventData(eventId);
  }

  Future<void> _loadEventData(String eventId) async {
    isLoading.value = true;
    try {
      final response = await apiService.getEvents(page: 1);
      currentEvent.value = response.data.firstWhere(
        (event) => event.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );
      _initializeDays();
      _setDynamicData();
      // Fetch initial tickets for the user and event
      await _refreshTickets();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeDays() {
    if (currentEvent.value != null) {
      availableDays.value = currentEvent.value!.eventDates.map((dateStr) {
        return DayModel(
          id: dateStr,
          label: 'Day ${currentEvent.value!.eventDates.indexOf(dateStr) + 1}',
          date: DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr)),
          weekday: DateFormat('EEEE').format(DateTime.parse(dateStr)),
        );
      }).toList();
      selectedDay.value = availableDays.isNotEmpty ? availableDays[0] : null;
    }
  }

  void _setDynamicData() {
    if (currentEvent.value != null) {
      adultTicketPrice.value = currentEvent.value!.pricing.adult.toDouble();
      childTicketPrice.value = currentEvent.value!.pricing.child.toDouble();
      adultServiceFee.value = 3.95; // Could be dynamic if API provides
      childServiceFee.value = 2.95; // Could be dynamic if API provides
      eventName.value = currentEvent.value!.name;
      eventVenue.value = currentEvent.value!.location;
    }
  }

  final eventName = ''.obs;
  final eventDate = ''.obs;
  final eventVenue = ''.obs;
  final adultTicketPrice = 0.0.obs;
  final childTicketPrice = 0.0.obs;
  final adultServiceFee = 3.95.obs;
  final childServiceFee = 2.95.obs;
  final isSubmitting = false.obs;

  void selectDay(DayModel day) {
    selectedDay.value = day;
  }

  // Fetch and refresh tickets for the current user and event
  Future<void> _refreshTickets() async {
    try {
      final user = Get.find<AuthService>().currentUser; // Get current user
      final response = await apiService.getUserTicketsByEvent(
        userId: user.value?.id ?? "",
        eventId: currentEvent.value!.id,
      );

      actualTickets.value = response; // Update tickets list
    } catch (e) {
      //logger
      _logger.e('Error refreshing tickets: $e');

      Get.snackbar('Error', 'Failed to refresh tickets: $e');
    }
  }

  // Create actual ticket and refresh tickets list
  Future<void> addTicket(
    String type,
    int count,
    List<bool> selectedDays,
  ) async {
    final price = type == 'Adult'
        ? adultTicketPrice.value
        : childTicketPrice.value;
    final selectedDates = currentEvent.value!.eventDates
        .asMap()
        .entries
        .where((entry) => selectedDays[entry.key])
        .map((entry) => entry.value)
        .toList();
    final ticket = Ticket(
      createdBy: Get.find<AuthService>().currentUser.value!,
      eventName: eventName.value,
      date: eventDate.value,
      venue: eventVenue.value,
      firstName: null, // Nullable as per JSON response
      lastName: null,
      email: null,
      contactNumber: null,
      ticketPrice: price,
      numberOfTickets: count,
      ticketType: type,
      selectedDates: selectedDates,
      totalAmount: count * price * selectedDates.length,
      bookingReference: '${DateTime.now().millisecondsSinceEpoch}',

      // createdBy: currentEvent.value!.createdBy,
    );
    try {
      await apiService.createTicket(ticket, currentEvent.value!.id);
      await _refreshTickets(); // Refresh tickets after adding
      Get.snackbar('Success', 'Ticket added successfully');
    } catch (e) {
      print("Error creating ticket: $e");
      Get.snackbar('Error', 'Failed to create ticket: $e');
    }
  }

  // Edit existing ticket and refresh tickets list
  Future<void> editTicket(
    int index,
    String type,
    int count,
    List<bool> selectedDays,
  ) async {
    if (index >= 0 && index < actualTickets.length) {
      final price = type == 'Adult'
          ? adultTicketPrice.value
          : childTicketPrice.value;
      final selectedDates = currentEvent.value!.eventDates
          .asMap()
          .entries
          .where((entry) => selectedDays[entry.key])
          .map((entry) => entry.value)
          .toList();
      final updatedTicket = actualTickets[index].copyWith(
        numberOfTickets: count,
        selectedDates: selectedDates,
        ticketPrice: price,

        // totalAmount: count * price * selectedDates.length,
        updatedAt: DateTime.now(),
      );
      try {
        await apiService.updateTicket(updatedTicket);
        await _refreshTickets(); // Refresh tickets after updating
        Get.snackbar('Success', 'Ticket updated successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to update ticket: $e');
      }
    }
  }

  // Edit individual field (local update, synced via bulk update)
  void editTicketField(int index, String field, String value) {
    if (index >= 0 && index < actualTickets.length) {
      final ticket = actualTickets[index];
      final updatedTicket = ticket.copyWith(
        firstName: field == 'firstName' ? value : ticket.firstName,
        lastName: field == 'lastName' ? value : ticket.lastName,
        email: field == 'email' ? value : ticket.email,
        contactNumber: field == 'contactNumber' ? value : ticket.contactNumber,
        updatedAt: DateTime.now(),
      );
      actualTickets[index] = updatedTicket; // Update locally
    }
  }

  void removeTicket(int index, Ticket ticket) async {
    if (index >= 0 && index < actualTickets.length) {
      try {
        final response = await apiService.deleteTicket(ticket.id!);
        actualTickets.removeAt(index);
        Get.snackbar(
          response,
          "Success",
          colorText: AppColors.white,
          backgroundColor: Colors.green,
        );
        //beaturiful snack bar
      } catch (e) {
        Get.snackbar(
          'Error',
          '$e',
          colorText: AppColors.white,
          backgroundColor: AppColors.branding,
        );
      }
    }
  }

  bool canProceedToDetails() {
    return actualTickets.isNotEmpty;
  }

  getTicketsByBookingReference() {
    final bookingReference = actualTickets.first.bookingReference;
    return actualTickets
        .where((ticket) => ticket.bookingReference == bookingReference)
        .toList();
  }

  void proceedToDetails() {
    if (!canProceedToDetails()) {
      Get.snackbar('Error', 'Please select at least one ticket');
      return;
    }
    currentStep.value = 1;
  }

  double get totalAmount {
    return actualTickets.fold(0, (sum, t) => sum + t.totalAmount);
  }

  int get totalTicketsCount {
    return actualTickets.fold(0, (sum, t) => sum + t.numberOfTickets);
  }

  void proceedToPayment() async {
    if (!actualTickets.every(
      (ticket) =>
          ticket.firstName?.isNotEmpty == true &&
          ticket.lastName?.isNotEmpty == true &&
          ticket.email?.isNotEmpty == true &&
          ticket.contactNumber?.isNotEmpty == true,
    )) {
      Get.snackbar('Error', 'Please fill all ticket details');
      return;
    }

    await saveTicketToBackend();

    currentStep.value = 2;
  }

  Future<void> saveTicketToBackend() async {
    isSubmitting.value = true;
    try {
      await bulkUpdateTicketsWithDetails(); // Sync local changes to backend
      currentStep.value = 3;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save ticket: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Bulk update all tickets with user details from TicketDetailsScreen
  Future<void> bulkUpdateTicketsWithDetails() async {
    if (actualTickets.isEmpty) return;
    final updates = actualTickets
        .map(
          (ticket) => {
            'ticketId': ticket.id,
            'firstName': ticket.firstName,
            'lastName': ticket.lastName,
            'email': ticket.email,
            'contactNumber': ticket.contactNumber,
          },
        )
        .toList();
    try {
      await apiService.bulkUpdateTickets(updates);

      await _refreshTickets(); // Refresh tickets after bulk update
    } catch (e) {
      Get.snackbar('Error', 'Failed to update tickets: $e');
    }
  }

  void downloadTickets() {
    Get.snackbar('Success', 'Tickets downloaded successfully');
  }

  void reset() {
    currentStep.value = 0;
    actualTickets.clear();
    selectedDay.value = availableDays.isNotEmpty ? availableDays[0] : null;
    final eventId = Get.arguments;
    _loadEventData(eventId);
  }

  // ==================== TICKET CONTROLLER - confirmPayment (FIX) ====================
  Future<void> confirmPayment(String clientSecret) async {
    try {
      isSubmitting.value = true;

      // Confirm payment with Stripe
      final paymentIntent = await Get.find<StripeService>()
          .confirmPaymentWithCardForm(clientSecret);

      // Check if payment succeeded
      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        // Update tickets status to paid
        // await _updateTicketsStatus('paid');

        // Sync ticket details to backend
        // await saveTicketToBackend();

        // Navigate to success screen
        currentStep.value = 3;
        Get.snackbar('Success', 'Payment completed successfully!');
      } else {
        throw Exception('Payment failed: ${paymentIntent.status}');
      }
    } catch (e) {
      _logger.e('Payment confirmation error: $e');
      Get.snackbar('Error', 'Payment failed: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _updateTicketsStatus(String status) async {
    try {
      actualTickets.value = actualTickets.map((t) {
        return t.copyWith(
          status: status,
          // paymentStatus: status,
          updatedAt: DateTime.now(),
        );
      }).toList();
      await apiService.bulkUpdateTickets(
        actualTickets.map((t) => t.toJson()).toList(),
      );
      _logger.i('Updated tickets status to $status');
    } catch (e) {
      _logger.e('Error updating ticket status: $e');
      rethrow;
    }
  }
}

class MainTicketScreen extends StatelessWidget {
  final TicketController controller = Get.put(TicketController());

  MainTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          switch (controller.currentStep.value) {
            case 0:
              return AddTicketScreen();
            case 1:
              return TicketDetailsScreen();
            case 2:
              return PaymentScreen();
            case 3:
              return SuccessScreen();
            default:
              return AddTicketScreen();
          }
        }),
      );
    });
  }
}

class AddTicketScreen extends StatelessWidget {
  final TicketController controller = Get.find();
  final RxBool isDescriptionExpanded = false.obs;

  AddTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D2D),

        title: Text(
          'Tickets',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(1),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [_buildAddTicketsSection(), SizedBox(height: 16)],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildDescriptionSheet(),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int current) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStep(1, 'Add tickets', current >= 1, current > 1),
          _buildStep(2, 'Add details', current >= 2, current > 2),
          _buildStep(3, 'Payment', current >= 3, current > 3),
          _buildStep(4, 'Confirmation', current >= 4, current > 4),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 14)
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddTicketsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add tickets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAdultTicketDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE31E24),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add adult ticket',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showChildrenTicketDialog(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Color(0xFFE31E24), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add children ticket',
                    style: TextStyle(color: Color(0xFFE31E24), fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSelectedTicketsList(),
        ],
      ),
    );
  }

  Widget _buildSelectedTicketsList() {
    return Obx(() {
      if (controller.actualTickets.isEmpty) {
        return Align(
          alignment: Alignment.center,
          child: Center(
            child: Text(
              'No tickets added yet.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Item#',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Detail',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Action',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ...controller.actualTickets.asMap().entries.map(
            (e) => _buildTicketItem(e.key, e.value),
          ),
        ],
      );
    });
  }

  Widget _buildTicketItem(int index, Ticket ticket) {
    final formattedDates = ticket.selectedDates
        .map((date) => DateFormat('yyyy-MM-dd').format(DateTime.parse(date)))
        .join(', ');

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ticket.numberOfTickets} ${ticket.ticketType} ticket${ticket.numberOfTickets > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  '\$${ticket.ticketPrice.toStringAsFixed(2)} ${ticket.selectedDates.length} day${ticket.selectedDates.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  formattedDates,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                  onPressed: () => ticket.ticketType == 'Adult'
                      ? _showEditAdultTicketDialog(index, ticket)
                      : _showEditChildrenTicketDialog(index, ticket),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFE31E24),
                  ),
                  onPressed: () => controller.removeTicket(index, ticket),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSheet() {
    return Obx(
      () => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: isDescriptionExpanded.value
            ? MediaQuery.of(Get.context!).size.height * 0.7
            : 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: isDescriptionExpanded.value
            ? _buildExpandedDescription()
            : _buildCollapsedDescription(),
      ),
    );
  }

  Widget _buildCollapsedDescription() {
    return GestureDetector(
      onTap: () => isDescriptionExpanded.value = true,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                controller.eventName.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_up, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDescription() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.eventName.value} ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down, size: 20),
                onPressed: () => isDescriptionExpanded.value = false,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.eventName.value,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Lorem ipsum dolor sit amet...',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Obx(
                  () => Text(
                    '\$${controller.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.totalTicketsCount} Tickets',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: controller.canProceedToDetails()
                  ? () => controller.proceedToDetails()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE31E24),
                disabledBackgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Next',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdultTicketDialog() =>
      Get.dialog(AdultTicketSelectionDialog(), barrierDismissible: true);
  void _showChildrenTicketDialog() =>
      Get.dialog(ChildrenTicketSelectionDialog(), barrierDismissible: true);
  void _showEditAdultTicketDialog(int index, Ticket ticket) => Get.dialog(
    AdultTicketSelectionDialog(editIndex: index, existingTicket: ticket),
    barrierDismissible: true,
  );
  void _showEditChildrenTicketDialog(int index, Ticket ticket) => Get.dialog(
    ChildrenTicketSelectionDialog(editIndex: index, existingTicket: ticket),
    barrierDismissible: true,
  );
}

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  _TicketDetailsScreenState createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final TicketController controller = Get.find();
  final Logger _logger = Logger();
  late List<Map<String, TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each ticket and field
    _controllers = controller.actualTickets.map((ticket) {
      return {
        'firstName': TextEditingController(text: ticket.firstName ?? ''),
        'lastName': TextEditingController(text: ticket.lastName ?? ''),
        'email': TextEditingController(text: ticket.email ?? ''),
        'contactNumber': TextEditingController(
          text: ticket.contactNumber ?? '',
        ),
      };
    }).toList();
    _logger.d(
      'Initialized controllers for ${controller.actualTickets.length} tickets',
    );
  }

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks
    for (var controllerMap in _controllers) {
      controllerMap.forEach((key, controller) => controller.dispose());
    }
    _logger.d('Disposed controllers');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D2D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => controller.currentStep.value = 0,
        ),
        title: Text('Tickets', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildStepIndicator(2),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => Column(
                      children: controller.actualTickets
                          .asMap()
                          .entries
                          .map((e) => _buildTicketForm(e.key, e.value))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int current) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStep(1, 'Add tickets', current >= 1, current > 1),
          _buildStep(2, 'Add details', current >= 2, current > 2),
          _buildStep(3, 'Payment', current >= 3, current > 3),
          _buildStep(4, 'Confirmation', current >= 4, current > 4),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 14)
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketForm(int index, Ticket ticket) {
    _logger.d('Building form for ticket $index: ${ticket.toJson()}');
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1} ${ticket.ticketType} ticket',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            ticket.selectedDates.join(', '),
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 16),
          _buildTextField(
            'First name',
            _controllers[index]['firstName']!,
            (value) => controller.editTicketField(index, 'firstName', value),
          ),
          SizedBox(height: 12),
          _buildTextField(
            'Last name',
            _controllers[index]['lastName']!,
            (value) => controller.editTicketField(index, 'lastName', value),
          ),
          SizedBox(height: 12),
          _buildTextField(
            'Email',
            _controllers[index]['email']!,
            (value) => controller.editTicketField(index, 'email', value),
          ),
          SizedBox(height: 12),
          _buildTextField(
            'Contact number',
            _controllers[index]['contactNumber']!,
            (value) =>
                controller.editTicketField(index, 'contactNumber', value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.black87)),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (value) {
            _logger.d('Updated $label: $value');
            onChanged(value);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFE31E24)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Obx(
                () => Text(
                  '\$${controller.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Obx(
                () => Text(
                  '${controller.totalTicketsCount} tickets',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => controller.proceedToPayment(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE31E24),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Confirm details',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TicketController controller = Get.find();
  final Logger _logger = Logger();
  final CardFormEditController _cardController = CardFormEditController();

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmPayment() async {
    if (controller.actualTickets.isEmpty) {
      Get.snackbar('Error', 'No tickets to pay for');
      return;
    }

    // Validate card form is complete
    if (!_cardController.hasCardFormField) {
      Get.snackbar('Error', 'Please enter complete card details');
      return;
    }

    try {
      controller.isSubmitting.value = true;

      // Create PaymentIntent on backend
      final clientSecret = await Get.find<ApiService>().createPaymentIntent(
        ticketId: controller.actualTickets.first.id,
      );
      _logger.i('Received clientSecret: $clientSecret');

      // Confirm payment - CardFormField handles the card data automatically
      await controller.confirmPayment(clientSecret);
    } catch (e) {
      _logger.e('Payment error: $e');
      Get.snackbar('Error', 'Payment failed: $e');
    } finally {
      controller.isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D2D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => controller.currentStep.value = 1,
        ),
        title: Text('Tickets', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildStepIndicator(3),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  _buildPaymentForm(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int current) {
    return Container(
      // color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStep(1, 'Add tickets', current >= 1, current > 1),
          _buildStep(2, 'Add details', current >= 2, current > 2),
          _buildStep(3, 'Payment', current >= 3, current > 3),
          _buildStep(4, 'Confirmation', current >= 4, current > 4),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 14)
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        CardFormField(
          controller: _cardController,
          enablePostalCode: false,

          style: CardFormStyle(
            // backgroundColor: AppColors.black,
            borderColor: Colors.grey[300]!,

            // textColor: Colors.black,
            // placeholderColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Obx(
                () => Text(
                  '\$${controller.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Obx(
                () => Text(
                  '${controller.totalTicketsCount} tickets',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isSubmitting.value ||
                      !_cardController.hasCardFormField
                  ? null
                  : _handleConfirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE31E24),
                disabledBackgroundColor: Colors.grey[400],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: controller.isSubmitting.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Confirm Payment',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdultTicketSelectionDialog extends StatelessWidget {
  final TicketController controller = Get.find();
  final int? editIndex;
  final Ticket? existingTicket;
  final RxInt ticketCount = 1.obs;
  final RxList<bool> selectedDays;

  AdultTicketSelectionDialog({super.key, this.editIndex, this.existingTicket})
    : selectedDays = RxList<bool>.filled(
        Get.find<TicketController>().availableDays.length,
        false,
      ) {
    if (existingTicket != null) {
      ticketCount.value = existingTicket!.numberOfTickets;
      // Initialize selectedDays based on existingTicket's selectedDates
      for (int i = 0; i < controller.availableDays.length; i++) {
        selectedDays[i] = existingTicket!.selectedDates.contains(
          controller.availableDays[i].id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModalHeader(),
            Expanded(
              child: SingleChildScrollView(child: _buildTicketOptions(context)),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add adult ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 24),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 8),
          Obx(
            () => Text(
              controller.eventName.value,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketOptions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adult ticket',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Obx(
            () => Text(
              '\$${controller.adultTicketPrice.value.toStringAsFixed(2)} USD per ticket (Including TAX)',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFE31E24),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildTicketCountSelector(),
          SizedBox(height: 16),
          Text(
            'Please tap on the day to select',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Obx(
            () => Text(
              'Select Days \$${controller.adultTicketPrice.value.toStringAsFixed(2)} per day (Including TAX)',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFE31E24),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildDaysList(),
        ],
      ),
    );
  }

  Widget _buildTicketCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of tickets',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 20),
                onPressed: () =>
                    ticketCount.value > 1 ? ticketCount.value-- : null,
              ),
              Obx(
                () => Text(
                  '${ticketCount.value}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 20),
                onPressed: () =>
                    ticketCount.value < 10 ? ticketCount.value++ : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysList() {
    return Obx(
      () => Column(
        children: List.generate(controller.availableDays.length, (index) {
          final day = controller.availableDays[index];
          return GestureDetector(
            onTap: () => selectedDays[index] = !selectedDays[index],
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selectedDays[index] ? Color(0xFFE31E24) : Colors.white,
                border: Border.all(
                  color: selectedDays[index]
                      ? Color(0xFFE31E24)
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day.label,
                    style: TextStyle(
                      color: selectedDays[index] ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    day.date,
                    style: TextStyle(
                      color: selectedDays[index]
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    day.weekday,
                    style: TextStyle(
                      color: selectedDays[index]
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Obx(
                () => Text(
                  '\$${(ticketCount.value * controller.adultTicketPrice.value * selectedDays.where((selected) => selected).length).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE31E24),
                  ),
                ),
              ),
              Obx(
                () => Text(
                  '${ticketCount.value * selectedDays.where((selected) => selected).length} Tickets',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
              Obx(
                () => Text(
                  '${selectedDays.where((selected) => selected).length} days',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
          Obx(
            () => ElevatedButton(
              onPressed: selectedDays.any((selected) => selected)
                  ? () async {
                      Get.back();
                      if (editIndex != null) {
                        await controller.editTicket(
                          editIndex!,
                          'Adult',
                          ticketCount.value,
                          List.from(selectedDays),
                        );
                      } else {
                        await controller.addTicket(
                          'Adult',
                          ticketCount.value,
                          List.from(selectedDays),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE31E24),
                disabledBackgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                editIndex != null ? 'Update ticket' : 'Add ticket',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildrenTicketSelectionDialog extends StatelessWidget {
  final TicketController controller = Get.find();
  final int? editIndex;
  final Ticket? existingTicket;
  final RxInt ticketCount = 1.obs;
  final RxList<bool> selectedDays;

  ChildrenTicketSelectionDialog({
    super.key,
    this.editIndex,
    this.existingTicket,
  }) : selectedDays = RxList<bool>.filled(
         Get.find<TicketController>().availableDays.length,
         false,
       ) {
    if (existingTicket != null) {
      ticketCount.value = existingTicket!.numberOfTickets;
      // Initialize selectedDays based on existingTicket's selectedDates
      for (int i = 0; i < controller.availableDays.length; i++) {
        selectedDays[i] = existingTicket!.selectedDates.contains(
          controller.availableDays[i].id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModalHeader(),
            Expanded(
              child: SingleChildScrollView(child: _buildTicketOptions(context)),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add children ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 24),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 8),
          Obx(
            () => Text(
              controller.eventName.value,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketOptions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Children ticket',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Obx(
            () => Text(
              '\$${controller.childTicketPrice.value.toStringAsFixed(2)} USD per ticket (Including TAX)',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFE31E24),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildTicketCountSelector(),
          SizedBox(height: 16),
          Text(
            'Please tap on the day to select',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Obx(
            () => Text(
              'Select Days \$${controller.childTicketPrice.value.toStringAsFixed(2)} per day (Including TAX)',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFE31E24),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildDaysList(),
        ],
      ),
    );
  }

  Widget _buildTicketCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of tickets',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 20),
                onPressed: () =>
                    ticketCount.value > 1 ? ticketCount.value-- : null,
              ),
              Obx(
                () => Text(
                  '${ticketCount.value}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 20),
                onPressed: () =>
                    ticketCount.value < 10 ? ticketCount.value++ : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysList() {
    return Obx(
      () => Column(
        children: List.generate(controller.availableDays.length, (index) {
          final day = controller.availableDays[index];
          return GestureDetector(
            onTap: () => selectedDays[index] = !selectedDays[index],
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selectedDays[index] ? Color(0xFFE31E24) : Colors.white,
                border: Border.all(
                  color: selectedDays[index]
                      ? Color(0xFFE31E24)
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day.label,
                    style: TextStyle(
                      color: selectedDays[index] ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    day.date,
                    style: TextStyle(
                      color: selectedDays[index]
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    day.weekday,
                    style: TextStyle(
                      color: selectedDays[index]
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Obx(
                () => Text(
                  '\$${(ticketCount.value * controller.childTicketPrice.value * selectedDays.where((selected) => selected).length).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE31E24),
                  ),
                ),
              ),
              Obx(
                () => Text(
                  '${ticketCount.value * selectedDays.where((selected) => selected).length} Tickets',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
              Obx(
                () => Text(
                  '${selectedDays.where((selected) => selected).length} days',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
          Obx(
            () => ElevatedButton(
              onPressed: selectedDays.any((selected) => selected)
                  ? () async {
                      Get.back();

                      if (editIndex != null) {
                        await controller.editTicket(
                          editIndex!,
                          'Child',
                          ticketCount.value,
                          selectedDays,
                        );
                      } else {
                        await controller.addTicket(
                          'Child',
                          ticketCount.value,
                          selectedDays,
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE31E24),
                disabledBackgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                editIndex != null ? 'Update ticket' : 'Add ticket',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  final TicketController controller = Get.find();

  SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D2D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            controller.reset();
            Get.back();
          },
        ),
        title: Text('Tickets', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildStepIndicator(4),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 50),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Your tickets have been successfully purchased.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You can download book of your pass anytime from your on',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      '+XXX-XXXXXXXXX',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => controller.downloadTickets(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE31E24),
                        padding: EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Download Tickets',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Color(0xFF2D2D2D),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              controller.eventName.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int current) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStep(1, 'Add tickets', true, true),
          _buildStep(2, 'Add details', true, true),
          _buildStep(3, 'Payment', true, true),
          _buildStep(4, 'Confirmation', true, true),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String label, bool isActive, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Center(
              child: Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
