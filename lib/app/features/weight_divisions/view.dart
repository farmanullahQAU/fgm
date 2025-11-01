import 'package:flutter/material.dart';
import 'package:fmac/app/features/weight_divisions/controller.dart';
import 'package:fmac/models/weight_division_participant.dart';
import 'package:fmac/widgets/back_button.dart';
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
        leading: const BackButtonWidget(),
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
      height: 40,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
        child: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more, color: Colors.black87, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantCard(WeightDivisionParticipant participant) {
    // Get event info
    final eventInfo = participant.event;

    final countryCode = controller.getCountryCode(participant);
    final countryName = controller.getCountryName(participant);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row - Profile, Name, Flag, Country, Rank
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image - larger
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: participant.profilePicture != null
                    ? NetworkImage(participant.profilePicture!)
                    : null,
                child: participant.profilePicture == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 32)
                    : null,
              ),
              const SizedBox(width: 12),

              // Participant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name - prominent
                    Text(
                      participant.attributes.printName.isNotEmpty
                          ? participant.attributes.printName
                          : '...',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Flag, Country, Rank row
                    Row(
                      children: [
                        if (controller.getCountryFlag(participant).isNotEmpty)
                          Text(
                            controller.getCountryFlag(participant),
                            style: const TextStyle(fontSize: 14),
                          ),
                        if (controller.getCountryFlag(participant).isNotEmpty)
                          const SizedBox(width: 6),
                        Text(
                          countryCode.isNotEmpty && countryName.isNotEmpty
                              ? '001 | $countryCode | $countryName'
                              : '001 | ... | ...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rank: ${participant.rank.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Organization name
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

                    // Details row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          participant.seed.toString().padLeft(4, '0'),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          participant.participantId.isNotEmpty
                              ? participant.participantId
                              : '...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                        if (eventInfo.division?.isNotEmpty == true)
                          Text(
                            eventInfo.division!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        if (eventInfo.name?.isNotEmpty == true)
                          Text(
                            eventInfo.name!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        Text(
                          'Seed: ${participant.seed.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Match Progression Tags
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildMatchProgressionTags(participant),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMatchProgressionTags(
    WeightDivisionParticipant participant,
  ) {
    const fullRoundOrder = [
      'R256',
      'R128',
      'R64',
      'R32',
      'R16',
      'QF',
      'SF',
      'F',
    ];

    final progressionMap = <String, dynamic>{};
    for (final p in participant.matchProgression) {
      final key = p.phase.toString().toUpperCase().trim();
      if (key.isNotEmpty) progressionMap[key] = p;
    }

    // Count how many phases have data
    final itemsWithData = fullRoundOrder
        .where((phase) => progressionMap.containsKey(phase))
        .length;
    final shouldUseFullWidth = itemsWithData <= 4;

    final boxes = fullRoundOrder.map((phase) {
      final data = progressionMap[phase];
      final matchNumber = (data != null && data.number != null)
          ? data.number.toString()
          : '--';

      // Medal logic — follows WT rules exactly
      String? medal;
      if (phase == 'F') {
        if (data?.isWinner == true)
          medal = '🥇';
        else if (data?.isWinner == false)
          medal = '🥈';
      } else if (phase == 'SF' && data?.isWinner == false) {
        medal = '🥉';
      }

      return Container(
        width: shouldUseFullWidth ? null : 80,
        height: 20,
        margin: const EdgeInsets.only(right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        constraints: shouldUseFullWidth
            ? const BoxConstraints(minWidth: 0, maxWidth: double.infinity)
            : const BoxConstraints(minWidth: 80, maxWidth: 80),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$phase: $matchNumber',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: data == null ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
            if (medal != null)
              Text(medal, style: const TextStyle(fontSize: 10)),
          ],
        ),
      );
    }).toList();

    // Group into rows of 4 boxes each, but make full width if 4 or fewer items have data
    final rows = <Widget>[];
    if (shouldUseFullWidth) {
      // If 4 or fewer items have data, make all boxes take full width
      rows.add(
        Row(
          children: boxes.map((box) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: box,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // More than 4 items have data, show 4 per row with fixed width
      for (int i = 0; i < boxes.length; i += 4) {
        rows.add(Row(children: boxes.skip(i).take(4).toList()));
        if (i + 4 < boxes.length) rows.add(const SizedBox(height: 5));
      }
    }

    return rows;
  }
}
