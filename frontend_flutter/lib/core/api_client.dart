import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Base URL for the FastAPI backend.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiAuthResponse {
  final User user;
  final String token;
  ApiAuthResponse({required this.user, required this.token});
}

class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Uri _u(String path) => Uri.parse('$apiBaseUrl$path');

  Map<String, String> get _headers {
    final map = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null && _authToken!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_authToken';
    }
    return map;
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) {
      String errorMessage = 'API error ${res.statusCode}';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        } else if (res.body.isNotEmpty) {
          errorMessage = res.body;
        }
      } catch (_) {
        if (res.body.isNotEmpty) {
          errorMessage = res.body;
        }
      }
      throw ApiException(errorMessage, statusCode: res.statusCode);
    }
  }

  // --- Auth -----------------------------------------------------------------
  Future<ApiAuthResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      _u('/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    _check(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final user = User.fromJson(data['user']);
    final token = data['token'] as String;
    setAuthToken(token);
    return ApiAuthResponse(user: user, token: token);
  }

  Future<ApiAuthResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      _u('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    _check(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final user = User.fromJson(data['user']);
    final token = data['token'] as String;
    setAuthToken(token);
    return ApiAuthResponse(user: user, token: token);
  }

  Future<User> getMe(String token) async {
    final res = await _client.get(
      _u('/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _check(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    setAuthToken(token);
    return User.fromJson(data);
  }

  // --- Customers -----------------------------------------------------------
  Future<List<Customer>> listCustomers() async {
    final res = await _client.get(_u('/api/customers'), headers: _headers);
    _check(res);
    return (jsonDecode(res.body) as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<Customer> createCustomer(Customer customer) async {
    final res = await _client.post(
      _u('/api/customers'),
      headers: _headers,
      body: jsonEncode(customer.toJson()),
    );
    _check(res);
    return Customer.fromJson(jsonDecode(res.body));
  }

  // --- Jobs ------------------------------------------------------------------
  Future<List<Job>> listJobs({JobStatus? status}) async {
    final uri = status == null
        ? _u('/api/jobs')
        : _u('/api/jobs').replace(queryParameters: {'status': status.toApi()});
    final res = await _client.get(uri, headers: _headers);
    _check(res);
    return (jsonDecode(res.body) as List).map((e) => Job.fromJson(e)).toList();
  }

  Future<Job> createJob(Job job) async {
    final res = await _client.post(
      _u('/api/jobs'),
      headers: _headers,
      body: jsonEncode(job.toJson()),
    );
    _check(res);
    return Job.fromJson(jsonDecode(res.body));
  }

  Future<Job> updateJob(int jobId, Map<String, dynamic> patch) async {
    final res = await _client.patch(
      _u('/api/jobs/$jobId'),
      headers: _headers,
      body: jsonEncode(patch),
    );
    _check(res);
    return Job.fromJson(jsonDecode(res.body));
  }

  Future<List<Job>> callbackHistory(int jobId) async {
    final res = await _client.get(_u('/api/jobs/$jobId/callback-history'), headers: _headers);
    _check(res);
    return (jsonDecode(res.body) as List).map((e) => Job.fromJson(e)).toList();
  }

  // --- Invoices --------------------------------------------------------------
  Future<Map<String, dynamic>> createInvoice(
      int jobId, List<Map<String, dynamic>> lineItems) async {
    final res = await _client.post(
      _u('/api/invoices'),
      headers: _headers,
      body: jsonEncode({'job_id': jobId, 'line_items': lineItems}),
    );
    _check(res);
    return jsonDecode(res.body);
  }
}
