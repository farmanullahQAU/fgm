import 'package:fmac/models/header_logo.dart';
import 'package:get/get.dart';

import '../models/carousel.dart';
import '../models/news_feed.dart';
import '../models/result.dart';
import '../models/schedule.dart';
import '../models/sponsor.dart';
import '../models/ticket.dart';
import '../models/user.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final Pagination pagination;

  PaginatedResponse({required this.data, required this.pagination});
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      itemsPerPage: json['itemsPerPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
    };
  }
}

class ApiService extends GetConnect {
  static const String _baseUrl = 'http://10.128.193.162:5000/api';

  String? _authToken;

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 10);
    httpClient.addRequestModifier<dynamic>((request) {
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      return request;
    });
    super.onInit();
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // ================= USER APIs =================
  Future<PaginatedResponse<User>> getUsers({int page = 1, String? role}) async {
    // Build query parameters
    final query = {'page': page.toString()};
    if (role != null) {
      query['role'] = role;
    }
    final response = await get('/users', query: query); // Pass query parameters
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch users: ${response.body['message'] ?? response.statusText}',
      );
    }
    final data = response.body['data'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<User> getUserProfile() async {
    final response = await get('/users/profile');
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch profile: ${response.body['message'] ?? response.statusText}',
      );
    }
    return User.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  Future<User> updateUserProfile(Map<String, dynamic> updates) async {
    final response = await put('/users/profile', updates);
    if (response.status.hasError) {
      throw Exception(
        'Failed to update profile: ${response.body['message'] ?? response.statusText}',
      );
    }
    return User.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  // ================= TICKET APIs =================
  Future<PaginatedResponse<Ticket>> getTickets({int page = 1}) async {
    final response = await get('/tickets?page=$page');
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch tickets: ${response.body['message'] ?? response.statusText}',
      );
    }
    final data = response.body['data'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<Ticket> createTicket(Ticket ticket) async {
    final response = await post('/tickets', ticket.toJson());
    if (response.status.hasError) {
      throw Exception(
        'Failed to create ticket: ${response.body['message'] ?? response.statusText}',
      );
    }
    return Ticket.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  // ================= SPONSOR APIs =================
  Future<PaginatedResponse<Sponsor>> getSponsors({int page = 1}) async {
    final url = '/sponsors?page=$page';
    print('Fetching sponsors from: $_baseUrl$url');
    final response = await get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.status.hasError) {
      final message = response.body['message'] ?? response.statusText;
      final errors = response.body['errors'] as List<dynamic>?;
      final errorDetails =
          errors?.map((e) => '${e['field']}: ${e['message']}').join(', ') ?? '';
      throw Exception(
        'Failed to fetch sponsors: $message${errorDetails.isNotEmpty ? ' ($errorDetails)' : ''}',
      );
    }
    final data = response.body['data']['sponsors'] as List<dynamic>? ?? [];
    final pagination = Pagination.fromJson(
      response.body['data']['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => Sponsor.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<PaginatedResponse<Sponsor>> getActiveSponsors() async {
    final response = await get('/sponsors/active');
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch active sponsors: ${response.body['message'] ?? response.statusText}',
      );
    }
    final data = response.body['data'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => Sponsor.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<PaginatedResponse<Sponsor>> getSponsorsByCategory(
    String category,
  ) async {
    final response = await get('/sponsors/category/$category');
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch sponsors by category: ${response.body['message'] ?? response.statusText}',
      );
    }
    final data = response.body['data'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => Sponsor.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<Sponsor> createSponsor(Sponsor sponsor) async {
    final response = await post('/sponsors', sponsor.toJson());
    if (response.status.hasError) {
      throw Exception(
        'Failed to create sponsor: ${response.body['message'] ?? response.statusText}',
      );
    }
    return Sponsor.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  // ================= SCHEDULE APIs =================
  Future<PaginatedResponse<Schedule>> getSchedules({int page = 1}) async {
    final response = await get('/schedules?page=$page');
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch schedules: ${response.body['message'] ?? response.statusText}',
      );
    }
    final data =
        response.body['data']['schedules']
            as List<dynamic>; // Corrected to access 'schedules'
    final pagination = Pagination.fromJson(
      response.body['data']['pagination']
          as Map<String, dynamic>, // Corrected to access 'pagination'
    );
    return PaginatedResponse(
      data: data
          .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<Schedule> createSchedule(Schedule schedule) async {
    final response = await post('/schedules', schedule.toJson());
    if (response.status.hasError) {
      throw Exception(
        'Failed to create schedule: ${response.body['message'] ?? response.statusText}',
      );
    }
    return Schedule.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  // ================= RESULT APIs =================
  Future<PaginatedResponse<Result>> getResults({int page = 1}) async {
    final response = await get('/results?page=$page');
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch results: ${response.body['message'] ?? response.statusText}',
      );
    }

    // Fixed: Access the correct data structure based on your API response
    final data = response.body['data']['results'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['data']['pagination'] as Map<String, dynamic>,
    );

    return PaginatedResponse(
      data: data
          .map((json) => Result.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<Result> createResult(Result result) async {
    final response = await post('/results', result.toJson());
    if (response.status.hasError) {
      throw Exception(
        'Failed to create result: ${response.body['message'] ?? response.statusText}',
      );
    }
    return Result.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  // ================= NEWS FEED APIs =================
  // Future<PaginatedResponse<NewsFeed>> getNewsFeeds({int page = 1}) async {
  //   final url = '/newsfeeds?page=$page';
  //   print('Fetching news feeds from: $_baseUrl$url'); // Log full URL
  //   final response = await get(url);
  //   print('Response status: ${response.statusCode}');
  //   print('Response body: ${response.body}'); // Log full body for debugging
  //   if (response.status.hasError) {
  //     final message = response.body['message'] ?? response.statusText;
  //     final errors = response.body['errors'] as List<dynamic>?;
  //     final errorDetails =
  //         errors?.map((e) => '${e['field']}: ${e['message']}').join(', ') ?? '';
  //     throw Exception(
  //       'Failed to fetch news feeds: $message${errorDetails.isNotEmpty ? ' ($errorDetails)' : ''}',
  //     );
  //   }

  //   final data = response.body['data'];
  //   final pagination = Pagination.fromJson(data['pagination']);
  //   return PaginatedResponse(
  //     data: data['newsFeeds'].map((json) => NewsFeed.fromJson(json)),
  //     pagination: pagination,
  //   );
  // }
  Future<PaginatedResponse<NewsFeed>> getNewsFeeds({int page = 1}) async {
    final url = '/newsfeeds?page=$page';
    print('Fetching news feeds from: $_baseUrl$url'); // Log full URL
    final response = await get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Log full body for debugging
    if (response.status.hasError) {
      if (response.statusCode == null) {
        throw Exception("Please check your internect connection");
      } else {
        final message = response.body['message'] ?? response.statusText;
        throw Exception(message);
      }
    }
    final data = response.body['data']['newsFeeds'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['data']['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => NewsFeed.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<NewsFeed> createNewsFeed(NewsFeed newsFeed) async {
    final response = await post('/news_feeds', newsFeed.toJson());
    if (response.status.hasError) {
      throw Exception(
        'Failed to create news feed: ${response.body['message'] ?? response.statusText}',
      );
    }
    return NewsFeed.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  // ================= CAROUSEL APIs =================
  Future<PaginatedResponse<Carousel>> getCarousels({int page = 1}) async {
    final url = '/carousels?page=$page';
    print('Fetching carousels from: $_baseUrl$url');
    final response = await get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.status.hasError) {
      final message = response.body['message'] ?? response.statusText;
      final errors = response.body['errors'] as List<dynamic>?;
      final errorDetails =
          errors?.map((e) => '${e['field']}: ${e['message']}').join(', ') ?? '';
      throw Exception(
        'Failed to fetch carousels: $message${errorDetails.isNotEmpty ? ' ($errorDetails)' : ''}',
      );
    }
    final data = response.body['data']['carousels'] as List<dynamic>? ?? [];
    final pagination = Pagination.fromJson(
      response.body['data']['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => Carousel.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<Carousel> createCarousel(Carousel carousel) async {
    final response = await post('/carousels', carousel.toJson());
    if (response.status.hasError) {
      throw Exception(
        'Failed to create carousel: ${response.body['message'] ?? response.statusText}',
      );
    }
    return Carousel.fromJson(response.body['data'] as Map<String, dynamic>);
  }

  // ================= HEADER LOGO APIs =================
  Future<PaginatedResponse<AppHeaderLogo>> getAppHeaderLogos({
    int page = 1,
  }) async {
    final url = '/app_header_logos?page=$page';
    print('Fetching app header logos from: $_baseUrl$url'); // Log full URL
    final response = await get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Log full body for debugging
    if (response.status.hasError) {
      final message = response.body['message'] ?? response.statusText;
      final errors = response.body['errors'] as List<dynamic>?;
      final errorDetails =
          errors?.map((e) => '${e['field']}: ${e['message']}').join(', ') ?? '';
      throw Exception(
        'Failed to fetch app header logos: $message${errorDetails.isNotEmpty ? ' ($errorDetails)' : ''}',
      );
    }
    final data =
        response.body['data']['appHeaderLogos'] as List<dynamic>? ?? [];
    final pagination = Pagination.fromJson(
      response.body['data']['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => AppHeaderLogo.fromJson(json as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  Future<AppHeaderLogo> createAppHeaderLogo(AppHeaderLogo logo) async {
    final response = await post('/app_header_logos', logo.toJson());
    if (response.status.hasError) {
      throw Exception(
        'Failed to create app header logo: ${response.body['message'] ?? response.statusText}',
      );
    }
    return AppHeaderLogo.fromJson(
      response.body['data'] as Map<String, dynamic>,
    );
  }

  // ================= AUTH APIs =================
  Future<Response> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    return response;
  }

  Future<Response> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (phone != null) 'phone': phone,
    };
    final response = await post('/auth/signup', body);
    return response;
  }

  Future<Response> refreshToken(String refreshToken) async {
    final response = await post('/auth/refresh', {
      'refreshToken': refreshToken,
    });
    return response;
  }

  Future<Response> logout(String? refreshToken) async {
    final response = await post('/auth/logout', {'refreshToken': refreshToken});
    return response;
  }

  Future<Response> logoutAll() async {
    final response = await post('/auth/logout-all', {});
    return response;
  }
}
