class StockPoint {
  final double close;
  final int time;

  StockPoint({required this.close, required this.time});

  factory StockPoint.fromJson(Map<String, dynamic> json) {
    return StockPoint(
      close: json['c'].toDouble(),
      time: json['t'],
    );
  }
}
