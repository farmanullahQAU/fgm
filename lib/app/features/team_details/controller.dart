import 'package:flutter/material.dart';
import 'package:fmac/models/team_details.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class TeamDetailsController extends GetxController {
  final Rx<TeamDetails?> teamDetails = Rx<TeamDetails?>(null);
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs; // 0 = Athletes, 1 = Officials
  final RxString searchQuery = ''.obs;
  final RxList<Athlete> filteredAthletes = <Athlete>[].obs;
  final RxList<Official> filteredOfficials = <Official>[].obs;

  String? _teamId;

  @override
  void onInit() {
    super.onInit();
    _teamId = Get.arguments as String?;
    if (_teamId != null) {
      _fetchTeamDetails();
    }
  }

  Future<void> _fetchTeamDetails() async {
    if (_teamId == null) return;

    try {
      isLoading.value = true;
      final apiService = Get.find<ApiService>();

      // Fetch athletes
      final athletesResponse = await apiService.getTeamDetails(_teamId!);
      final athletesDetails = athletesResponse.data.first;

      // Fetch officials separately
      final officialsResponse = await apiService.getTeamOfficials(_teamId!);
      final officials = officialsResponse.data;

      // Create team details with both athletes and officials
      final teamDetailsData = TeamDetails(
        athletes: athletesDetails.athletes,
        officials: officials,
      );

      teamDetails.value = teamDetailsData;

      // Initialize filtered lists
      filteredAthletes.assignAll(teamDetailsData.athletes);
      filteredOfficials.assignAll(teamDetailsData.officials);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(int index) {
    selectedTab.value = index;
    // Clear search when switching tabs
    searchQuery.value = '';
    _applySearch();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applySearch();
  }

  void _applySearch() {
    if (teamDetails.value == null) return;

    final query = searchQuery.value.toLowerCase().trim();

    if (query.isEmpty) {
      // Show all items
      filteredAthletes.assignAll(teamDetails.value!.athletes);
      filteredOfficials.assignAll(teamDetails.value!.officials);
    } else {
      // Filter athletes
      final filteredAthletesList = teamDetails.value!.athletes.where((athlete) {
        return athlete.attributes.printName.toLowerCase().contains(query) ||
            athlete.athleteId.toLowerCase().contains(query) ||
            athlete.attributes.licenseNumber.toLowerCase().contains(query) ||
            athlete.attributes.gender.toLowerCase().contains(query) ||
            athlete.organizationName.toLowerCase().contains(query) ||
            athlete.rank.toString().contains(query) ||
            athlete.seed.toString().contains(query);
      }).toList();
      filteredAthletes.assignAll(filteredAthletesList);

      // Filter officials
      final filteredOfficialsList = teamDetails.value!.officials.where((
        official,
      ) {
        return official.attributes.printName.toLowerCase().contains(query) ||
            official.id.toLowerCase().contains(query) ||
            official.attributes.licenseNumber.toLowerCase().contains(query) ||
            official.attributes.gender.toLowerCase().contains(query) ||
            official.attributes.country.toLowerCase().contains(query) ||
            official.attributes.mainRole.toLowerCase().contains(query) ||
            official.function.toLowerCase().contains(query);
      }).toList();
      filteredOfficials.assignAll(filteredOfficialsList);
    }
  }

  String getCountryFlag(Athlete athlete) {
    final flagEmoji = athlete.getFlagEmoji();
    if (flagEmoji.isNotEmpty) {
      return flagEmoji;
    }
    return '';
  }

  String getCountryName(Athlete athlete) {
    final countryName = athlete.getCountryName();
    if (countryName.isNotEmpty) {
      return countryName;
    }
    return '';
  }

  String getCountryCode(Athlete athlete) {
    return athlete.getCountryCode();
  }

  String getContinent(Athlete athlete) {
    final continent = athlete.getContinent();
    if (continent.isNotEmpty) {
      // Format continent: "ASIA" -> "Asia", "EUROPE" -> "Europe", etc.
      if (continent.length > 1) {
        return continent[0] + continent.substring(1).toLowerCase();
      }
      return continent;
    }
    return '';
  }

  String getMedalIcon(String medalType) {
    switch (medalType.toLowerCase()) {
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      case 'bronze':
        return '🥉';
      default:
        return '';
    }
  }

  void sortAthletes(String column) {
    final athletes = List<Athlete>.from(filteredAthletes);

    switch (column.toLowerCase()) {
      case 'id':
        athletes.sort((a, b) => a.athleteId.compareTo(b.athleteId));
        break;
      case 'wt':
        athletes.sort(
          (a, b) => a.attributes.country.compareTo(b.attributes.country),
        );
        break;
      case 'cat.':
        athletes.sort(
          (a, b) => a.attributes.gender.compareTo(b.attributes.gender),
        );
        break;
      case 'event':
        athletes.sort((a, b) {
          final aEvent = a.matchProgression.isNotEmpty
              ? a.matchProgression.first.event.name
              : '';
          final bEvent = b.matchProgression.isNotEmpty
              ? b.matchProgression.first.event.name
              : '';
          return aEvent.compareTo(bEvent);
        });
        break;
      case 'rank':
        athletes.sort((a, b) => a.rank.compareTo(b.rank));
        break;
    }

    filteredAthletes.assignAll(athletes);
  }

  void sortOfficials(String column) {
    final officials = List<Official>.from(filteredOfficials);

    switch (column.toLowerCase()) {
      case 'name':
        officials.sort(
          (a, b) => a.attributes.printName.compareTo(b.attributes.printName),
        );
        break;
      case 'id':
        officials.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'wt':
        officials.sort(
          (a, b) => a.attributes.country.compareTo(b.attributes.country),
        );
        break;
      case 'function':
        officials.sort((a, b) => a.function.compareTo(b.function));
        break;
    }

    filteredOfficials.assignAll(officials);
  }
}
