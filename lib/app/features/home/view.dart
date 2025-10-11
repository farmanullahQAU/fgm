import 'package:flutter/material.dart';
import 'package:fmac/app/features/login/login_screen.dart';
import 'package:fmac/core/values/app_constants.dart';
import 'package:fmac/models/news_feed.dart';
import 'package:get/get.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/values/app_colors.dart';
import 'controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildContent(context, controller),
              Positioned(
                bottom: 80,
                right: 16,
                child: _buildNotificationButton(context),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavBar(controller, isDark),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, HomeController controller) {
    if (controller.isLoading && controller.newsItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadInitialData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadInitialData(),
      child: _buildScrollContent(context, controller),
    );
  }

  Widget _buildScrollContent(BuildContext context, HomeController controller) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          controller.handleNewsScroll(scrollNotification.metrics);
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(child: _buildHeader(context, controller)),

          // Action Buttons Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),

          // Carousel Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildCarousel(context, controller),
              ],
            ),
          ),

          // Sponsors Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSponsorsSection(context, controller),
              ],
            ),
          ),

          // Latest News Section with Infinite Scroll
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // News List with separate GetBuilder for better performance
          GetBuilder<HomeController>(
            id: 'news_list',
            builder: (controller) => SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = controller.newsItems[index];
                return Container(
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    index == 0 ? 0 : 16,
                    16,
                    index == controller.newsItems.length - 1 ? 16 : 0,
                  ),
                  child: _buildNewsItem(context, item),
                );
              }, childCount: controller.newsItems.length),
            ),
          ),

          // Load More News Indicator
          SliverToBoxAdapter(child: _buildLoadMoreNewsIndicator(controller)),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.1, color: AppColors.darkTextSecondary),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(context, 'fmac_logo.png', 70),
          _buildLogo(context, 'mareg_logo.png', 70),
          Row(
            children: [
              _buildLogo(context, 'wt_logo.png', 70),
              Icon(
                Icons.menu,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, String imageUrl, double width) {
    return Image.asset(
      'assets/images/$imageUrl',
      width: width,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image, size: 70),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(context, 'group.svg', 'All Athletes', borderColor),
          _buildActionButton(
            context,
            'weight.svg',
            'Weight Divisions',
            borderColor,
          ),
          _buildActionButton(
            context,
            'random_weight.svg',
            'Random Weigh in',
            borderColor,
          ),
          _buildActionButton(
            context,
            'draw_list.svg',
            'Draw List',
            borderColor,
          ),
          _buildActionButton(
            context,
            'move_match.svg',
            'Moved Matches',
            borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String iconPath,
    String label,
    Color borderColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('$iconsBasePath$iconPath', width: 22),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1.2),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context, HomeController controller) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: controller.carouselItems.isEmpty
                ? const Center(child: Text('No carousels available'))
                : PageView.builder(
                    itemCount: controller.carouselItems.length,
                    controller: PageController(initialPage: 0),
                    onPageChanged: controller.onCarouselChanged,
                    itemBuilder: (context, index) {
                      final carousel = controller.carouselItems[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.network(
                          carousel.image ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50),
                              ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          GetBuilder<HomeController>(
            id: 'carousel_dots',
            builder: (controller) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.carouselItems.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: controller.currentCarouselIndex.value == index
                      ? 20
                      : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: controller.currentCarouselIndex.value == index
                        ? AppColors.black
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorsSection(
    BuildContext context,
    HomeController controller,
  ) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Our Sponsors', style: Get.textTheme.labelMedium),
              GetBuilder<HomeController>(
                id: 'sponsors_load_more',
                builder: (controller) {
                  if (controller.hasMoreSponsors ||
                      controller.isLoadingMoreSponsors) {
                    return TextButton(
                      onPressed: controller.isLoadingMoreSponsors
                          ? null
                          : () => controller.loadMoreSponsors(),
                      child: controller.isLoadingMoreSponsors
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('View More'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          controller.sponsorItems.isEmpty
              ? const Center(child: Text('No sponsors available'))
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.sponsorItems
                      .map(
                        (sponsor) => Container(
                          width: 55,
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: context.theme.highlightColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Image.network(
                              sponsor.image ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.business, size: 30),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsFeed item) {
    final createdByName = item.createdBy != null
        ? '${item.createdBy!['firstName'] ?? ''} ${item.createdBy!['lastName'] ?? ''}'
              .trim()
        : 'Unknown';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: item.image != null && item.image!.isNotEmpty
              ? Image.network(
                  item.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[400],
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[400],
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                item.createdAt != null
                    ? item.createdAt!.toString().substring(0, 10)
                    : 'Unknown date',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'By: $createdByName',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreNewsIndicator(HomeController controller) {
    return GetBuilder<HomeController>(
      id: 'news_loader',
      builder: (controller) {
        if (controller.isLoadingMoreNews) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!controller.hasMoreNews && controller.newsItems.isNotEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No more news to load',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNavBar(HomeController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GetBuilder<HomeController>(
        id: 'bottom_nav',
        builder: (controller) => BottomNavigationBar(
          currentIndex: controller.selectedTab.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today),
              ),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.emoji_events_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.emoji_events),
              ),
              label: 'Results',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.play_circle_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.play_circle),
              ),
              label: 'Watch',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.sensors),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.sensors),
              ),
              label: 'Live',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () {
            Get.to(() => const LoginScreen());
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 26,
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.accentRed,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            child: const Text(
              '1',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

/*
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildContent(context, controller),
              Positioned(
                bottom: 80,
                right: 16,
                child: _buildNotificationButton(context),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavBar(controller, isDark),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, HomeController controller) {
    if (controller.isLoading && controller.newsItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadInitialData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadInitialData(),
      child: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(child: _buildHeader(context, controller)),

          // Action Buttons Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildActionButtons(context),
              ],
            ),
          ),

          // Carousel Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildCarousel(context, controller),
              ],
            ),
          ),

          // Sponsors Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSponsorsSection(context, controller),
              ],
            ),
          ),

          // Latest News Section with Infinite Scroll
          SliverPadding(
            padding: const EdgeInsets.only(top: 1),
            sliver: _buildNewsList(context, controller),
          ),

          // Load More News Indicator
          SliverToBoxAdapter(child: _buildLoadMoreNewsIndicator(controller)),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.1, color: AppColors.darkTextSecondary),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(context, 'fmac_logo.png', 70),
          _buildLogo(context, 'mareg_logo.png', 70),
          Row(
            children: [
              _buildLogo(context, 'wt_logo.png', 70),
              Icon(
                Icons.menu,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, String imageUrl, double width) {
    return Image.asset(
      'assets/images/$imageUrl',
      width: width,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image, size: 70),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(context, 'group.svg', 'All Athletes', borderColor),
          _buildActionButton(
            context,
            'weight.svg',
            'Weight Divisions',
            borderColor,
          ),
          _buildActionButton(
            context,
            'random_weight.svg',
            'Random Weigh in',
            borderColor,
          ),
          _buildActionButton(
            context,
            'draw_list.svg',
            'Draw List',
            borderColor,
          ),
          _buildActionButton(
            context,
            'move_match.svg',
            'Moved Matches',
            borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String iconPath,
    String label,
    Color borderColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('$iconsBasePath$iconPath', width: 22),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1.2),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context, HomeController controller) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: controller.carouselItems.isEmpty
                ? const Center(child: Text('No carousels available'))
                : PageView.builder(
                    itemCount: controller.carouselItems.length,
                    controller: PageController(initialPage: 0),
                    onPageChanged: controller.onCarouselChanged,
                    itemBuilder: (context, index) {
                      final carousel = controller.carouselItems[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.network(
                          carousel.image ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50),
                              ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.carouselItems.length,
              (index) => GetBuilder<HomeController>(
                id: 'carousel_dots', // Specific ID for carousel dots only
                builder: (controller) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: controller.currentCarouselIndex.value == index
                      ? 20
                      : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: controller.currentCarouselIndex.value == index
                        ? AppColors.black
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorsSection(
    BuildContext context,
    HomeController controller,
  ) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Our Sponsors', style: Get.textTheme.labelMedium),
              GetBuilder<HomeController>(
                id: 'sponsors_load_more', // Specific ID for sponsors load more
                builder: (controller) {
                  if (controller.hasMoreSponsors ||
                      controller.isLoadingMoreSponsors) {
                    return TextButton(
                      onPressed: controller.isLoadingMoreSponsors
                          ? null
                          : () => controller.loadMoreSponsors(),
                      child: controller.isLoadingMoreSponsors
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('View More'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          controller.sponsorItems.isEmpty
              ? const Center(child: Text('No sponsors available'))
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.sponsorItems
                      .map(
                        (sponsor) => Container(
                          width: 55,
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: context.theme.highlightColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Image.network(
                              sponsor.image ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.business, size: 30),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, HomeController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          final newsIndex = index - 1;
          if (newsIndex < controller.newsItems.length) {
            final item = controller.newsItems[newsIndex];
            return Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.fromLTRB(
                16,
                newsIndex == 0 ? 0 : 16,
                16,
                newsIndex == controller.newsItems.length - 1 ? 16 : 0,
              ),
              child: _buildNewsItem(context, item),
            );
          }

          return null;
        },
        childCount: controller.newsItems.length + 1, // +1 for the header
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsFeed item) {
    final createdByName = item.createdBy != null
        ? '${item.createdBy!['firstName'] ?? ''} ${item.createdBy!['lastName'] ?? ''}'
              .trim()
        : 'Unknown';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: item.image != null && item.image!.isNotEmpty
              ? Image.network(
                  item.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[400],
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[400],
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                item.createdAt != null
                    ? item.createdAt!.toString().substring(0, 10)
                    : 'Unknown date',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'By: $createdByName',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreNewsIndicator(HomeController controller) {
    return GetBuilder<HomeController>(
      id: 'news_load_more', // Specific ID for news load more
      builder: (controller) {
        if (!controller.hasMoreNews) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No more news to load',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        if (controller.isLoadingMoreNews) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNavBar(HomeController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GetBuilder<HomeController>(
        id: 'bottom_nav', // Specific ID for bottom navigation
        builder: (controller) => BottomNavigationBar(
          currentIndex: controller.selectedTab.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today),
              ),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.emoji_events_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.emoji_events),
              ),
              label: 'Results',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.play_circle_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.play_circle),
              ),
              label: 'Watch',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.sensors),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.sensors),
              ),
              label: 'Live',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () {
            Get.to(() => const LoginScreen());
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 26,
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.accentRed,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            child: const Text(
              '1',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
*/
