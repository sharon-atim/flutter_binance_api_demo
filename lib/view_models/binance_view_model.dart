import 'dart:async';
import 'dart:convert';

import 'package:flutter_binance_crypto_api_demo/model/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final binanceViewModelProvider =
    FutureProvider<List<BinanceModel>>((ref) async {
  final binanceViewModel = BinanceViewModel();
  return await ref.watch(binanceViewModel
      as AlwaysAliveProviderListenable<FutureOr<List<BinanceModel>>>);
});

class BinanceViewModel extends AsyncNotifier<List<BinanceModel>> {
  final List<BinanceModel> _binanceList = [];
  List<BinanceModel> get binanceData => _binanceList;

  BinanceModel operator [](int index) => _binanceList[index];

  @override
  FutureOr<List<BinanceModel>> build() {
    return getBinanceData();
  }

  Future<List<BinanceModel>> getBinanceData() async {
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
        return _binanceList;
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
