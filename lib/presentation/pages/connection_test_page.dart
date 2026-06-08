import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';

/// Test page to verify backend-frontend connectivity
class ConnectionTestPage extends StatefulWidget {
  const ConnectionTestPage({super.key});

  @override
  State<ConnectionTestPage> createState() => _ConnectionTestPageState();
}

class _ConnectionTestPageState extends State<ConnectionTestPage> {
  final List<TestResult> _testResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runAllTests();
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    await _testConnectionConfig();
    await _testHealthCheck();
    await _testDoctorsEndpoint();
    await _testApiConfig();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testConnectionConfig() async {
    try {
      final result = TestResult(
        name: '📋 API Configuration',
        timestamp: DateTime.now(),
      );

      final details = {
        'Environment': ApiConfig.currentEnvironment.toString().split('.').last,
        'Base URL': ApiConfig.baseUrl,
        'API Base URL': ApiConfig.apiBaseUrl,
        'Connection Timeout': '${ApiConfig.connectionTimeout.inSeconds}s',
        'Read Timeout': '${ApiConfig.readTimeout.inSeconds}s',
        'Write Timeout': '${ApiConfig.writeTimeout.inSeconds}s',
        'Development': ApiConfig.isDevelopment,
        'Logging Enabled': ApiConfig.enableLogging,
      };

      result.status = 'success';
      result.data = details;
      result.message = 'Configuration loaded successfully';

      setState(() {
        _testResults.add(result);
      });
    } catch (e) {
      _addError('📋 API Configuration', e);
    }
  }

  Future<void> _testHealthCheck() async {
    try {
      final result = TestResult(
        name: '🏥 Backend Health Check',
        timestamp: DateTime.now(),
      );

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.get('/health');

      result.status = 'success';
      result.statusCode = response.statusCode;
      result.data = response.data;
      result.message = 'Backend is healthy';

      setState(() {
        _testResults.add(result);
      });
    } catch (e) {
      _addError('🏥 Backend Health Check', e);
    }
  }

  Future<void> _testDoctorsEndpoint() async {
    try {
      final result = TestResult(
        name: '👨‍⚕️ Doctors Endpoint',
        timestamp: DateTime.now(),
      );

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.get(
        ApiConfig.doctorsEndpoint,
        queryParameters: {'page': 1, 'page_size': 5},
      );

      result.status = 'success';
      result.statusCode = response.statusCode;
      final items = response.data['items'] as List?;
      // final sampleDoctor = (items != null && items.isNotEmpty)
      //     ? items[0]['user']?['first_name'] ?? 'N/A'
      //     : 'None';
      
      result.data = {
        'Total doctors': response.data['total'] ?? 0,
        'Returned items': items?.length ?? 0,
        // 'Sample doctor': sampleDoctor,
      };
      result.message = 'Successfully fetched doctors';

      setState(() {
        _testResults.add(result);
      });
    } catch (e) {
      _addError('👨‍⚕️ Doctors Endpoint', e);
    }
  }

  Future<void> _testApiConfig() async {
    try {
      final result = TestResult(
        name: '⚙️ API Endpoints',
        timestamp: DateTime.now(),
      );

      final endpoints = {
        'Login': ApiConfig.loginEndpoint,
        'Register': ApiConfig.registerEndpoint,
        'Refresh': ApiConfig.refreshEndpoint,
        'Logout': ApiConfig.logoutEndpoint,
        'My Profile': ApiConfig.userProfileEndpoint,
        'Doctors': ApiConfig.doctorsEndpoint,
        'Top Rated': ApiConfig.topRatedDoctorsEndpoint,
        'Appointments': ApiConfig.appointmentsEndpoint,
        'My Appointments': ApiConfig.myAppointmentsEndpoint,
        'Check Availability': ApiConfig.checkAvailabilityEndpoint,
      };

      result.status = 'success';
      result.data = endpoints;
      result.message = 'All endpoints configured';

      setState(() {
        _testResults.add(result);
      });
    } catch (e) {
      _addError('⚙️ API Endpoints', e);
    }
  }

  void _addError(String testName, dynamic error) {
    final errorMessage = error is DioException
        ? 'DioException: ${error.message}\nType: ${error.type}'
        : error.toString();

    final result = TestResult(
      name: testName,
      timestamp: DateTime.now(),
      status: 'error',
      message: errorMessage,
    );

    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔗 Backend Connection Test'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runAllTests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                final isSuccess = result.status == 'success';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                result.message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isSuccess
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (result.statusCode != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Status Code: ${result.statusCode}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (result.data != null)
                              SizedBox(
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _formatData(result.data),
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Time: ${result.timestamp.toLocal()}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _runAllTests,
        tooltip: 'Run all tests',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  String _formatData(dynamic data) {
    if (data is Map) {
      final buffer = StringBuffer();
      data.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
      return buffer.toString();
    }
    return data.toString();
  }
}

class TestResult {
  final String name;
  final DateTime timestamp;
  late String status; // 'success' or 'error'
  late String message;
  int? statusCode;
  dynamic data;

  TestResult({
    required this.name,
    required this.timestamp,
    this.status = 'pending',
    this.message = '',
  });
}
