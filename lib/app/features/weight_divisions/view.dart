import 'package:flutter/material.dart';
import 'package:fmac/app/features/weight_divisions/controller.dart';
import 'package:fmac/models/weight_division_participant.dart';
import 'package:get/get.dart';

class WeightDivisionsView extends StatelessWidget {
  WeightDivisionsView({super.key});

  final WeightDivisionsController controller = Get.put(
    WeightDivisionsController(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Weight Divisions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search and Filters
          _buildSearchAndFilters(),

          // Table Header
          _buildTableHeader(),

          // Participants List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.participants.isEmpty) {
                return const Center(child: Text('No participants found'));
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final scrollPosition = notification.metrics.pixels;
                    final maxScroll = notification.metrics.maxScrollExtent;

                    if (scrollPosition >= maxScroll - 200) {
                      controller.loadMore();
                    }
                  }
                  return true;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount:
                      controller.participants.length +
                      (controller.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.participants.length) {
                      return Obx(
                        () => controller.isLoadingMore.value
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      );
                    }

                    final participant = controller.participants[index];
                    return _buildParticipantCard(participant);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Dropdowns
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  icon: Icons.wc,
                  label: 'Gender',
                  onTap: () => _showGenderFilter(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  icon: Icons.scale,
                  label: 'Weight Division',
                  onTap: () => _showWeightCategoryFilter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGenderFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Gender',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('MALE'),
              onTap: () {
                controller.selectGender('MALE');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('FEMALE'),
              onTap: () {
                controller.selectGender('FEMALE');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('All'),
              onTap: () {
                controller.selectGender('');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightCategoryFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Weight Division',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // Add weight categories dynamically or statically
            ListTile(
              title: const Text('58kg'),
              onTap: () {
                controller.selectWeightCategory('58kg');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('67kg'),
              onTap: () {
                controller.selectWeightCategory('67kg');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('All'),
              onTap: () {
                controller.selectWeightCategory('');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 36,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildSortableHeader('ID', 'id'),
          _buildSortableHeader('WT', 'wt'),
          _buildSortableHeader('Cat.', 'cat.'),
          _buildSortableHeader('Event', 'event'),
          _buildSortableHeader('Rank', 'rank'),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String title, String column) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onSort(column),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.unfold_more, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard(WeightDivisionParticipant participant) {
    // Get match history
    final matchHistory = participant.matchHistory;

    // Get event info
    final eventInfo = participant.event;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // First Row: Profile, Name, Country, Rank
          Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 16),

              // Participant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              participant.attributes.printName.isNotEmpty
                                  ? participant.attributes.printName
                                  : '...',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          participant.attributes.country.isNotEmpty
                              ? controller.getCountryFlag(
                                  participant.attributes.country,
                                )
                              : '🏳️',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          participant.attributes.country.isNotEmpty
                              ? '001 | ${participant.attributes.country} | ${controller.getCountryName(participant.attributes.country)}'
                              : '001 | ... | ...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),

                        Flexible(
                          fit: FlexFit.tight,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Rank: ${participant.rank.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Organization Name
                    Text(
                      participant.organizationName?.isNotEmpty == true
                          ? participant.organizationName!
                          : '...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Details Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),

                      child: Row(
                        children: [
                          Text(
                            participant.participantId.isNotEmpty
                                ? participant.participantId
                                : '...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            participant.attributes.licenseNumber.isNotEmpty
                                ? participant.attributes.licenseNumber
                                : '...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            eventInfo.division?.isNotEmpty == true
                                ? eventInfo.division!
                                : '...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            eventInfo.name?.isNotEmpty == true
                                ? eventInfo.name!
                                : '...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Seed: ${participant.seed.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 11,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Match Progression Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _buildMatchProgressionTags(matchHistory),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMatchProgressionTags(List<MatchHistory> matchHistory) {
    List<Widget> tags = [];

    // Always show 8 boxes to match the design
    final rounds = ['R256', 'R128', 'R64', 'R32', 'R16', 'QF', 'SF', 'F'];

    for (final round in rounds) {
      // Check if this round exists in match history
      final matches = matchHistory
          .where((match) => match.phase == round)
          .toList();

      List<Widget> tagChildren = [];

      if (matches.isNotEmpty) {
        // Show real data if available
        final match = matches.first;
        tagChildren.add(
          Text(
            '${match.phase}: ${match.score}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        );

        // Add medal icons based on actual match results
        if (match.isWinner == true) {
          if (match.phase == 'SF') {
            tagChildren.add(const Text('🥉', style: TextStyle(fontSize: 9)));
          } else if (match.phase == 'F') {
            tagChildren.add(const Text('🥈', style: TextStyle(fontSize: 9)));
            tagChildren.add(const Text('🥇', style: TextStyle(fontSize: 9)));
          }
        }
      } else {
        // Show empty box with dots if no data
        tagChildren.add(
          Text(
            '...',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        );
      }

      tags.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: tagChildren),
        ),
      );
    }

    return tags;
  }
}
