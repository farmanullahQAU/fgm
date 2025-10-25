import 'package:flutter/material.dart';
import 'package:fmac/app/features/team_details/controller.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:fmac/models/team_details.dart';
import 'package:get/get.dart';

class TeamDetailsView extends StatelessWidget {
  TeamDetailsView({super.key});

  final TeamDetailsController controller = Get.put(TeamDetailsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Team Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final teamDetails = controller.teamDetails.value;
        if (teamDetails == null) {
          return Center(
            child: Text(
              'Team details not found',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        return Column(
          children: [
            // Team Header Section
            _buildTeamHeader(teamDetails, theme),

            // Tabs and Search Section
            _buildTabsAndSearch(theme),

            // Content Section
            Expanded(
              child: controller.selectedTab.value == 0
                  ? _buildAthletesList(theme)
                  : _buildOfficialsList(theme),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTeamHeader(TeamDetails teamDetails, ThemeData theme) {
    // Get team info from first athlete if available
    final firstAthlete = teamDetails.athletes.isNotEmpty
        ? teamDetails.athletes.first
        : null;
    final countryCode = firstAthlete?.attributes.country ?? '';
    final organizationName = firstAthlete?.organizationName ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Flag Container
          Container(
            width: 36,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: Center(
              child: Text(
                countryCode.isNotEmpty
                    ? controller.getCountryFlag(countryCode)
                    : '🏳️',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Team Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countryCode.isNotEmpty
                      ? '001 | $countryCode | ${controller.getCountryName(countryCode)} | Asia'
                      : '001 | ... | ... | Asia',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  organizationName.isNotEmpty ? organizationName : '...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndSearch(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Tabs
          Expanded(
            child: Row(
              children: [
                _buildTab('Athletes', 0, theme),
                const SizedBox(width: 6),
                _buildTab('Officials', 1, theme),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Search Bar
          Expanded(
            flex: 1,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: TextField(
                onChanged: controller.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, ThemeData theme) {
    final isSelected = controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkBackground : Colors.grey.shade100,

            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAthletesList(ThemeData theme) {
    return Column(
      children: [
        // Table Header
        Container(
          height: 36,
          color: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildSortableHeader('ID', 'id', theme),
              _buildSortableHeader('WT', 'wt', theme),
              _buildSortableHeader('Cat.', 'cat.', theme),
              _buildSortableHeader('Event', 'event', theme),
              _buildSortableHeader('Rank', 'rank', theme),
            ],
          ),
        ),

        // Athletes List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.filteredAthletes.length,
            itemBuilder: (context, index) {
              final athlete = controller.filteredAthletes[index];
              return _buildAthleteCard(athlete, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfficialsList(ThemeData theme) {
    return Column(
      children: [
        // Table Header
        Container(
          height: 40,
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildSortableHeader('Name', 'name', theme),
              _buildSortableHeader('ID', 'id', theme),
              _buildSortableHeader('WT', 'wt', theme),
              _buildSortableHeader('Function', 'function', theme),
            ],
          ),
        ),

        // Officials List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.filteredOfficials.length,
            itemBuilder: (context, index) {
              final official = controller.filteredOfficials[index];
              return _buildOfficialCard(official, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortableHeader(String title, String column, ThemeData theme) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (controller.selectedTab.value == 0) {
            controller.sortAthletes(column);
          } else {
            controller.sortOfficials(column);
          }
        },
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

  Widget _buildAthleteCard(Athlete athlete, ThemeData theme) {
    // Get event info from match progression
    final eventInfo = athlete.matchProgression.isNotEmpty
        ? athlete.matchProgression.first.event
        : null;

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
          // Top Row - Profile, Name, Team, Country, Rank
          Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 8),

              // Athlete Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            athlete.attributes.printName.isNotEmpty
                                ? athlete.attributes.printName
                                : '...',
                            style: Get.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,

                              color: Colors.black,
                              height: 1.2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Text(
                          athlete.attributes.country.isNotEmpty
                              ? controller.getCountryFlag(
                                  athlete.attributes.country,
                                )
                              : '🏳️',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          athlete.attributes.country.isNotEmpty
                              ? '001 | ${athlete.attributes.country} | ${controller.getCountryName(athlete.attributes.country)}'
                              : '001 | ... | ...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rank: ${athlete.rank.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      athlete.organizationName.isNotEmpty
                          ? athlete.organizationName
                          : '...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),

                        color: Get.theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            athlete.seed.toString().padLeft(4, '0'),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            athlete.athleteId.isNotEmpty
                                ? athlete.athleteId
                                : '...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            eventInfo?.division.isNotEmpty == true
                                ? eventInfo!.division
                                : '...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            eventInfo?.name.isNotEmpty == true
                                ? eventInfo!.name
                                : '...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seed: ${athlete.seed.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.2,
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
            children: _buildMatchProgressionTags(athlete),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMatchProgressionTags(Athlete athlete) {
    List<Widget> tags = [];

    // Always show 8 boxes to match the design
    final rounds = ['R256', 'R128', 'R64', 'R32', 'R16', 'QF', 'SF', 'F'];

    for (final round in rounds) {
      // Check if this round exists in match history
      final matchHistory = athlete.matchHistory
          .where((match) => match.phase == round)
          .toList();

      List<Widget> tagChildren = [];

      if (matchHistory.isNotEmpty) {
        // Show real data if available
        final match = matchHistory.first;
        tagChildren.add(
          Text(
            '${match.phase}: ${match.score ?? 0}',
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

  Widget _buildOfficialCard(Official official, ThemeData theme) {
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
      child: Row(
        children: [
          // Profile Icon
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.person, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),

          // Official Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  official.attributes.printName.isNotEmpty
                      ? official.attributes.printName
                      : '...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${official.attributes.licenseNumber} | ${official.attributes.gender} | ${official.attributes.country}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // ID
          SizedBox(
            width: 80,
            child: Text(
              official.id.isNotEmpty ? official.id : '...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Country Flag
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                official.attributes.country.isNotEmpty
                    ? controller.getCountryFlag(official.attributes.country)
                    : '🏳️',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Function
          SizedBox(
            width: 100,
            child: Text(
              official.function.isNotEmpty ? official.function : '...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
