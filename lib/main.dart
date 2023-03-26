import 'package:flutter/material.dart';
import 'package:flutter_binance_crypto_api_demo/models/model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Flutter Binance API'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _getData = BinanceViewModel().getBinanceData();

  @override
  void initState() {
    super.initState();
    _getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.yellowAccent.shade700,
      ),
      body: Center(
          child: FutureBuilder<List<BinanceModel>>(
        future: _getData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<BinanceModel>? binanceData = snapshot.data;
            return ListView.builder(
              itemCount: binanceData != null ? binanceData.length : 0,
              itemBuilder: (context, index) {
                final priceChangePercent =
                    binanceData?[index].priceChangePercent.toString();
                final parsePriceChangePercent =
                    double.parse(priceChangePercent!);
                final symbolLastPrice = binanceData![index].lastPrice;
                double symbolLastPriceParsed = double.parse(symbolLastPrice);

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
                                color: parsePriceChangePercent > -0.1
                                    ? Colors.green
                                    : Colors.red),
                          ),
                          Text(
                            '£ ${symbolLastPriceParsed.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
              },
            );
          }
          return CircularProgressIndicator(
            color: Colors.yellowAccent.shade700,
          );
        },
      )),
    );
  }
}
