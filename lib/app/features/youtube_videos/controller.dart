import 'package:flutter/material.dart';
import 'package:fmac/models/vidoes.dart';
import 'package:fmac/services/api_services.dart';
import 'package:get/get.dart';

class VideoController extends GetxController {
  var isLoading = true.obs;
  var isLoadMoreLoading = false.obs;
  var videos = <Video>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var isRefreshing = false.obs;

  final ApiService _apiService = Get.find();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (currentPage.value < totalPages.value && !isLoadMoreLoading.value) {
        loadMoreVideos();
      }
    }
  }

  Future<void> fetchVideos({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
      currentPage.value = 1;
    } else if (!isRefresh && currentPage.value > totalPages.value) {
      return;
    } else {
      isLoading.value = true;
    }

    try {
      final response = await _apiService.getVideos(page: currentPage.value);
      if (isRefresh) {
        videos.clear();
      }
      videos.addAll(response.data);
      totalPages.value = response.pagination.totalPages;
      currentPage.value++;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load videos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error fetching videos: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMoreVideos() async {
    if (isLoadMoreLoading.value) return;
    isLoadMoreLoading.value = true;

    try {
      final response = await _apiService.getVideos(page: currentPage.value);
      videos.addAll(response.data);
      totalPages.value = response.pagination.totalPages;
      currentPage.value++;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load more videos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error loading more videos: $e');
    } finally {
      isLoadMoreLoading.value = false;
    }
  }

  Future<void> incrementVideoViews(String videoId) async {
    try {
      await _apiService.incrementVideoViews(videoId);
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
