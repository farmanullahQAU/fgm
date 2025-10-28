import 'package:flutter/material.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/match.dart';
import 'controller.dart';

class CourtDetailsView extends StatelessWidget {
  const CourtDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CourtDetailsController());

    return Scaffold(
      appBar: AppBar(title: Text('Court Details'), centerTitle: true),
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (controller.courtDetails.value == null) {
          return const Center(child: Text('No data available'));
        }

        return _buildContent(context, controller);
      }),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CourtDetailsController controller,
  ) {
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildLiveMatchCard(
              context,
              controller.upcomingMatches.last,
              controller,
            ),
            // Live Match Section (if exists)
            if (controller.liveMatches.isNotEmpty) ...[
              ...controller.liveMatches.map(
                (match) => _buildLiveMatchCard(context, match, controller),
              ),
              const SizedBox(height: 16),
            ],

            // Upcoming Matches Section
            if (controller.upcomingMatches.isNotEmpty) ...[
              _buildUpcomingMatchesHeader(context),
              const SizedBox(height: 8),
              ...controller.upcomingMatches.map(
                (match) => _buildUpcomingMatchCard(context, match),
              ),
            ],

            // Bottom padding for FABs
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(
    BuildContext context,
    Match match,
    CourtDetailsController controller,
  ) {
    // Calculate live time
    final liveTime = _calculateLiveTime(match);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Match #, Live badge, Round
          Row(
            children: [
              Text(
                'Match# ${match.matchNumber}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Live $liveTime',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  match.currentRound == 0
                      ? 'Round 1'
                      : 'Round ${match.currentRound}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Court number
          Text(
            'Court# 0${match.mat}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),

          // Event category
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${match.event.gender == 'MALE' ? 'Men' : 'Women'} ${match.event.weightCategory} / ${match.phase}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 16),

          // Match scores table
          _buildMatchTable(context, match),
        ],
      ),
    );
  }

  Widget _buildMatchTable(BuildContext context, Match match) {
    final r1 = match.roundScores.isNotEmpty ? match.roundScores[0] : null;
    final r2 = match.roundScores.length > 1 ? match.roundScores[1] : null;
    final r3 = match.roundScores.length > 2 ? match.roundScores[2] : null;
    final currentRound = match.currentRound;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(4.5), // Athletes column - wider
          1: FlexColumnWidth(2.0), // Warnings
          2: FlexColumnWidth(1.0), // R1
          3: FlexColumnWidth(1.0), // R2
          4: FlexColumnWidth(1.0), // R3
          5: FlexColumnWidth(1.5), // Score - slightly wider
        },
        children: [
          // Table Header
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),

            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: _buildHeaderCell('Athletes', flex: 2),
              ),
              Container(
                alignment: Alignment.center,
                child: _buildHeaderCell('Warnings'),
              ),
              Container(
                alignment: Alignment.center,
                child: _buildHeaderCell('R1'),
              ),
              Container(
                alignment: Alignment.center,
                child: _buildHeaderCell('R2'),
              ),
              Container(
                alignment: Alignment.center,
                child: _buildHeaderCell('R3'),
              ),
              Container(
                alignment: Alignment.center,
                child: _buildHeaderCell('Score'),
              ),
            ],
          ),

          // Home Athlete Row
          _buildTableRow(
            match,
            match.homeCompetitor,
            match.warnings.home,
            r1,
            r2,
            r3,
            match.score.home,
            Colors.blue,
            true,
            currentRound,
          ),

          // Away Athlete Row
          _buildTableRow(
            match,
            match.awayCompetitor,
            match.warnings.away,
            r1,
            r2,
            r3,
            match.score.away,
            Colors.red,
            false,
            currentRound,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Container(
        child: Container(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    Match match,
    Competitor competitor,
    int warnings,
    RoundScore? r1,
    RoundScore? r2,
    RoundScore? r3,
    int? totalScore,
    Color sideColor,
    bool isHome,
    int currentRound,
  ) {
    return TableRow(
      decoration: BoxDecoration(color: sideColor.withOpacity(0.1)),
      children: [
        // Athlete info with side bar
        _buildAthleteCell(competitor, sideColor),
        // Warnings
        Container(
          alignment: Alignment.center,
          child: _buildScoreCell(warnings.toString(), isCurrentRound: false),
        ),
        // R1
        Container(
          alignment: Alignment.center,
          child: _buildScoreCell(
            r1 != null
                ? (isHome ? r1.home.toString() : r1.away.toString())
                : '0',
            isCurrentRound: currentRound == 1,
          ),
        ),
        // R2
        Container(
          alignment: Alignment.center,
          child: _buildScoreCell(
            r2 != null
                ? (isHome ? r2.home.toString() : r2.away.toString())
                : '0',
            isCurrentRound: currentRound == 2 || currentRound == 0,
          ),
        ),
        // R3
        Container(
          alignment: Alignment.center,
          child: _buildScoreCell(
            r3 != null
                ? (isHome ? r3.home.toString() : r3.away.toString())
                : '0',
            isCurrentRound: currentRound == 3,
          ),
        ),
        // Total Score
        Container(
          alignment: Alignment.center,
          child: _buildScoreCell(
            totalScore?.toString() ?? '0',
            isCurrentRound: false,
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteCell(Competitor competitor, Color sideColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          // Side color bar
          Container(
            width: 6,
            height: 45,
            decoration: BoxDecoration(
              color: sideColor,
              // borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flag and country code
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      competitor.country,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 4),
                // Name
                Text(
                  competitor.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCell(String text, {bool isCurrentRound = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      // margin: EdgeInsets.all(isCurrentRound ? 2 : 0),
      decoration: BoxDecoration(
        border: isCurrentRound
            ? Border(
                bottom: BorderSide(color: Colors.green, width: 1),
                top: BorderSide(color: Colors.green, width: 0),
                left: BorderSide(color: Colors.green, width: 1),
                right: BorderSide(color: Colors.green, width: 1),
              )
            : null,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildUpcomingMatchesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Upcoming Matches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMatchCard(BuildContext context, Match match) {
    final date = _parseDate(match.scheduledStart);
    final time = _parseTime(match.scheduledStart);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and match info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$date . $time',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '${match.event.gender == 'MALE' ? 'Men' : 'Women'} ${match.event.weightCategory} / ${match.phase} / Match ${match.matchNumber}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Competitors
          Row(
            children: [
              // Home competitor
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.homeCompetitor.country,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              match.homeCompetitor.name,
                              style: const TextStyle(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 48,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // Away competitor
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.awayCompetitor.country,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              match.awayCompetitor.name,
                              style: const TextStyle(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateLiveTime(Match match) {
    // TODO: Calculate actual live time
    return '01:46';
  }

  String _parseDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM y').format(date);
    } catch (e) {
      return '--';
    }
  }

  String _parseTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return '--:--';
    }
  }
}
