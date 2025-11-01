import 'package:flutter/material.dart';
import 'package:fmac/app/features/teams/controller.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/models/team.dart';
import 'package:fmac/widgets/back_button.dart';
import 'package:get/get.dart';

class TeamsView extends StatelessWidget {
  TeamsView({super.key});

  final TeamsController controller = Get.put(TeamsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Team & Athletes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButtonWidget(),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.teams.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTeams,
          color: theme.colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount:
                controller.teams.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.teams.length) {
                if (controller.hasMore.value &&
                    !controller.isLoadingMore.value) {
                  controller.loadMore();
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final team = controller.teams[index];

              return _buildTeamCard(team, index, theme);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTeamCard(Team team, int index, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.teamDetails, arguments: team.teamId);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row - Flag, ID, Country Info, Heart
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Flag Container
                  Column(
                    children: [
                      Text(
                        (index + 1).toString().padLeft(3, '0'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        width: 42,
                        height: 30,
                        child: Center(
                          child: controller.getCountryFlag(team).isNotEmpty
                              ? Text(
                                  controller.getCountryFlag(team),
                                  style: const TextStyle(fontSize: 20),
                                )
                              : Container(
                                  width: 42,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country code, Country name, Continent
                        Builder(
                          builder: (context) {
                            final countryCode = team.getCountryCode();
                            final countryName = controller.getCountryName(team);
                            final continent = controller.getContinent(team);

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

                            return Text(
                              parts.join(' | '),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),

                        // Team name - Bold
                        Text(
                          team.getTeamName(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Heart icon
                  IconButton(
                    icon: Icon(
                      Icons.favorite_outline,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Stats row
              Row(
                children: [
                  const SizedBox(width: 54),
                  Text(
                    'Athletes: ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${team.athleteCount} ',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Officials: ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${team.officialCount} ',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.teamDetails,
                        arguments: team.teamId,
                      );
                    },
                    child: Text(
                      'See Details',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
