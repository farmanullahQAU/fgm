import 'package:flutter/material.dart';
import 'package:fmac/app/features/team_details/controller.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:fmac/models/team_details.dart';
import 'package:fmac/widgets/back_button.dart';
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
        // backgroundColor: theme.appBarTheme.backgroundColor,
        // elevation: theme.appBarTheme.elevation,
        leading: const BackButtonWidget(),
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
    final countryCode = firstAthlete != null
        ? controller.getCountryCode(firstAthlete)
        : '';
    final countryName = firstAthlete != null
        ? controller.getCountryName(firstAthlete)
        : '';
    final continent = firstAthlete != null
        ? controller.getContinent(firstAthlete)
        : '';
    final organizationName = firstAthlete?.organizationName ?? '';

    final List<String> parts = [];
    if (countryCode.isNotEmpty) {
      parts.add(countryCode);
    }
    if (countryName.isNotEmpty) {
      parts.add(countryName);
    }
    if (continent.isNotEmpty) {
      parts.add(continent);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Flag Container
          Container(
            width: 42,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Center(
              child:
                  firstAthlete != null &&
                      controller.getCountryFlag(firstAthlete).isNotEmpty
                  ? Text(
                      controller.getCountryFlag(firstAthlete),
                      style: const TextStyle(fontSize: 20),
                    )
                  : Container(
                      width: 42,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Team Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts.isNotEmpty
                      ? '001 | ${parts.join(' | ')}'
                      : '001 | ... | ...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  organizationName.isNotEmpty ? organizationName : '...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black,
                    height: 1.2,
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
          height: 40,
          color: AppColors.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSortableHeader('ID', 'id', theme, isLight: !Get.isDarkMode),
              _buildSortableHeader('WT', 'wt', theme, isLight: !Get.isDarkMode),
              _buildSortableHeader(
                'Cat.',
                'cat.',
                theme,
                isLight: !Get.isDarkMode,
              ),
              _buildSortableHeader(
                'Event',
                'event',
                theme,
                isLight: !Get.isDarkMode,
              ),
              _buildSortableHeader(
                'Rank',
                'rank',
                theme,
                isLight: !Get.isDarkMode,
              ),
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
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSortableHeader('Name', 'name', theme, isLight: true),
              _buildSortableHeader('ID', 'id', theme, isLight: true),
              _buildSortableHeader('WT', 'wt', theme, isLight: true),
              _buildSortableHeader(
                'Function',
                'function',
                theme,
                isLight: true,
              ),
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

  Widget _buildSortableHeader(
    String title,
    String column,
    ThemeData theme, {
    bool isLight = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (controller.selectedTab.value == 0) {
            controller.sortAthletes(column);
          } else {
            controller.sortOfficials(column);
          }
        },
        child: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.unfold_more,
                color: AppColors.darkTextPrimary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAthleteCard(Athlete athlete, ThemeData theme) {
    // Get event info from match progression
    final eventInfo = athlete.matchProgression.isNotEmpty
        ? athlete.matchProgression.first.event
        : null;

    final countryCode = controller.getCountryCode(athlete);
    final countryName = controller.getCountryName(athlete);

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
                backgroundImage: athlete.profilePicture != null
                    ? NetworkImage(athlete.profilePicture!)
                    : null,
                child: athlete.profilePicture == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 32)
                    : null,
              ),
              const SizedBox(width: 12),

              // Athlete Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name - prominent
                    Text(
                      athlete.attributes.printName.isNotEmpty
                          ? athlete.attributes.printName
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
                        if (controller.getCountryFlag(athlete).isNotEmpty)
                          Text(
                            controller.getCountryFlag(athlete),
                            style: const TextStyle(fontSize: 14),
                          ),
                        if (controller.getCountryFlag(athlete).isNotEmpty)
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
                            'Rank: ${athlete.rank.toString().padLeft(2, '0')}',
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
                    const SizedBox(height: 6),

                    // Details row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          athlete.seed.toString().padLeft(4, '0'),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          athlete.athleteId.isNotEmpty
                              ? athlete.athleteId
                              : '...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                        if (eventInfo?.division.isNotEmpty == true)
                          Text(
                            eventInfo!.division,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        if (eventInfo?.name.isNotEmpty == true)
                          Text(
                            eventInfo!.name,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        Text(
                          'Seed: ${athlete.seed.toString().padLeft(2, '0')}',
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
            children: _buildMatchProgressionTags(athlete),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMatchProgressionTags(Athlete athlete) {
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
    for (final p in athlete.matchProgression) {
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

      // ✅ Medal logic — follows WT rules exactly
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
        width: shouldUseFullWidth
            ? null
            : 80, // 🔹 full width if 4 or fewer items with data, otherwise fixed width
        height: 20, // 🔹 compact height for cube-like look
        margin: const EdgeInsets.only(right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        constraints: shouldUseFullWidth
            ? const BoxConstraints(minWidth: 0, maxWidth: double.infinity)
            : const BoxConstraints(minWidth: 80, maxWidth: 80),
        decoration: BoxDecoration(
          // color: bgColor,
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

    // 🔹 Group into rows of 4 boxes each, but make full width if 4 or fewer items have data
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
              child: Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.grey.shade300),
                ),
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
