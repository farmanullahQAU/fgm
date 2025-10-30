// import 'package:flutter/material.dart';
// import 'package:fmac/models/carousel.dart';
// import 'package:fmac/models/header_logo.dart';
// import 'package:fmac/models/news_feed.dart';
// import 'package:fmac/models/sponsor.dart';
// import 'package:fmac/services/api_services.dart';
// import 'package:get/get.dart';

// class HomeController extends GetxController {
//   final ApiService _apiService = Get.find<ApiService>();

//   // UI State
//   final RxInt selectedTab = 0.obs;
//   final RxInt currentCarouselIndex = 0.obs;

//   // Data
//   final List<NewsFeed> _newsItems = [];
//   final List<Carousel> _carouselItems = [];
//   final List<Sponsor> _sponsorItems = [];
//   final List<AppHeaderLogo> _headerLogos = [];

//   // Pagination States
//   final RxBool _isLoading = false.obs;
//   final RxBool _isLoadingMoreNews = false.obs;
//   final RxBool _isLoadingMoreSponsors = false.obs;
//   final RxString _errorMessage = ''.obs;

//   int _currentNewsPage = 1;
//   int _currentSponsorPage = 1;
//   bool _hasMoreNews = true;
//   bool _hasMoreSponsors = true;

//   // Getters for data (immutable access)
//   List<NewsFeed> get newsItems => List.unmodifiable(_newsItems);
//   List<Carousel> get carouselItems => List.unmodifiable(_carouselItems);
//   List<Sponsor> get sponsorItems => List.unmodifiable(_sponsorItems);
//   List<AppHeaderLogo> get headerLogos => List.unmodifiable(_headerLogos);

//   // Getters for state
//   bool get isLoading => _isLoading.value;
//   bool get isLoadingMoreNews => _isLoadingMoreNews.value;
//   bool get isLoadingMoreSponsors => _isLoadingMoreSponsors.value;
//   bool get hasMoreNews => _hasMoreNews;
//   bool get hasMoreSponsors => _hasMoreSponsors;
//   String get errorMessage => _errorMessage.value;
//   final RxBool _isLoadingSchedules = false.obs;
//   final RxString _scheduleErrorMessage = ''.obs;

//   // Getter for state
//   String get scheduleErrorMessage => _scheduleErrorMessage.value;

//   @override
//   void onInit() {
//     super.onInit();
//     loadInitialData();
//   }

//   Future<void> loadInitialData() async {
//     _isLoading.value = true;
//     _errorMessage.value = '';
//     _scheduleErrorMessage.value = ''; // Clear schedule error

//     // Clear existing data
//     _newsItems.clear();
//     _carouselItems.clear();
//     _sponsorItems.clear();
//     _headerLogos.clear();

//     _currentNewsPage = 1;
//     _currentSponsorPage = 1;
//     _hasMoreNews = true;
//     _hasMoreSponsors = true;

//     try {
//       await Future.wait([_loadNewsFeeds(), _loadCarousels(), _loadSponsors()]);
//     } catch (e) {
//       _errorMessage.value = e.toString();
//       _scheduleErrorMessage.value = e.toString();
//       Get.snackbar('Error', e.toString());
//     } finally {
//       _isLoading.value = false;
//       update();
//     }
//   }

//   Future<void> _loadNewsFeeds({bool loadMore = false}) async {
//     if (loadMore) {
//       if (!_hasMoreNews || _isLoadingMoreNews.value) return;
//       _isLoadingMoreNews.value = true;
//       _currentNewsPage++;
//     } else {
//       _currentNewsPage = 1;
//       _hasMoreNews = true;
//     }

//     try {
//       final newsResponse = await _apiService.getNewsFeeds(
//         page: _currentNewsPage,
//       );

//       if (loadMore) {
//         _newsItems.addAll(newsResponse.data);
//         print(
//           'Loaded more news. Page: $_currentNewsPage, Items: ${newsResponse.data.length}, Total: ${_newsItems.length}',
//         );
//       } else {
//         _newsItems.clear();
//         _newsItems.addAll(newsResponse.data);
//         print(
//           'Loaded initial news. Page: $_currentNewsPage, Items: ${_newsItems.length}',
//         );
//       }

//       _hasMoreNews = newsItems.length < newsResponse.pagination.totalItems;
//       print('Has more news: $_hasMoreNews');
//     } catch (e) {
//       if (loadMore) {
//         _currentNewsPage--; // Rollback page on error
//       }
//       rethrow;
//     } finally {
//       if (loadMore) {
//         _isLoadingMoreNews.value = false;
//       }
//     }
//   }

//   Future<void> _loadCarousels() async {
//     try {
//       final carouselResponse = await _apiService.getCarousels();
//       _carouselItems.clear();
//       _carouselItems.addAll(carouselResponse.data);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _loadSponsors({bool loadMore = false}) async {
//     if (loadMore) {
//       if (!_hasMoreSponsors || _isLoadingMoreSponsors.value) return;
//       _isLoadingMoreSponsors.value = true;
//       _currentSponsorPage++;
//     } else {
//       _currentSponsorPage = 1;
//       _hasMoreSponsors = true;
//     }

//     try {
//       final sponsorResponse = await _apiService.getSponsors(
//         page: _currentSponsorPage,
//       );

//       if (loadMore) {
//         _sponsorItems.addAll(sponsorResponse.data);
//       } else {
//         _sponsorItems.clear();
//         _sponsorItems.addAll(sponsorResponse.data);
//       }

//       _hasMoreSponsors =
//           _sponsorItems.length < sponsorResponse.pagination.totalItems;
//       print(
//         'Loaded sponsors. Total: ${_sponsorItems.length}, Has more: $_hasMoreSponsors',
//       );
//     } catch (e) {
//       if (loadMore) {
//         _currentSponsorPage--;
//       }
//       rethrow;
//     } finally {
//       if (loadMore) {
//         _isLoadingMoreSponsors.value = false;
//       }
//     }
//   }

//   Future<void> loadMoreNews() async {
//     print(
//       'loadMoreNews called - hasMore: $_hasMoreNews, isLoading: ${_isLoadingMoreNews.value}',
//     );

//     if (!_hasMoreNews || _isLoadingMoreNews.value) {
//       print('Skipping loadMoreNews - conditions not met');
//       return;
//     }

//     try {
//       await _loadNewsFeeds(loadMore: true);
//       update(['news_list', 'news_loader']);
//       print('News loaded successfully. Total items: ${_newsItems.length}');
//     } catch (e) {
//       _errorMessage.value = 'Failed to load more news: ${e.toString()}';
//       Get.snackbar('Error', 'Failed to load more news');
//       print('Error loading more news: $e');
//     }
//   }

//   Future<void> loadMoreSponsors() async {
//     if (!_hasMoreSponsors || _isLoadingMoreSponsors.value) return;

//     try {
//       await _loadSponsors(loadMore: true);
//       update(['sponsors_list']);
//     } catch (e) {
//       _errorMessage.value = 'Failed to load more sponsors: ${e.toString()}';
//       Get.snackbar('Error', 'Failed to load more sponsors');
//     }
//   }

//   void changeTab(int index) {
//     selectedTab.value = index;
//     update(['bottom_nav']); // Update only bottom navigation
//   }

//   void onCarouselChanged(int index) {
//     currentCarouselIndex.value = index;
//     update(['carousel_dots']);
//   }

//   // Method to handle scroll for news
//   void handleNewsScroll(ScrollMetrics metrics) {
//     final maxScroll = metrics.maxScrollExtent;
//     final currentScroll = metrics.pixels;
//     final threshold = maxScroll * 0.8;

//     if (currentScroll >= threshold &&
//         _hasMoreNews &&
//         !_isLoadingMoreNews.value &&
//         !_isLoading.value) {
//       print('Scroll threshold reached. Loading more news...');
//       loadMoreNews();
//     }
//   }

//   // Method to handle horizontal scroll for sponsors
//   void handleSponsorsScroll(ScrollMetrics metrics) {
//     final maxScroll = metrics.maxScrollExtent;
//     final currentScroll = metrics.pixels;
//     final threshold = maxScroll * 0.7;

//     if (currentScroll >= threshold &&
//         _hasMoreSponsors &&
//         !_isLoadingMoreSponsors.value &&
//         !_isLoading.value) {
//       print('Sponsors scroll threshold reached. Loading more sponsors...');
//       loadMoreSponsors();
//     }
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fmac/models/carousel.dart';
import 'package:fmac/models/event.dart';
import 'package:fmac/models/header_logo.dart';
import 'package:fmac/models/news_feed.dart';
import 'package:fmac/models/sponsor.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // UI State
  final RxInt selectedTab = 0.obs;
  final RxInt currentCarouselIndex = 0.obs;

  // Data
  final List<NewsFeed> _newsItems = [];
  final List<Carousel> _carouselItems = [];
  final List<Sponsor> _sponsorItems = [];
  final List<AppHeaderLogo> _headerLogos = [];
  final List<Event> _events = [];

  // Pagination States
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMoreNews = false.obs;
  final RxBool _isLoadingMoreSponsors = false.obs;
  final RxString _errorMessage = ''.obs;

  int _currentNewsPage = 1;
  int _currentSponsorPage = 1;
  bool _hasMoreNews = true;
  bool _hasMoreSponsors = true;

  // Getters for data (immutable access)
  List<NewsFeed> get newsItems => List.unmodifiable(_newsItems);
  List<Carousel> get carouselItems => List.unmodifiable(_carouselItems);
  List<Sponsor> get sponsorItems => List.unmodifiable(_sponsorItems);
  List<AppHeaderLogo> get headerLogos => List.unmodifiable(_headerLogos);

  // Getters for state
  bool get isLoading => _isLoading.value;
  bool get isLoadingMoreNews => _isLoadingMoreNews.value;
  bool get isLoadingMoreSponsors => _isLoadingMoreSponsors.value;
  bool get hasMoreNews => _hasMoreNews;
  bool get hasMoreSponsors => _hasMoreSponsors;
  String get errorMessage => _errorMessage.value;
  final RxBool _isLoadingSchedules = false.obs;
  final RxString _scheduleErrorMessage = ''.obs;
  final RxInt _currentBannerIndex = 0.obs;
  PageController? _bannerPageController;
  Timer? _bannerTimer;

  String get scheduleErrorMessage => _scheduleErrorMessage.value;
  List<Event> get events => List.unmodifiable(_events);
  int get currentBannerIndex => _currentBannerIndex.value;
  bool get hasLiveEvents => _events.any((e) {
    final s = e.status.toLowerCase();
    return s.contains('upcoming') ||
        s.contains('open') ||
        s.contains('ongoing');
  });
  List<Event> get liveEvents => _events
      .where((e) {
        final s = e.status.toLowerCase();
        return s.contains('upcoming') ||
            s.contains('open') ||
            s.contains('ongoing');
      })
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _scheduleErrorMessage.value = '';

    // Reset pagination states BEFORE clearing data
    _currentNewsPage = 1;
    _currentSponsorPage = 1;
    _hasMoreNews = true;
    _hasMoreSponsors = true;

    try {
      // Fetch all data in parallel
      await Future.wait([
        _loadNewsFeeds(),
        _loadCarousels(),
        _loadSponsors(),
        _loadEvents(),
      ], eagerError: true);

      // Only update UI after all data is successfully loaded
      _isLoading.value = false;
      update();
      _setupBannerAutoplay();
    } catch (e) {
      _errorMessage.value = e.toString();
      _scheduleErrorMessage.value = e.toString();
      _isLoading.value = false;
      update();
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadNewsFeeds({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMoreNews || _isLoadingMoreNews.value) return;
      _isLoadingMoreNews.value = true;
      _currentNewsPage++;
    } else {
      _currentNewsPage = 1;
      _hasMoreNews = true;
    }

    try {
      final newsResponse = await _apiService.getNewsFeeds(
        page: _currentNewsPage,
      );

      // Safely add items - check for null response
      if (newsResponse.data.isNotEmpty) {
        if (loadMore) {
          _newsItems.addAll(newsResponse.data);
          print(
            'Loaded more news. Page: $_currentNewsPage, Items: ${newsResponse.data.length}, Total: ${_newsItems.length}',
          );
        } else {
          _newsItems.clear();
          _newsItems.addAll(newsResponse.data);
          print(
            'Loaded initial news. Page: $_currentNewsPage, Items: ${_newsItems.length}',
          );
        }
      }

      // Update hasMoreNews based on actual count
      _hasMoreNews =
          _newsItems.length < (newsResponse.pagination.totalItems ?? 0);
      print('Has more news: $_hasMoreNews');
    } catch (e) {
      if (loadMore) {
        _currentNewsPage--;
      }
      print('Error loading news: $e');
      rethrow;
    } finally {
      if (loadMore) {
        _isLoadingMoreNews.value = false;
      }
    }
  }

  Future<void> _loadCarousels() async {
    try {
      final carouselResponse = await _apiService.getCarousels();
      _carouselItems.clear();
      if (carouselResponse.data.isNotEmpty) {
        _carouselItems.addAll(carouselResponse.data);
      }
    } catch (e) {
      print('Error loading carousels: $e');
      rethrow;
    }
  }

  Future<void> _loadSponsors({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMoreSponsors || _isLoadingMoreSponsors.value) return;
      _isLoadingMoreSponsors.value = true;
      _currentSponsorPage++;
    } else {
      _currentSponsorPage = 1;
      _hasMoreSponsors = true;
    }

    try {
      final sponsorResponse = await _apiService.getSponsors(
        page: _currentSponsorPage,
      );

      if (sponsorResponse.data.isNotEmpty) {
        if (loadMore) {
          _sponsorItems.addAll(sponsorResponse.data);
        } else {
          _sponsorItems.clear();
          _sponsorItems.addAll(sponsorResponse.data);
        }
      }

      _hasMoreSponsors =
          _sponsorItems.length < (sponsorResponse.pagination.totalItems ?? 0);
      print(
        'Loaded sponsors. Total: ${_sponsorItems.length}, Has more: $_hasMoreSponsors',
      );
    } catch (e) {
      if (loadMore) {
        _currentSponsorPage--;
      }
      print('Error loading sponsors: $e');
      rethrow;
    } finally {
      if (loadMore) {
        _isLoadingMoreSponsors.value = false;
      }
    }
  }

  Future<void> _loadEvents() async {
    try {
      final eventsResponse = await _apiService.getEvents(page: 1);
      _events.clear();
      _events.addAll(eventsResponse.data);
    } catch (e) {
      print('Error loading events: $e');
      // Do not rethrow; banner is optional
    }
  }

  Future<void> loadMoreNews() async {
    print(
      'loadMoreNews called - hasMore: $_hasMoreNews, isLoading: ${_isLoadingMoreNews.value}',
    );

    if (!_hasMoreNews || _isLoadingMoreNews.value) {
      print('Skipping loadMoreNews - conditions not met');
      return;
    }

    try {
      await _loadNewsFeeds(loadMore: true);
      update(['news_list', 'news_loader']);
      print('News loaded successfully. Total items: ${_newsItems.length}');
    } catch (e) {
      _errorMessage.value = 'Failed to load more news: ${e.toString()}';
      Get.snackbar('Error', 'Failed to load more news');
      print('Error loading more news: $e');
    }
  }

  Future<void> loadMoreSponsors() async {
    if (!_hasMoreSponsors || _isLoadingMoreSponsors.value) return;

    try {
      await _loadSponsors(loadMore: true);
      update(['sponsors_list']);
    } catch (e) {
      _errorMessage.value = 'Failed to load more sponsors: ${e.toString()}';
      Get.snackbar('Error', 'Failed to load more sponsors');
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    update(['bottom_nav']);
  }

  void onCarouselChanged(int index) {
    currentCarouselIndex.value = index;
    update(['carousel_dots']);
  }

  void onBannerChanged(int index) {
    _currentBannerIndex.value = index;
    update(['event_banner']);
  }

  void handleNewsScroll(ScrollMetrics metrics) {
    final maxScroll = metrics.maxScrollExtent;
    final currentScroll = metrics.pixels;
    final threshold = maxScroll * 0.8;

    if (currentScroll >= threshold &&
        _hasMoreNews &&
        !_isLoadingMoreNews.value &&
        !_isLoading.value) {
      print('Scroll threshold reached. Loading more news...');
      loadMoreNews();
    }
  }

  void handleSponsorsScroll(ScrollMetrics metrics) {
    final maxScroll = metrics.maxScrollExtent;
    final currentScroll = metrics.pixels;
    final threshold = maxScroll * 0.7;

    if (currentScroll >= threshold &&
        _hasMoreSponsors &&
        !_isLoadingMoreSponsors.value &&
        !_isLoading.value) {
      print('Sponsors scroll threshold reached. Loading more sponsors...');
      loadMoreSponsors();
    }
  }

  void _setupBannerAutoplay() {
    _bannerTimer?.cancel();
    if (liveEvents.isEmpty) return;
    _bannerPageController ??= PageController();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_bannerPageController == null) return;
      final count = liveEvents.length;
      final next = (currentBannerIndex + 1) % count;
      _bannerPageController!.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      onBannerChanged(next);
    });
  }

  PageController? get bannerPageController => _bannerPageController;

  @override
  void onClose() {
    _bannerTimer?.cancel();
    _bannerPageController?.dispose();
    super.onClose();
  }
}
