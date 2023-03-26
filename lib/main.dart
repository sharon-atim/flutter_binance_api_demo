import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_binance_crypto_api_demo/model/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Flutter Binance API',
      ),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Flutter Binance API',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellowAccent.shade700,
        ),
        body: Consumer(
          builder: (context, ref, _) {
            final binanceData = ref.watch(binanceViewModelProvider);

            return binanceData.when(
              data: (binanceData) => ListView.builder(
                key: UniqueKey(),
                itemBuilder: (context, index) {
                  final symbolData = binanceData[index];
                  final priceChangePercent =
                      double.parse(symbolData.priceChangePercent);
                  final symbolLastPriceParsed =
                      double.parse(symbolData.lastPrice);

                  return Card(
                    child: ListTile(
                      title: Text(
                        binanceData[index].symbol,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                binanceData[index].priceChangePercent,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: priceChangePercent > -0.1
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                '£ ${symbolLastPriceParsed.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text('Error: $error'),
            );
          },
        ));
  }
}

final binanceViewModelProvider = FutureProvider<BinanceViewModel>((ref) async {
  final binanceViewModel = BinanceViewModel();
  await binanceViewModel.getBinanceData();
  binanceViewModel.startTimer();
  return binanceViewModel;
});

class BinanceViewModel extends ChangeNotifier {
  final List<BinanceModel> _binanceList = [];
  List<BinanceModel> get binanceData => _binanceList;
  BinanceModel operator [](int index) => _binanceList[index];

  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await getBinanceData();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Future<void> getBinanceData() async {
    try {
      final response = await http
          .get(Uri.parse('https://data.binance.com/api/v3/ticker/24hr'));
      List<dynamic> binanceDataJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var symbol in binanceDataJson) {
          BinanceModel binanceData = BinanceModel.fromJson(symbol);
          _binanceList.add(binanceData);
        }
        _binanceList.sort((a, b) => a.symbol.compareTo(b.symbol));
        notifyListeners();
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }
}
