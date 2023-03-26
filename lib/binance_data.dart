import 'package:flutter/material.dart';
import 'package:flutter_binance_crypto_api_demo/model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<BinanceModel>> getBinanceData() async {
  try {
    debugPrint('Getting binance data');
    final response = await http
        .get(Uri.parse('https://data.binance.com/api/v3/ticker/24hr'));
    List<BinanceModel> binanceList = [];
    List<dynamic> binanceDataJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      for (var symbol in binanceDataJson) {
        BinanceModel binanceData = BinanceModel.fromJson(symbol);
        binanceList.add(binanceData);
        binanceList.sort(
          (a, b) => a.symbol.compareTo(b.symbol),
        );
      }
      return binanceList;
    } else {
      throw Exception('Failed to load');
    }
  } catch (e) {
    throw Exception(e);
  }
}
