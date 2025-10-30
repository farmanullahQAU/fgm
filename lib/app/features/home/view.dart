import 'package:flutter/material.dart';
import 'package:fmac/app/features/courts/view.dart';
import 'package:fmac/app/features/events/view.dart';
import 'package:fmac/app/features/news_details/view.dart';
import 'package:fmac/app/features/results/view.dart';
import 'package:fmac/app/features/schedule/view.dart';
import 'package:fmac/app/features/youtube_videos/watch_screen.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/core/values/app_constants.dart';
import 'package:fmac/models/news_feed.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/values/app_colors.dart';
import 'controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'bottom_nav',
      init: HomeController(),
      builder: (controller) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: controller.selectedTab.value == 0
              ? _buildAppBar(context, controller)
              : null,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottomSheet: GetBuilder<HomeController>(
            id: 'event_banner',
            builder: (c) => c.hasLiveEvents
                ? _buildEventBanner(context, c)
                : const SizedBox.shrink(),
          ),
          body: IndexedStack(
            index: controller.selectedTab.value,
            children: [
              Obx(() => _buildContent(context, controller)),
              SchedulePage(),
              ResultsPage(),
              WatchScreen(),
              CourtsView(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavBar(controller, isDark),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    HomeController controller,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150),
      child: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Top logos section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => EventsPage());
                      },
                      child: _buildLogo(context, 'fmac_logo.png', 65),
                    ),
                    _buildLogo(context, 'mareg_logo.png', 65),
                    Row(
                      children: [
                        _buildLogo(context, 'wt_logo.png', 65),
                        SizedBox(width: 8),
                        Icon(
                          Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(height: 1, thickness: 0.1),
              // Action buttons section
              _buildActionButtonsBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            'group.svg',
            'Team &\nAthletes',
            onTap: () => Get.toNamed(AppRoutes.teams),
          ),
          _buildActionButton(
            context,
            'weight.svg',
            'Weight\nDivisions',
            onTap: () => Get.toNamed(AppRoutes.weightDivisions),
          ),
          _buildActionButton(
            context,
            'random_weight.svg',
            'Random\nWeigh In',
            onTap: () => Get.toNamed(AppRoutes.randomWeighIn),
          ),
          _buildActionButton(
            context,
            'draw_list.svg',
            'Draw\nList',
            onTap: () => Get.toNamed(AppRoutes.drawList),
          ),
          _buildActionButton(
            context,
            'move_match.svg',
            'Moved\nMatches',
            onTap: () {
              Get.toNamed(AppRoutes.movedMatches);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String iconPath,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('$iconsBasePath$iconPath', width: 22),
          const SizedBox(height: 6),
          SizedBox(
            width: 58,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Get.theme.textTheme.labelMedium?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
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
          const Icon(Icons.image, size: 65),
    );
  }

  Widget _buildContent(BuildContext context, HomeController controller) {
    if (controller.isLoading && controller.newsItems.isEmpty) {
      return _buildShimmerLoading(context);
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

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Carousel shimmer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            height: 160,
            color: Colors.white,
          ),
          // Sponsors shimmer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 20, color: Colors.white),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      5,
                      (_) => Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // News shimmer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 20, color: Colors.white),
                const SizedBox(height: 16),
                Column(
                  children: List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(width: 56, height: 56, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 100,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        physics: const AlwaysScrollableScrollPhysics(),
        primary: true,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildCarousel(context, controller),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [_buildSponsorsSection(context, controller)],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
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
          SliverToBoxAdapter(child: _buildLoadMoreNewsIndicator(controller)),
          SliverToBoxAdapter(
            child: SizedBox(height: controller.hasLiveEvents ? 140 : 80),
          ),
          // Add extra bottom space when banner is visible so content isn't hidden
          // This keeps layout stable without affecting other sections
          // Replaces the fixed space above when banner is present
        ],
      ),
    );
  }

  Widget _buildEventBanner(BuildContext context, HomeController controller) {
    final events = controller.liveEvents;
    if (events.isEmpty) return const SizedBox.shrink();

    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.accentRed,

            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const SizedBox(width: 10),
              Expanded(
                child: PageView.builder(
                  controller: controller.bannerPageController,
                  onPageChanged: controller.onBannerChanged,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Container(
                            child: Text(
                              e.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          Text(
                            e.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Get.to(() => EventsPage());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/images/buy_ticket.svg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Sponsors',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GetBuilder<HomeController>(
            id: 'sponsors_list',
            builder: (controller) {
              if (controller.sponsorItems.isEmpty &&
                  !controller.isLoadingMoreSponsors) {
                return const Center(
                  child: Text(
                    'No sponsors available',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return SizedBox(
                height: 60,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      controller.handleSponsorsScroll(
                        scrollNotification.metrics,
                      );
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        controller.sponsorItems.length +
                        (controller.hasMoreSponsors ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.sponsorItems.length) {
                        if (controller.hasMoreSponsors &&
                            !controller.isLoadingMoreSponsors) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.loadMoreSponsors();
                          });
                        }

                        return controller.isLoadingMoreSponsors
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 33),
                                  color: Colors.white,
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final sponsor = controller.sponsorItems[index];
                      return Container(
                        width: 80,
                        margin: EdgeInsets.only(
                          right: index == controller.sponsorItems.length - 1
                              ? 0
                              : 12,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
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
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.business, size: 24),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsFeed item) {
    return InkWell(
      onTap: () => Get.to(() => NewsDetailsScreen(newsItem: item)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 50,
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
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  (item.createdAt != null &&
                          item.createdAt.toString().length >= 10)
                      ? item.createdAt.toString().substring(0, 10)
                      : 'Unknown date',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreNewsIndicator(HomeController controller) {
    return GetBuilder<HomeController>(
      id: 'news_loader',
      builder: (controller) {
        if (controller.isLoadingMoreNews) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 80, height: 20, color: Colors.white),
                ],
              ),
            ),
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
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
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
}
