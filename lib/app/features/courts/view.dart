import 'package:flutter/material.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:get/get.dart';

import 'controller.dart';

class CourtsView extends StatelessWidget {
  const CourtsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CourtsController());

    return Scaffold(
      appBar: AppBar(title: const Text('Courts'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.courts.isEmpty) {
          return Center(child: Text('No courts available'));
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: controller.courts.length,
            itemBuilder: (context, index) {
              final court = controller.courts[index];
              return _buildCourtCard(context, court, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCourtCard(
    BuildContext context,
    court,
    CourtsController controller,
  ) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.courtDetails, arguments: court.mat);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      court.mat.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    court.courtNumber,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Live', court.liveMatches, Colors.red),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Upcoming',
              court.upcomingMatches,
              AppColors.lightPrimary,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Completed',
              court.completedMatches,
              Colors.green,
            ),
            const SizedBox(height: 8),
            Divider(color: Theme.of(context).dividerColor),
            Text(
              'Total: ${court.totalMatches}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
