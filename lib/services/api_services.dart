import 'dart:async';

import 'package:fmac/models/carousel.dart';
import 'package:fmac/models/court.dart';
import 'package:fmac/models/court_details.dart';
import 'package:fmac/models/draw_list.dart';
import 'package:fmac/models/event.dart';
import 'package:fmac/models/header_logo.dart';
import 'package:fmac/models/moved_match.dart';
import 'package:fmac/models/news_feed.dart';
import 'package:fmac/models/payment_confirmation.dart';
import 'package:fmac/models/payment_intent.dart';
import 'package:fmac/models/purchased_ticket.dart';
import 'package:fmac/models/random_weigh_in.dart';
import 'package:fmac/models/result.dart';
import 'package:fmac/models/schedule.dart';
import 'package:fmac/models/sponsor.dart';
import 'package:fmac/models/team.dart';
import 'package:fmac/models/team_details.dart' hide Event;
import 'package:fmac/models/ticket.dart';
import 'package:fmac/models/user.dart';
import 'package:fmac/models/vidoes.dart';
import 'package:fmac/models/weight_division_participant.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:fmac/services/storage_services/token_storage_service.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:logger/logger.dart';

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
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
    );
  }
}

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiError(this.message, {this.statusCode, this.details});

  @override
  String toString() =>
      'ApiError: $message${details != null ? ' ($details)' : ''}';
}

class ApiService extends GetConnect {
  static final String _baseUrl = 'http://10.77.77.162:5000/api';
  final TokenStorageService _tokenStorage = TokenStorageService();
  final Logger _logger = Logger();
  bool _isRefreshing = false;

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 30);

    httpClient.addRequestModifier<dynamic>((request) async {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Log request details
      _logger.i('═══════════════════════════════════════════════════════════');
      _logger.i('📤 API REQUEST');
      _logger.i('Method: ${request.method}');
      _logger.i('URL: ${request.url}');
      if (request.headers.isNotEmpty) {
        _logger.d('Headers: ${request.headers}');
      }
      if (request.url.toString().contains('/login') ||
          request.url.toString().contains('/register')) {
        _logger.d('Body: [Sensitive data hidden]');
      }
      _logger.i('═══════════════════════════════════════════════════════════');

      return request;
    });

    httpClient.addResponseModifier((request, response) async {
      // Log response details
      _logger.i('═══════════════════════════════════════════════════════════');
      _logger.i('📥 API RESPONSE');
      _logger.i('Status: ${response.statusCode}');
      _logger.i('URL: ${request.url}');

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        _logger.i('✅ Success');
        if (response.body != null) {
          // Log response body (truncate if too long)
          final bodyStr = response.body.toString();
          if (bodyStr.length > 500) {
            _logger.d('Body: ${bodyStr.substring(0, 500)}... (truncated)');
          } else {
            _logger.d('Body: $bodyStr');
          }
        }
      } else {
        _logger.e('❌ Error');
        _logger.e('Status: ${response.statusCode}');
        if (response.body != null) {
          _logger.e('Error Body: ${response.body}');
        }
      }
      _logger.i('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 401 && !_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshed = await _refreshToken();
          if (refreshed) {
            _logger.i('Token refreshed, retrying request...');
            return await _retryRequest(request);
          } else {
            _logger.e('Token refresh failed, logging out...');
            Get.find<AuthService>().logout();
            throw ApiError(
              'Session expired, please log in again',
              statusCode: 401,
            );
          }
        } finally {
          _isRefreshing = false;
        }
      }
      return response;
    });

    super.onInit();
  }

  Future<Response> _retryRequest(Request request) async {
    final token = await _tokenStorage.getAccessToken();
    request.headers['Authorization'] = 'Bearer $token';
    return await httpClient.request(
      request.url.path,
      request.method,
      body: request.bodyBytes,
      query: request.url.queryParameters,
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await post('/auth/refresh', {
        'refreshToken': refreshToken,
      });
      if (response.statusCode == 200) {
        final data = response.body['data'];
        await _tokenStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return false;
    }
  }

  Future<void> _handleResponse(Response response, String action) async {
    if (response.status.hasError) {
      final message =
          response.body['message'] ?? response.statusText ?? 'Unknown error';
      final errors = response.body['errors'] as List<dynamic>?;
      final details = errors
          ?.map((e) => '${e['field'] ?? 'unknown'}: ${e['message']}')
          .join(', ');

      _logger.e('═══════════════════════════════════════════════════════════');
      _logger.e('❌ API ERROR in $action');
      _logger.e('Status: ${response.statusCode}');
      _logger.e('Message: $message');
      if (details != null) {
        _logger.e('Details: $details');
      }
      _logger.e('Full Response: ${response.body}');
      _logger.e('═══════════════════════════════════════════════════════════');

      throw ApiError(
        'Failed to $action: $message',
        statusCode: response.statusCode,
        details: details,
      );
    } else {
      _logger.i('✅ $action completed successfully');
    }
  }

  // AUTH APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _handleResponse(response, 'login');
    return response.body['data'];
  }

  Future<Map<String, dynamic>> signup({
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
    await _handleResponse(response, 'signup');
    return response.body['data'];
  }

  Future<void> logout(String? refreshToken) async {
    final response = await post('/auth/logout', {'refreshToken': refreshToken});
    await _handleResponse(response, 'logout');
  }

  Future<void> logoutAll() async {
    final response = await post('/auth/logout-all', {});
    await _handleResponse(response, 'logout all');
  }

  // USER APIs
  Future<PaginatedResponse<User>> getUsers({int page = 1, String? role}) async {
    final query = {'page': page.toString()};
    if (role != null) query['role'] = role;
    final response = await get('/users', query: query);
    await _handleResponse(response, 'fetch users');
    final data = response.body['data'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => User.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<User> getUserProfile() async {
    final response = await get('/users/profile');
    await _handleResponse(response, 'fetch user profile');
    return User.fromJson(response.body['data']);
  }

  Future<User> updateUserProfile(Map<String, dynamic> updates) async {
    final response = await put('/users/profile', updates);
    await _handleResponse(response, 'update user profile');
    return User.fromJson(response.body['data']);
  }

  // EVENT APIs
  Future<PaginatedResponse<Event>> getEvents({int page = 1}) async {
    final response = await get('/events?page=$page');
    await _handleResponse(response, 'fetch events');
    final data = response.body['data']['events'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Event.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<Event> createEvent(Event event) async {
    final response = await post('/events', event.toJson());
    await _handleResponse(response, 'create event');
    return Event.fromJson(response.body['data']);
  }

  // TICKET APIs
  Future<void> createTicket(Ticket ticket, String eventId) async {
    final payload = ticket.toJson()..['event'] = eventId;
    _logger.i('Creating ticket with eventId: $eventId');
    _logger.i('Payload event field: ${payload['event']}');
    _logger.i('Full payload: $payload');
    final response = await post('/tickets', payload);
    await _handleResponse(response, 'create ticket');
    _logger.i('Ticket created successfully, response: ${response.body}');
  }

  // Future<PaginatedResponse<Ticket>> getTickets({int page = 1}) async {
  //   final response = await get('/tickets?page=$page');
  //   await _handleResponse(response, 'fetch tickets');
  //   final data = response.body['data'] as List<dynamic>;
  //   final pagination = Pagination.fromJson(response.body['pagination']);
  //   return PaginatedResponse(
  //     data: data.map((json) => Ticket.fromJson(json)).toList(),
  //     pagination: pagination,
  //   );
  // }

  Future<List<Ticket>> getUserTicketsByEvent({
    required String userId,
    required String eventId,
  }) async {
    final url = '/tickets/user/$userId/event/$eventId';
    final response = await get(url);
    await _handleResponse(response, 'fetch user tickets');

    _logger.d('UserTickets: ${response.statusCode} ${response.body}');
    final data = response.body['data'] as List<dynamic>? ?? [];
    return data.map((json) => Ticket.fromJson(json)).toList();
  }

  Future<Ticket> updateTicket(Ticket ticket) async {
    final response = await put('/tickets/${ticket.id}', ticket.toJson());
    await _handleResponse(response, 'update ticket');
    return Ticket.fromJson(response.body['data']);
  }

  Future<String> deleteTicket(String id) async {
    final response = await delete('/tickets/$id');
    await _handleResponse(response, 'delete ticket');
    return response.body['message'];
  }

  Future<void> createTickets(List<Map<String, dynamic>> tickets) async {
    final response = await post('/tickets/bulk', {'tickets': tickets});
    await _handleResponse(response, 'create bulk tickets');
  }

  Future<void> bulkUpdateTickets(List<Map<String, dynamic>> updates) async {
    final response = await patch('/tickets/bulk-update', {
      'ticketUpdates': updates,
    });
    await _handleResponse(response, 'bulk update tickets');
  }

  // SPONSOR APIs
  Future<PaginatedResponse<Sponsor>> getSponsors({int page = 1}) async {
    final response = await get('/sponsors?page=$page');
    await _handleResponse(response, 'fetch sponsors');
    final data = response.body['data']['sponsors'] as List<dynamic>? ?? [];
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Sponsor.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<PaginatedResponse<Sponsor>> getActiveSponsors() async {
    final response = await get('/sponsors/active');
    await _handleResponse(response, 'fetch active sponsors');
    final data = response.body['data'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Sponsor.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<PaginatedResponse<Sponsor>> getSponsorsByCategory(
    String category,
  ) async {
    final response = await get('/sponsors/category/$category');
    await _handleResponse(response, 'fetch sponsors by category');
    final data = response.body['data'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Sponsor.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<Sponsor> createSponsor(Sponsor sponsor) async {
    final response = await post('/sponsors', sponsor.toJson());
    await _handleResponse(response, 'create sponsor');
    return Sponsor.fromJson(response.body['data']);
  }

  // SCHEDULE APIs
  Future<PaginatedResponse<Schedule>> getSchedules({int page = 1}) async {
    final response = await get('/schedules?page=$page');
    await _handleResponse(response, 'fetch schedules');
    final data = response.body['data']['schedules'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Schedule.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<Schedule> createSchedule(Schedule schedule) async {
    final response = await post('/schedules', schedule.toJson());
    await _handleResponse(response, 'create schedule');
    return Schedule.fromJson(response.body['data']);
  }

  // RESULT APIs
  Future<PaginatedResponse<Result>> getResults({int page = 1}) async {
    final response = await get('/results?page=$page');
    await _handleResponse(response, 'fetch results');
    final data = response.body['data']['results'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Result.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<Result> createResult(Result result) async {
    final response = await post('/results', result.toJson());
    await _handleResponse(response, 'create result');
    return Result.fromJson(response.body['data']);
  }

  // NEWS FEED APIs
  Future<PaginatedResponse<NewsFeed>> getNewsFeeds({int page = 1}) async {
    final response = await get('/newsfeeds?page=$page');
    await _handleResponse(response, 'fetch news feeds');
    final data = response.body['data']['newsFeeds'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => NewsFeed.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<NewsFeed> createNewsFeed(NewsFeed newsFeed) async {
    final response = await post('/news_feeds', newsFeed.toJson());
    await _handleResponse(response, 'create news feed');
    return NewsFeed.fromJson(response.body['data']);
  }

  // CAROUSEL APIs
  Future<PaginatedResponse<Carousel>> getCarousels({int page = 1}) async {
    final response = await get('/carousels?page=$page');
    await _handleResponse(response, 'fetch carousels');
    final data = response.body['data']['carousels'] as List<dynamic>? ?? [];
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Carousel.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<Carousel> createCarousel(Carousel carousel) async {
    final response = await post('/carousels', carousel.toJson());
    await _handleResponse(response, 'create carousel');
    return Carousel.fromJson(response.body['data']);
  }

  // HEADER LOGO APIs
  Future<PaginatedResponse<AppHeaderLogo>> getAppHeaderLogos({
    int page = 1,
  }) async {
    final response = await get('/app_header_logos?page=$page');
    await _handleResponse(response, 'fetch app header logos');
    final data =
        response.body['data']['appHeaderLogos'] as List<dynamic>? ?? [];
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => AppHeaderLogo.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<AppHeaderLogo> createAppHeaderLogo(AppHeaderLogo logo) async {
    final response = await post('/app_header_logos', logo.toJson());
    await _handleResponse(response, 'create app header logo');
    return AppHeaderLogo.fromJson(response.body['data']);
  }

  // VIDEO APIs
  Future<PaginatedResponse<Video>> getVideos({required int page}) async {
    try {
      final response = await get('/youtube-videos?page=$page');
      await _handleResponse(response, 'fetch videos');
      final data = response.body['data']['videos'] as List<dynamic>;
      final pagination = Pagination.fromJson(response.body['pagination']);
      return PaginatedResponse(
        data: data.map((json) => Video.fromJson(json)).toList(),
        pagination: pagination,
      );
    } catch (e) {
      _logger.e('Error fetching videos: $e');
      rethrow;
    }
  }

  Future<void> incrementVideoViews(String videoId) async {
    final response = await post('/youtube-videos/$videoId/views', {});
    await _handleResponse(response, 'increment video views');
  }

  // PAYMENT API
  Future<PaymentIntent> createPaymentIntent(List<String> ticketIds) async {
    _logger.i('Creating payment intent with ticketIds: $ticketIds');

    final response = await post('/payment/create-intent', {
      'ticketIds': ticketIds,
    });

    _logger.i("Payment intent response: ${response.body}");
    await _handleResponse(response, 'create payment intent');
    return PaymentIntent.fromJson(response.body['data']);
  }

  Future<PaymentConfirmation> confirmPayment(String paymentIntentId) async {
    final response = await post('/payment/confirm', {
      'paymentIntentId': paymentIntentId,
    });
    await _handleResponse(response, 'confirm payment');
    return PaymentConfirmation.fromJson(response.body['data']);
  }

  // TEAMS AND ATHLETES APIs
  Future<PaginatedResponse<Team>> getTeams({int page = 1}) async {
    final response = await get('/club/teams-athletes?page=$page');
    await _handleResponse(response, 'fetch teams and athletes');
    final data = response.body['data']['teams'] as List<dynamic>;
    final pagination = Pagination.fromJson(response.body['pagination']);
    return PaginatedResponse(
      data: data.map((json) => Team.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  Future<PaginatedResponse<TeamDetails>> getTeamDetails(String teamId) async {
    final response = await get('/club/teams/$teamId/athletes');
    await _handleResponse(response, 'fetch team details');
    final data = response.body['data'] as Map<String, dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    final teamDetails = TeamDetails.fromJson(data);
    return PaginatedResponse(data: [teamDetails], pagination: pagination);
  }

  Future<PaginatedResponse<Official>> getTeamOfficials(
    String organizationId,
  ) async {
    final response = await get('/club/teams/$organizationId/officials');
    await _handleResponse(response, 'fetch team officials');
    final data = response.body['data']['officials'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data.map((json) => Official.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  // WEIGHT DIVISIONS API
  Future<PaginatedResponse<WeightDivisionParticipant>> getWeightDivisions({
    String? gender,
    String? weightCategory,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    String query = '/club/weight-divisions?page=$page&limit=$limit';

    if (gender != null && gender.isNotEmpty) {
      query += '&gender=$gender';
    }
    if (weightCategory != null && weightCategory.isNotEmpty) {
      query += '&weightCategory=$weightCategory';
    }
    if (search != null && search.isNotEmpty) {
      query += '&search=$search';
    }

    final response = await get(query);
    await _handleResponse(response, 'fetch weight divisions');
    final data = response.body['data']['participants'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data
          .map((json) => WeightDivisionParticipant.fromJson(json))
          .toList(),
      pagination: pagination,
    );
  }

  // RANDOM WEIGH INS API
  Future<PaginatedResponse<RandomWeighIn>> getRandomWeighIns({
    int page = 1,
    int limit = 10,
  }) async {
    final query = {'page': page.toString(), 'limit': limit.toString()};
    final response = await get('/random-weigh-ins', query: query);
    await _handleResponse(response, 'fetch random weigh ins');
    final data = response.body['data']['randomWeighIns'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data.map((json) => RandomWeighIn.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  // DRAW LISTS API
  Future<PaginatedResponse<DrawList>> getDrawLists({
    int page = 1,
    int limit = 10,
  }) async {
    String url = '/draw-lists?page=$page&limit=$limit';
    final response = await get(url);
    await _handleResponse(response, 'fetch draw lists');
    final data = response.body['data']['drawLists'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data.map((json) => DrawList.fromJson(json)).toList(),
      pagination: pagination,
    );
  }

  // COURTS API
  Future<List<Court>> getCourts() async {
    final response = await get('/club/courts');
    await _handleResponse(response, 'fetch courts');
    final data = response.body['data']['courts'] as List<dynamic>;
    return data.map((json) => Court.fromJson(json)).toList();
  }

  Future<CourtDetails> getCourtDetails(int mat) async {
    final response = await get('/club/courts/$mat/grouped-details');
    await _handleResponse(response, 'fetch court details');
    final courtData = response.body['data']['court'] as Map<String, dynamic>;
    return CourtDetails.fromJson(courtData);
  }

  // MOVED MATCHES API
  Future<List<MovedMatch>> getMovedMatches({String? search}) async {
    final query = <String, String>{};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    final response = await get('/club/moved-matches', query: query);
    await _handleResponse(response, 'fetch moved matches');
    final data = response.body['data']['matches'] as List<dynamic>;
    return data.map((json) => MovedMatch.fromJson(json)).toList();
  }

  // MY TICKETS API
  Future<PaginatedResponse<PurchasedTicket>> getMyTickets({
    int page = 1,
    int limit = 10,
  }) async {
    final query = {'page': page.toString(), 'limit': limit.toString()};
    final response = await get('/payment/tickets/user/history', query: query);
    await _handleResponse(response, 'fetch my tickets');
    final data = response.body['data']['tickets'] as List<dynamic>;
    final pagination = Pagination.fromJson(
      response.body['data']['pagination'] as Map<String, dynamic>,
    );
    return PaginatedResponse(
      data: data.map((json) => PurchasedTicket.fromJson(json)).toList(),
      pagination: pagination,
    );
  }
}
