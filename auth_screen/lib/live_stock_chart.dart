// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';

// class LiveStockChart extends StatefulWidget {
//   final String ticker;
//   final double userStockPrice;
 
//   const LiveStockChart({
//     required this.ticker,
//     required this.userStockPrice,
//   });

//   @override
//   _LiveStockChartState createState() => _LiveStockChartState();
// }

// class _LiveStockChartState extends State<LiveStockChart> {
//   List<FlSpot> _spots = [];
//   bool _isLoading = true;
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchStockData();
//     _timer = Timer.periodic(Duration(seconds: 30), (timer) {
//       _fetchStockData();
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   Future<void> _fetchStockData() async {
//     try {
//       final List<FlSpot> fetchedSpots = await fetchLiveData(widget.ticker);
//       setState(() {
//         _spots = fetchedSpots;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching stock data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 300, // Set a fixed height to avoid layout issues
//       padding: EdgeInsets.all(16), // Add padding to prevent cut-off
//       child: _isLoading
//           ? const CircularProgressIndicator()
//           : LineChart(
//               LineChartData(
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: _spots,
//                     isCurved: true,
//                     color: Colors.blue,
//                     barWidth: 2,
//                     belowBarData: BarAreaData(show: false),
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, barData, index) =>
//                           FlDotCirclePainter(
//                         radius: 3,
//                         color: Colors.red,
//                         strokeWidth: 2,
//                         strokeColor: Colors.red,
//                       ),
//                     ),
//                   ),
//                   LineChartBarData(
//                     spots: [
//                       FlSpot(
//                         _spots.isNotEmpty ? _spots.last.x : 0,
//                         widget.userStockPrice,
//                       ),
//                     ],
//                     isCurved: false,
//                     color: Colors.green,
//                     barWidth: 2,
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, barData, index) =>
//                           FlDotCirclePainter(
//                         radius: 5,
//                         color: Colors.green,
//                         strokeWidth: 2,
//                         strokeColor: Colors.green,
//                       ),
//                     ),
//                   ),
//                 ],
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//                   ),
//                 ),
//                 gridData: FlGridData(show: true),
//               ),
//             ),
//     );
//   }
// }

// Future<List<FlSpot>> fetchLiveData(String ticker) async {
//   const apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
//   final url = 'https://api.polygon.io/v2/aggs/ticker/$ticker/prev?apiKey=$apiKey';

//   try {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       List<FlSpot> spots = [];

//       if (jsonData['results'] != null) {
//         for (var data in jsonData['results']) {
//           final time = data['t']; // Replace with actual time field if different
//           final value = data['c']; // Replace with actual close price field if different
//           if (time is num && value is num) {
//             spots.add(FlSpot(time.toDouble(), value.toDouble()));
//           }
//         }
//       } else {
//         print('No results found in the response');
//       }

//       return spots;
//     } else {
//       print('Failed to load data. Status code: ${response.statusCode}');
//       throw Exception('Failed to load live data');
//     }
//   } catch (e) {
//     print('Error fetching live data: $e');
//     throw Exception('Error fetching live data');
//   }
// }


///////////////////////////////////////////////////////////////////// THIS WORKS BELOW /////////////////////
// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';

// class LiveStockChart extends StatefulWidget {
//   final String ticker;
//   final double userStockPrice;

//   const LiveStockChart({
//     required this.ticker,
//     required this.userStockPrice,
//   });

//   @override
//   _LiveStockChartState createState() => _LiveStockChartState();
// }

// class _LiveStockChartState extends State<LiveStockChart> {
//   List<FlSpot> _spots = [];
//   bool _isLoading = true;
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchStockData();
//     _timer = Timer.periodic(Duration(seconds: 30), (timer) {
//       _fetchStockData();
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   Future<void> _fetchStockData() async {
//     try {
//       final List<FlSpot> fetchedSpots = await fetchLiveData(widget.ticker);
//       setState(() {
//         _spots = fetchedSpots;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching stock data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 300, // Set a fixed height to avoid layout issues
//       padding: EdgeInsets.all(16), // Add padding to prevent cut-off
//       child: _isLoading
//           ? const CircularProgressIndicator()
//           : LineChart(
//               LineChartData(
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: _spots,
//                     isCurved: true,
//                     color: Colors.blue,
//                     barWidth: 2,
//                     belowBarData: BarAreaData(show: false),
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, barData, index) =>
//                           FlDotCirclePainter(
//                         radius: 3,
//                         color: Colors.red,
//                         strokeWidth: 2,
//                         strokeColor: Colors.red,
//                       ),
//                     ),
//                   ),
//                   LineChartBarData(
//                     spots: [
//                       FlSpot(
//                         _spots.isNotEmpty ? _spots.last.x : 0,
//                         widget.userStockPrice,
//                       ),
//                     ],
//                     isCurved: false,
//                     color: Colors.green,
//                     barWidth: 2,
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, barData, index) =>
//                           FlDotCirclePainter(
//                         radius: 5,
//                         color: Colors.green,
//                         strokeWidth: 2,
//                         strokeColor: Colors.green,
//                       ),
//                     ),
//                   ),
//                 ],
//                 titlesData: FlTitlesData( 
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 60,
//                       getTitlesWidget: (value, meta) {
//                         String text;
//                         if (value >= 1000) {
//                           text = (value / 1000).toStringAsFixed(1) + 'K';
//                         } else {
//                           text = value.toString();
//                         } 
//                         return Text( 
//                           text, 
//                           style: TextStyle(
//                             fontSize: 10,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 40,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           value.toStringAsFixed(1),
//                           style: TextStyle(
//                             fontSize: 10,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 gridData: FlGridData(show: true),
//               ),
//             ),
//     );
//   }
// }

// Future<List<FlSpot>> fetchLiveData(String ticker) async {
//   const apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
//   final url = 'https://api.polygon.io/v2/aggs/ticker/$ticker/prev?apiKey=$apiKey';

//   try {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       List<FlSpot> spots = [];

//       if (jsonData['results'] != null) {
//         for (var data in jsonData['results']) {
//           final time = data['t']; // Replace with actual time field if different
//           final value = data['c']; // Replace with actual close price field if different
//           if (time is num && value is num) {
//             spots.add(FlSpot(time.toDouble(), value.toDouble()));
//           }
//         }
//       } else {
//         print('No results found in the response');
//       }

//       return spots;
//     } else {
//       print('Failed to load data. Status code: ${response.statusCode}');
//       throw Exception('Failed to load live data');
//     }
//   } catch (e) {
//     print('Error fetching live data: $e');
//     throw Exception('Error fetching live data');
//   }
// }

////////////////////////////////////////////////////////////////////////



import 'dart:convert';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveStockChart extends StatefulWidget {
  final String ticker;
  final double userStockPrice;

  const LiveStockChart({
    required this.ticker,
    required this.userStockPrice,
  });

  @override
  _LiveStockChartState createState() => _LiveStockChartState();
}

class _LiveStockChartState extends State<LiveStockChart> {
  List<FlSpot> _spots = [];
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchStockData();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchStockData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchStockData() async {
    try {
      final List<FlSpot> fetchedSpots = await fetchLiveData(widget.ticker);
      setState(() {
        _spots = fetchedSpots;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Container(
      height: 300, // Set a fixed height to avoid layout issues
      padding: EdgeInsets.all(16), // Add padding to prevent cut-off
      child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              children: [
                Text(
                  widget.ticker,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: Colors.red,
                              strokeWidth: 2,
                              strokeColor: Colors.red,
                            ),
                          ),
                        ),
                        LineChartBarData(
                          spots: [
                            if (_spots.isNotEmpty)
                              FlSpot(
                                _spots.last.x,
                                widget.userStockPrice,
                              ),
                          ],
                          isCurved: false,
                          color: Colors.green,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 5,
                              color: Colors.green,
                              strokeWidth: 2,
                              strokeColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              final DateTime date =
                                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
                              return Text(
                                _formatTime(date),
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
                Text(
                  'Date: ${_formatDate(now)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}

Future<List<FlSpot>> fetchLiveData(String ticker) async {
  const apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
  final url = 'https://api.polygon.io/v2/aggs/ticker/$ticker/prev?apiKey=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<FlSpot> spots = [];

      if (jsonData['results'] != null) {
        for (var data in jsonData['results']) {
          final time = data['t'];
          final value = data['c'];
          if (time is num && value is num) {
            spots.add(FlSpot(time.toDouble(), value.toDouble())); 
          }
        }
      } else {
        print('No results found in the response');
      }

      return spots;
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      throw Exception('Failed to load live data');
    }
  } catch (e) {
    print('Error fetching live data: $e');
    throw Exception('Error fetching live data');
  }
}
