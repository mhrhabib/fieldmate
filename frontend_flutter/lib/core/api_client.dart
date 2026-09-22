import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Base URL for the FastAPI backend.
///
/// Override at build/run time so you don't have to edit code per environment:
///   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
///   flutter build web --dart-define=API_BASE_URL=https://api.yourdomain.com
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _u(String path) => Uri.parse('$apiBaseUrl$path');

  Map<String, String> get _headers => const {'Content-Type': 'application/json'};

  void _check(http.Response res) {
    if (res.statusCode >= 400) {
      throw ApiException('API error ${res.statusCode}: ${res.body}');
    }
  }

  // --- Customers -----------------------------------------------------------
  Future<List<Customer>> listCustomers() async {
    final res = await _client.get(_u('/api/customers/'));
    _check(res);
    return (jsonDecode(res.body) as List).map((e) => Customer.fromJson(e)).toList();
  }

  Future<Customer> createCustomer(Customer customer) async {
    final res = await _client.post(_u('/api/customers/'),
        headers: _headers, body: jsonEncode(customer.toJson()));
    _check(res);
    return Customer.fromJson(jsonDecode(res.body));
  }

  // --- Jobs ------------------------------------------------------------------
  Future<List<Job>> listJobs({JobStatus? status}) async {
    final uri = status == null
        ? _u('/api/jobs/')
        : _u('/api/jobs/').replace(queryParameters: {'status': status.toApi()});
    final res = await _client.get(uri);
    _check(res);
    return (jsonDecode(res.body) as List).map((e) => Job.fromJson(e)).toList();
  }

  Future<Job> createJob(Job job) async {
    final res =
        await _client.post(_u('/api/jobs/'), headers: _headers, body: jsonEncode(job.toJson()));
    _check(res);
    return Job.fromJson(jsonDecode(res.body));
  }

  Future<Job> updateJob(int jobId, Map<String, dynamic> patch) async {
    final res = await _client.patch(_u('/api/jobs/$jobId'),
        headers: _headers, body: jsonEncode(patch));
    _check(res);
    return Job.fromJson(jsonDecode(res.body));
  }

  Future<List<Job>> callbackHistory(int jobId) async {
    final res = await _client.get(_u('/api/jobs/$jobId/callback-history'));
    _check(res);
    return (jsonDecode(res.body) as List).map((e) => Job.fromJson(e)).toList();
  }

  // --- Invoices --------------------------------------------------------------
  Future<Map<String, dynamic>> createInvoice(
      int jobId, List<Map<String, dynamic>> lineItems) async {
    final res = await _client.post(
      _u('/api/invoices/'),
      headers: _headers,
      body: jsonEncode({'job_id': jobId, 'line_items': lineItems}),
    );
    _check(res);
    return jsonDecode(res.body);
  }
}
