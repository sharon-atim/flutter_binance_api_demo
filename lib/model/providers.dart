import 'dart:async';

import 'package:flutter_binance_crypto_api_demo/model/model.dart';
import 'package:flutter_binance_crypto_api_demo/view_models/binance_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final binanceViewModelProvider =
    FutureProvider<List<BinanceModel>>((ref) async {
  final binanceViewModel = BinanceViewModel();
  return await ref.watch(binanceViewModel.getBinanceData()
      as AlwaysAliveProviderListenable<FutureOr<List<BinanceModel>>>);
});
