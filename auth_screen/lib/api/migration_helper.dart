import 'package:auth_screen/api/api_module.dart';
import 'package:auth_screen/services/stock_price_service.dart';
import 'package:auth_screen/services/stock_data_service.dart';
import 'package:auth_screen/services/trading_service.dart' as old_trading;
import 'package:auth_screen/api_service.dart';
import 'package:logger/logger.dart';

/// Helper class to assist with migration from old services to new API structure
/// This can be removed once the migration is complete
class MigrationHelper {
  static final ApiModule api = ApiModule();
  static final Logger _logger = Logger();

  /// Provides backwards compatibility for old StockPriceService
  static StockPriceService getStockPriceService() {
    _logger.w(
        'Using deprecated StockPriceService. Use ApiModule().stockService instead.');
    return StockPriceService();
  }

  /// Provides backwards compatibility for old StockDataService
  static StockDataService getStockDataService() {
    _logger.w(
        'Using deprecated StockDataService. Use ApiModule().stockService instead.');
    return StockDataService();
  }

  /// Provides backwards compatibility for old TradingService
  static old_trading.TradingService getTradingService() {
    _logger.w(
        'Using deprecated TradingService. Use ApiModule().tradingService instead.');
    return old_trading.TradingService();
  }

  /// Provides backwards compatibility for old ApiService
  static Future<List<Map<String, String>>> fetchTickerNews(
      String symbol) async {
    _logger.w(
        'Using deprecated ApiService.fetchTickerNews. Use ApiModule().newsService.fetchNews instead.');
    return await ApiService.fetchTickerNews(symbol);
  }
}
