// import 'package:flutter/material.dart';
// import 'package:fmac/app/features/teams/controller.dart';
// import 'package:fmac/app/routes/app_routes.dart';
// import 'package:fmac/models/team.dart';
// import 'package:get/get.dart';

// class TeamsView extends StatelessWidget {
//   TeamsView({super.key});

//   final TeamsController controller = Get.put(TeamsController());

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'Team & Athletes',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: theme.appBarTheme.backgroundColor,
//         elevation: theme.appBarTheme.elevation,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value && controller.teams.isEmpty) {
//           return Center(
//             child: CircularProgressIndicator(color: theme.colorScheme.primary),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: controller.refreshTeams,
//           color: theme.colorScheme.primary,
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             itemCount:
//                 controller.teams.length + (controller.hasMore.value ? 1 : 0),
//             itemBuilder: (context, index) {
//               if (index == controller.teams.length) {
//                 // Load more indicator
//                 if (controller.hasMore.value &&
//                     !controller.isLoadingMore.value) {
//                   controller.loadMore();
//                   return Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               }

//               final team = controller.teams[index];
//               final isSelected = controller.selectedTeamIndex.value == index;

//               return _buildTeamCard(team, index, isSelected, theme);
//             },
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildTeamCard(
//     Team team,
//     int index,
//     bool isSelected,
//     ThemeData theme,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: isSelected
//             ? Border.all(color: theme.colorScheme.primary, width: 2)
//             : Border.all(color: theme.dividerColor.withOpacity(0.3), width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: theme.shadowColor.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           // Navigate to team details
//           Get.toNamed(AppRoutes.teamDetails, arguments: team.teamId);
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Left rail: ID badge + Flag
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF5F6F7),
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(color: Colors.grey.shade300, width: 1),
//                     ),
//                     child: Text(
//                       (index + 1).toString().padLeft(3, '0'),
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                         height: 1.0,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     width: 48,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(3),
//                       border: Border.all(color: Colors.grey.shade300, width: 1),
//                       color: Colors.white,
//                     ),
//                     child: Center(
//                       child: Text(
//                         controller.getCountryFlag(team.attributes.country),
//                         style: const TextStyle(fontSize: 20),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 12),

//               // Main content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Country code and name
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: team.attributes.country,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black,
//                               height: 1.1,
//                             ),
//                           ),
//                           const TextSpan(
//                             text: ' | ',
//                             style: TextStyle(fontSize: 12, color: Colors.black),
//                           ),
//                           TextSpan(
//                             text: controller.getCountryName(
//                               team.attributes.country,
//                             ),
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                               height: 1.1,
//                             ),
//                           ),
//                           const TextSpan(
//                             text: ' | Asia',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF8E8E93),
//                               height: 1.1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 4),

//                     // Team name
//                     Text(
//                       team.attributes.name,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: theme.textTheme.bodyMedium?.color,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),

//                     // Athletes and Officials count with See Details
//                     Row(
//                       children: [
//                         Text(
//                           'Athletes: ${team.athleteCount}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: theme.textTheme.bodySmall?.color,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Text(
//                           'Officials: ${team.officialCount}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: theme.textTheme.bodySmall?.color,
//                           ),
//                         ),
//                         const Spacer(),
//                         Text(
//                           'See Details',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: theme.colorScheme.primary,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 16),

//               // Heart icon
//               Icon(
//                 Icons.favorite_border,
//                 color: theme.iconTheme.color?.withOpacity(0.6),
//                 size: 20,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fmac/app/features/teams/controller.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/models/team.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
        ),
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
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(2),
                        //   border: Border.all(
                        //     color: Colors.grey.shade300,
                        //     width: 1,
                        //   ),
                        // ),
                        child: Center(
                          child: Text(
                            controller.getCountryFlag(team.attributes.country),
                            style: const TextStyle(fontSize: 20),
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
                        // ID, Country code, Country name, Region
                        Row(
                          children: [
                            // const SizedBox(width: 8),
                            // Text(
                            //   team.attributes.country,
                            //   style: const TextStyle(
                            //     fontSize: 13,
                            //     fontWeight: FontWeight.w700,
                            //     color: Colors.black,
                            //     height: 1.1,
                            //   ),
                            // ),
                            Text(
                              controller.getCountryName(
                                team.attributes.country,
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              team.attributes.country,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Team name - Bold
                        Text(
                          team.attributes.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Subtitle
                        Text(
                          '...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
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
