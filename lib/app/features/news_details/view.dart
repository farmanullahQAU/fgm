import 'package:flutter/material.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:fmac/models/news_feed.dart';
import 'package:get/get.dart';

class NewsDetailsScreen extends StatelessWidget {
  final NewsFeed newsItem;

  const NewsDetailsScreen({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Back Button
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: _shareNews,
              ),
            ],
            pinned: true,
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildNewsImage(context),
            ),
          ),

          // News Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // News Title
                  Text(
                    newsItem.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _formatDate(newsItem.createdAt!),
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Get.theme.hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // News Meta Information
                  // _buildNewsMeta(context),

                  // News Content
                  _buildNewsContent(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsImage(BuildContext context) {
    return Stack(
      children: [
        // News Image
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: newsItem.image != null && newsItem.image!.isNotEmpty
              ? Image.network(
                  newsItem.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.article_outlined, size: 80, color: Colors.grey),
    );
  }

  Widget _buildNewsMeta(BuildContext context) {
    final createdByName = newsItem.createdBy != null
        ? '${newsItem.createdBy!['firstName'] ?? ''} ${newsItem.createdBy!['lastName'] ?? ''}'
              .trim()
        : 'Unknown Author';

    final date = newsItem.createdAt != null
        ? _formatDate(newsItem.createdAt!)
        : 'Unknown date';

    return Row(
      children: [
        // Author Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey.withOpacity(0.3),
          ),
          child: Icon(Icons.person, color: AppColors.grey, size: 20),
        ),

        const SizedBox(width: 12),

        // Author and Date Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                createdByName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),

        // Bookmark Button
        IconButton(
          icon: Icon(
            Icons.bookmark_border,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: _toggleBookmark,
        ),
      ],
    );
  }

  Widget _buildNewsContent(BuildContext context) {
    // This would be the actual content from your news item
    // For now, using placeholder text as shown in your screenshot

    return Text(
      newsItem.description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 16,
        height: 1.6,
        letterSpacing: 0.2,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildNewsTags() {
    final tags = ['Sports', 'Championship', 'FMAC', 'News'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '#$tag',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRelatedNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related News',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Related news list - you can replace with actual related news
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildRelatedNewsItem(index),
        ),
      ],
    );
  }

  Widget _buildRelatedNewsItem(int index) {
    final titles = [
      'Upcoming Championship Events',
      'New Athletes Join FMAC',
      'Season Schedule Announcement',
    ];

    final dates = ['15.04.2024', '12.04.2024', '10.04.2024'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[300],
            ),
            child: const Icon(
              Icons.article_outlined,
              color: Colors.grey,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index],
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  dates[index],
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _shareNews() {
    // Implement share functionality
    // You can use packages like share_plus for this
  }

  void _toggleBookmark() {
    // Implement bookmark functionality
  }
}
