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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.courts.length,
            itemBuilder: (context, index) {
              final court = controller.courts[index];
              return _buildCourtListTile(context, court);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCourtListTile(BuildContext context, court) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Get.toNamed(AppRoutes.courtDetails, arguments: court.mat);
        },
        leading: Container(
          width: 48,
          height: 48,
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
        title: Text(
          court.courtNumber,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${court.totalMatches}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Total',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
