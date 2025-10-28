import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class MovedMatchesView extends StatelessWidget {
  const MovedMatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MovedMatchesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moved Matches'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),

          // Matches List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.matches.isEmpty) {
                return Center(child: Text('No moved matches found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.matches.length,
                itemBuilder: (context, index) {
                  final match = controller.matches[index];
                  return _buildMatchCard(context, match);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Original Match Section with blue vertical bar
          Expanded(
            child: _buildMatchSection(
              context,
              match.originalMatchNumber,
              match.homeCompetitor.name,
              match.homeCompetitor.country,
              Colors.blue,
              isLeft: true,
            ),
          ),

          // Arrow Icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.red,
              size: 24,
            ),
          ),

          // New Match Section with red vertical bar
          Expanded(
            child: _buildMatchSection(
              context,
              match.newMatchNumber,
              match.homeCompetitor.name, // Using same competitor as placeholder shows team
              match.homeCompetitor.country,
              Colors.red,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchSection(
    BuildContext context,
    String matchNumber,
    String athleteName,
    String country,
    Color barColor, {
    required bool isLeft,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: isLeft
              ? BorderSide(color: barColor, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: barColor, width: 4)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(12) : Radius.zero,
          right: !isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Number
          Text(
            matchNumber,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLeft ? Colors.black : Colors.red,
            ),
          ),
          const SizedBox(height: 8),

          // Athlete Info with Flag
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLeft) ...[
                _buildFlagIcon(),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  athleteName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isLeft) ...[
                const SizedBox(width: 4),
                _buildFlagIcon(),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // Team/Country Name
          Text(
            athleteName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFlagIcon() {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

