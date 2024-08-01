import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:CurrencySwapper/cubit/state.dart';
import 'package:CurrencySwapper/cubit/cubit.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController baseCurrencyController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  bool showBaseCurrencyList = false;
  bool showCurrencyList = false;
  double? conversionResult;
  String? baseCurrencyFlag;
  String? targetCurrencyFlag;

  void selectCurrency(String code, bool isFromCurrency) {
    setState(() {
      if (isFromCurrency) {
        baseCurrencyController.text = code;
        baseCurrencyFlag = 'assets/images/${code}.png';
        showBaseCurrencyList = false;
      } else {
        currencyController.text = code;
        targetCurrencyFlag = 'assets/images/${code}.png';
        showCurrencyList = false;
      }
    });
  }

  void convertCurrency() {
    if (baseCurrencyController.text.isNotEmpty &&
        currencyController.text.isNotEmpty) {
      final currencyBloc = BlocProvider.of<CurrencyBloc>(context);
      currencyBloc.convertCurrency(
          from: baseCurrencyController.text, to: currencyController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CurrencyBloc currencyBloc = BlocProvider.of<CurrencyBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: BlocConsumer<CurrencyBloc, AppState>(listener: (context, state) {
        if (state is ConvertCurrencySuccessState) {
          setState(() {
            conversionResult = currencyBloc.result;
          });
        }
      }, builder: (context, state) {
        if (state is LoadCurrenciesFromDbLoadingState ||
            state is FetchCurrenciesLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is LoadCurrenciesFromDbErrorState ||
            state is FetchCurrenciesErrorState) {
          return Center(child: Text('Failed to load currencies'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: baseCurrencyController,
                    readOnly: true,
                    onTap: () {
                      setState(() {
                        showBaseCurrencyList = !showBaseCurrencyList;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Base Currency:',
                      border: OutlineInputBorder(),
                      labelStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      suffixIcon: baseCurrencyFlag != null
                          ? Container(
                              padding: const EdgeInsets.only(
                                  right: 16.0), // Add padding to the right
                              child: Image.asset(baseCurrencyFlag!,
                                  fit: BoxFit.contain, width: 50, height: 50),
                            )
                          : null,
                    ),
                  ),
                  if (showBaseCurrencyList)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: currencyBloc.currenciesList.length,
                      itemBuilder: (context, index) {
                        final currencyCode =
                            currencyBloc.currenciesList.keys.elementAt(index);
                        final currencyName =
                            currencyBloc.currenciesList[currencyCode]['name'];
                        return Column(
                          children: [
                            ListTile(
                              leading: Image.asset(
                                  'assets/images/${currencyCode}.png',
                                  width: 40,
                                  height: 40),
                              title: Text('$currencyName ($currencyCode)'),
                              onTap: () => selectCurrency(currencyCode, true),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  SizedBox(height: 20),
                  TextField(
                    controller: currencyController,
                    readOnly: true,
                    onTap: () {
                      setState(() {
                        showCurrencyList = !showCurrencyList;
                      });
                    },
                    decoration: InputDecoration(
                      labelStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                      suffixIcon: targetCurrencyFlag != null
                          ? Container(
                              padding: const EdgeInsets.only(
                                  right: 16.0), // Add padding to the right
                              child: Image.asset(targetCurrencyFlag!,
                                  fit: BoxFit.contain, width: 50, height: 50),
                            )
                          : null,
                    ),
                  ),
                  if (showCurrencyList)
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: currencyBloc.currenciesList.length,
                      itemBuilder: (context, index) {
                        final currencyCode =
                            currencyBloc.currenciesList.keys.elementAt(index);
                        final currencyName =
                            currencyBloc.currenciesList[currencyCode]['name'];
                        return Column(
                          children: [
                            ListTile(
                              leading: Image.asset(
                                  'assets/images/${currencyCode}.png',
                                  width: 40,
                                  height: 40),
                              title: Text('$currencyName ($currencyCode)'),
                              onTap: () => selectCurrency(currencyCode, false),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: convertCurrency,
                    child: Text('Convert'),
                  ),
                  if (conversionResult != null)
                    Card(
                      margin: const EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if (targetCurrencyFlag != null)
                              Image.asset(targetCurrencyFlag!,
                                  width: 50, height: 50),
                            SizedBox(width: 8),
                            Text(
                              'Result: $conversionResult ${currencyController.text}',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}
