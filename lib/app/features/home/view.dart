// import 'package:flutter/material.dart';
// import 'package:fmac/app/features/login/login_screen.dart';
// import 'package:fmac/core/values/app_constants.dart';
// import 'package:fmac/models/news_feed.dart';
// import 'package:get/get.dart';
// import 'package:svg_flutter/svg.dart';

// import '../../../core/values/app_colors.dart';
// import 'controller.dart';
import 'package:flutter/material.dart';
import 'package:fmac/app/features/login/login_screen.dart';
import 'package:fmac/app/features/news_details/view.dart';
import 'package:fmac/core/values/app_constants.dart';
import 'package:fmac/models/news_feed.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:svg_flutter/svg.dart';

import '../../../core/values/app_colors.dart';
import 'controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(Get.find<AuthService>().accessToken);
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
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        children: [
          // Header shimmer
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 70, height: 70, color: Colors.white),
                Container(width: 70, height: 70, color: Colors.white),
                Container(width: 70, height: 70, color: Colors.white),
              ],
            ),
          ),
          // Action buttons shimmer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (_) => Column(
                  children: [
                    Container(width: 22, height: 22, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 64, height: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
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
                  height: 50,
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
                                const SizedBox(height: 4),
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
          Text('Our Sponsors', style: Get.textTheme.labelMedium),
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
                height: 50,
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
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        controller.sponsorItems.length +
                        (controller.hasMoreSponsors ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Load more indicator as last item
                      if (index == controller.sponsorItems.length) {
                        if (controller.hasMoreSponsors &&
                            !controller.isLoadingMoreSponsors) {
                          // Trigger load more when the last item becomes visible
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.loadMoreSponsors();
                          });
                        }

                        return controller.isLoadingMoreSponsors
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
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
                          vertical: 4,
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
    final createdByName = item.createdBy != null
        ? '${item.createdBy!['firstName'] ?? ''} ${item.createdBy!['lastName'] ?? ''}'
              .trim()
        : 'Unknown';

    return InkWell(
      onTap: () => Get.to(() => NewsDetailsScreen(newsItem: item)),
      child: Row(
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
                  ).textTheme.labelMedium?.copyWith(fontSize: 13, height: 1.4),
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
                // const SizedBox(height: 4),
                // Text(
                //   'By: $createdByName',
                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //     fontSize: 11,
                //     color: AppColors.grey,
                //   ),
                // ),
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
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
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
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HomeController>(
//       init: HomeController(),
//       builder: (controller) {
//         final isDark = Theme.of(context).brightness == Brightness.dark;

//         return Scaffold(
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           body: Stack(
//             children: [
//               _buildContent(context, controller),
//               Positioned(
//                 bottom: 80,
//                 right: 16,
//                 child: _buildNotificationButton(context),
//               ),
//             ],
//           ),
//           bottomNavigationBar: _buildBottomNavBar(controller, isDark),
//         );
//       },
//     );
//   }

//   Widget _buildContent(BuildContext context, HomeController controller) {
//     if (controller.isLoading && controller.newsItems.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (controller.errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               controller.errorMessage,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodyMedium?.copyWith(color: Colors.red),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => controller.loadInitialData(),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () => controller.loadInitialData(),
//       child: _buildScrollContent(context, controller),
//     );
//   }

//   Widget _buildScrollContent(BuildContext context, HomeController controller) {
//     return NotificationListener<ScrollNotification>(
//       onNotification: (scrollNotification) {
//         if (scrollNotification is ScrollUpdateNotification) {
//           controller.handleNewsScroll(scrollNotification.metrics);
//         }
//         return false;
//       },
//       child: CustomScrollView(
//         slivers: [
//           // Header Section
//           SliverToBoxAdapter(child: _buildHeader(context, controller)),

//           // Action Buttons Section
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 _buildActionButtons(context),
//               ],
//             ),
//           ),

//           // Carousel Section
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 const SizedBox(height: 24),
//                 _buildCarousel(context, controller),
//               ],
//             ),
//           ),

//           // Sponsors Section
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 _buildSponsorsSection(context, controller),
//               ],
//             ),
//           ),

//           // Latest News Section with Infinite Scroll
//           SliverToBoxAdapter(
//             child: Container(
//               color: Theme.of(context).cardColor,
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Latest',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),

//           // News List with separate GetBuilder for better performance
//           GetBuilder<HomeController>(
//             id: 'news_list',
//             builder: (controller) => SliverList(
//               delegate: SliverChildBuilderDelegate((context, index) {
//                 final item = controller.newsItems[index];
//                 return Container(
//                   color: Theme.of(context).cardColor,
//                   padding: EdgeInsets.fromLTRB(
//                     16,
//                     index == 0 ? 0 : 16,
//                     16,
//                     index == controller.newsItems.length - 1 ? 16 : 0,
//                   ),
//                   child: _buildNewsItem(context, item),
//                 );
//               }, childCount: controller.newsItems.length),
//             ),
//           ),

//           // Load More News Indicator
//           SliverToBoxAdapter(child: _buildLoadMoreNewsIndicator(controller)),

//           // Bottom Padding
//           const SliverToBoxAdapter(child: SizedBox(height: 80)),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, HomeController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(width: 0.1, color: AppColors.darkTextSecondary),
//         ),
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildLogo(context, 'fmac_logo.png', 70),
//           _buildLogo(context, 'mareg_logo.png', 70),
//           Row(
//             children: [
//               _buildLogo(context, 'wt_logo.png', 70),
//               Icon(
//                 Icons.menu,
//                 color: Theme.of(context).iconTheme.color,
//                 size: 24,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogo(BuildContext context, String imageUrl, double width) {
//     return Image.asset(
//       'assets/images/$imageUrl',
//       width: width,
//       errorBuilder: (context, error, stackTrace) =>
//           const Icon(Icons.image, size: 70),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

//     return Container(
//       color: Theme.of(context).scaffoldBackgroundColor,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildActionButton(context, 'group.svg', 'All Athletes', borderColor),
//           _buildActionButton(
//             context,
//             'weight.svg',
//             'Weight Divisions',
//             borderColor,
//           ),
//           _buildActionButton(
//             context,
//             'random_weight.svg',
//             'Random Weigh in',
//             borderColor,
//           ),
//           _buildActionButton(
//             context,
//             'draw_list.svg',
//             'Draw List',
//             borderColor,
//           ),
//           _buildActionButton(
//             context,
//             'move_match.svg',
//             'Moved Matches',
//             borderColor,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(
//     BuildContext context,
//     String iconPath,
//     String label,
//     Color borderColor,
//   ) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SvgPicture.asset('$iconsBasePath$iconPath', width: 22),
//         const SizedBox(height: 6),
//         SizedBox(
//           width: 64,
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: Theme.of(
//               context,
//             ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1.2),
//             maxLines: 2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCarousel(BuildContext context, HomeController controller) {
//     return Container(
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: Column(
//         children: [
//           SizedBox(
//             height: 160,
//             child: controller.carouselItems.isEmpty
//                 ? const Center(child: Text('No carousels available'))
//                 : PageView.builder(
//                     itemCount: controller.carouselItems.length,
//                     controller: PageController(initialPage: 0),
//                     onPageChanged: controller.onCarouselChanged,
//                     itemBuilder: (context, index) {
//                       final carousel = controller.carouselItems[index];
//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Image.network(
//                           carousel.image ?? "",
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                                 color: Colors.grey[300],
//                                 child: const Icon(Icons.image, size: 50),
//                               ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           const SizedBox(height: 12),
//           GetBuilder<HomeController>(
//             id: 'carousel_dots',
//             builder: (controller) => Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 controller.carouselItems.length,
//                 (index) => AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: const EdgeInsets.symmetric(horizontal: 3),
//                   width: controller.currentCarouselIndex.value == index
//                       ? 20
//                       : 6,
//                   height: 6,
//                   decoration: BoxDecoration(
//                     color: controller.currentCarouselIndex.value == index
//                         ? AppColors.black
//                         : AppColors.grey,
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSponsorsSection(
//     BuildContext context,
//     HomeController controller,
//   ) {
//     return Container(
//       color: Theme.of(context).cardColor,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Our Sponsors', style: Get.textTheme.labelMedium),
//           const SizedBox(height: 16),

//           GetBuilder<HomeController>(
//             id: 'sponsors_list',
//             builder: (controller) {
//               if (controller.sponsorItems.isEmpty &&
//                   !controller.isLoadingMoreSponsors) {
//                 return const Center(
//                   child: Text(
//                     'No sponsors available',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 );
//               }

//               return SizedBox(
//                 height: 50,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount:
//                       controller.sponsorItems.length +
//                       (controller.hasMoreSponsors ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     // Load more indicator as last item
//                     if (index == controller.sponsorItems.length) {
//                       if (controller.hasMoreSponsors &&
//                           !controller.isLoadingMoreSponsors) {
//                         // Trigger load more when the last item becomes visible
//                         WidgetsBinding.instance.addPostFrameCallback((_) {
//                           controller.loadMoreSponsors();
//                         });
//                       }

//                       return controller.isLoadingMoreSponsors
//                           ? Container(
//                               width: 80,
//                               margin: const EdgeInsets.only(right: 33),
//                               child: const Center(
//                                 child: SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : const SizedBox.shrink();
//                     }

//                     final sponsor = controller.sponsorItems[index];
//                     return Container(
//                       width: 80,
//                       margin: EdgeInsets.only(
//                         right: index == controller.sponsorItems.length - 1
//                             ? 0
//                             : 12,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           width: 1,
//                           color: context.theme.highlightColor,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Image.network(
//                           sponsor.image ?? "",

//                           errorBuilder: (context, error, stackTrace) =>
//                               const Icon(Icons.business, size: 24),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNewsItem(BuildContext context, NewsFeed item) {
//     final createdByName = item.createdBy != null
//         ? '${item.createdBy!['firstName'] ?? ''} ${item.createdBy!['lastName'] ?? ''}'
//               .trim()
//         : 'Unknown';

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
//           child: item.image != null && item.image!.isNotEmpty
//               ? Image.network(
//                   item.image!,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     color: Colors.grey[400],
//                     child: Icon(
//                       Icons.image_outlined,
//                       color: Colors.grey[600],
//                       size: 28,
//                     ),
//                   ),
//                 )
//               : Container(
//                   color: Colors.grey[400],
//                   child: Icon(
//                     Icons.image_outlined,
//                     color: Colors.grey[600],
//                     size: 28,
//                   ),
//                 ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 item.title,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: Theme.of(
//                   context,
//                 ).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 item.createdAt != null
//                     ? item.createdAt!.toString().substring(0, 10)
//                     : 'Unknown date',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   fontSize: 11,
//                   color: AppColors.grey,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'By: $createdByName',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   fontSize: 11,
//                   color: AppColors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadMoreNewsIndicator(HomeController controller) {
//     return GetBuilder<HomeController>(
//       id: 'news_loader',
//       builder: (controller) {
//         if (controller.isLoadingMoreNews) {
//           return const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (!controller.hasMoreNews && controller.newsItems.isNotEmpty) {
//           return const Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               'No more news to load',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           );
//         }

//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildBottomNavBar(HomeController controller, bool isDark) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: GetBuilder<HomeController>(
//         id: 'bottom_nav',
//         builder: (controller) => BottomNavigationBar(
//           currentIndex: controller.selectedTab.value,
//           onTap: controller.changeTab,
//           type: BottomNavigationBarType.fixed,
//           selectedFontSize: 11,
//           unselectedFontSize: 11,
//           iconSize: 24,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.home_outlined),
//               ),
//               activeIcon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.home),
//               ),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.calendar_today_outlined),
//               ),
//               activeIcon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.calendar_today),
//               ),
//               label: 'Schedule',
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.emoji_events_outlined),
//               ),
//               activeIcon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.emoji_events),
//               ),
//               label: 'Results',
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.play_circle_outline),
//               ),
//               activeIcon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.play_circle),
//               ),
//               label: 'Watch',
//             ),
//             BottomNavigationBarItem(
//               icon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.sensors),
//               ),
//               activeIcon: Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Icon(Icons.sensors),
//               ),
//               label: 'Live',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationButton(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         InkWell(
//           onTap: () {
//             Get.to(() => const LoginScreen());
//           },
//           child: Container(
//             width: 56,
//             height: 56,
//             decoration: BoxDecoration(
//               color: AppColors.black,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.notifications_outlined,
//               color: AppColors.white,
//               size: 26,
//             ),
//           ),
//         ),
//         Positioned(
//           right: 2,
//           top: 2,
//           child: Container(
//             padding: const EdgeInsets.all(5),
//             decoration: const BoxDecoration(
//               color: AppColors.accentRed,
//               shape: BoxShape.circle,
//             ),
//             constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
//             child: const Text(
//               '1',
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: 11,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
