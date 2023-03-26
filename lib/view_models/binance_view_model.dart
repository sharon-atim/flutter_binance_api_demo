

import 'package:flutter/material.dart';
import 'package:flutter_binance_crypto_api_demo/models/model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BinanceViewModel with ChangeNotifier {
  final List<BinanceModel> _binanceList = [];
  bool _isLoading = false;
  List<BinanceModel> get binanceList => _binanceList;
  bool get isLoading => _isLoading;

  Future<List<BinanceModel>> getBinanceData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://data.binance.com/api/v3/ticker/24hr'));
      List<dynamic> binanceDataJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var symbol in binanceDataJson) {
          BinanceModel binanceData = BinanceModel.fromJson(symbol);
          _binanceList.add(binanceData);
          _binanceList.sort(
            (a, b) => a.symbol.compareTo(b.symbol),
          );
        }
        _isLoading = false;
        notifyListeners();
        return _binanceList;
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e);
    }
  }
}
