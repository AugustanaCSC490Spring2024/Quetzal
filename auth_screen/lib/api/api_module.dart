import 'package:logger/logger.dart';
import 'api_client.dart';
import 'services/stock_service.dart';
import 'services/news_service.dart';
import 'services/trading_service.dart';

/// Main API module that provides access to all API services
///
/// This class follows the Singleton pattern to ensure only one instance
/// of each service exists throughout the app lifecycle.
class ApiModule {
  static final ApiModule _instance = ApiModule._internal();

  /// Get the singleton instance
  factory ApiModule() => _instance;

  // Services
  late final ApiClient _apiClient;
  late final StockService stockService;
  late final NewsService newsService;
  late final TradingService tradingService;
  late final Logger _logger;

  /// Private constructor
  ApiModule._internal() {
    _logger = Logger();
    _apiClient = ApiClient(logger: _logger);

    // Initialize services with shared client
    stockService = StockService(apiClient: _apiClient, logger: _logger);
    newsService = NewsService(apiClient: _apiClient, logger: _logger);
    tradingService = TradingService(logger: _logger);
  }

  /// Dispose of all resources
  void dispose() {
    _apiClient.dispose();
    stockService.dispose();
  }
}
