import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:CurrencySwapper/cubit/state.dart';
import 'package:dio/dio.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper.init();

  static Database? database;

  DatabaseHelper.init();

  Future<Database> get getDatabase async {
    if (database != null) return database!;

    database = await initDB('currencies.db');
    return database!;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: createDB);
  }

  Future createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE currencies (
      id $idType,
      code $textType,
      name $textType
    )
    ''');
  }

  Future<void> insertCurrency(Map<String, dynamic> currency) async {
    final db = await instance.getDatabase;

    await db.insert('currencies', currency);
  }

  Future<List<Map<String, dynamic>>> getCurrencies() async {
    final db = await instance.getDatabase;

    final result = await db.query('currencies');
    return result;
  }
}

class CurrencyBloc extends Cubit<AppState> {
  CurrencyBloc() : super(InitialState());

  static CurrencyBloc get(context) => BlocProvider.of(context);

  final String fetchApiUrl =
      'https://api.freecurrencyapi.com/v1/currencies?apikey=fca_live_f0xPPxtMIsuUwf7NQ4tCBXYLiEozRh7tv9xRKwlV&currencies=EUR%2CUSD%2CCAD&base_currency=USD';
  late Dio dio = Dio();
  late DatabaseHelper dbHelper = DatabaseHelper.instance;

  Map<String, dynamic> currenciesList = {};

  Future<void> fetchCurrencies() async {
    try {
      emit(FetchCurrenciesLoadingState());
      final response = await dio.get(fetchApiUrl);
      currenciesList = response.data['data'];
      //print(curs);
      currenciesList.forEach((code, details) async {
        await dbHelper.insertCurrency({'code': code, 'name': details['name']});
      });

      emit(FetchCurrenciesSuccessState());
    } on DioError catch (e) {
      emit(FetchCurrenciesErrorState(e.toString()));
      throw Exception('Failed to load currencies: ${e.response?.data}');
    }
  }

  Future<void> loadCurrenciesFromDb() async {
    try {
      emit(LoadCurrenciesFromDbLoadingState());
      final dbCurrencies = await dbHelper.getCurrencies();
      if (dbCurrencies.isNotEmpty) {
        currenciesList = {
          for (var currency in dbCurrencies)
            currency['code']: {'name': currency['name']}
        };
        print(currenciesList);
        emit(LoadCurrenciesFromDbSuccessState());
      } else {
        await fetchCurrencies();
      }
    } catch (e) {
      emit(LoadCurrenciesFromDbErrorState(e.toString()));
      throw Exception('Failed to load currencies from database: $e');
    }
  }

  /*
  Api doesn't show the last Historical data for 2 currencies of your choosing for the last 7 days.
  As it onl show the date of the day before only and doesn't accept date range
  */
  // Map<String, dynamic> historicalData = {};
  // Future<void> fetchHistoricalData(
  //     {required String date, required String from, required String to}) async {
  //   try {
  //     emit(LoadingState());
  //     final response = await _dio.get(
  //         'https://api.currencyapi.com/v3/range?datetime_start=2021-11-30T23:59:59Z&datetime_end=2021-12-31T23:59:59Z&accuracy=day');
  //     historicalData = response.data;
  //     emit(SuccessState());
  //     print(historicalData);
  //   } on DioError catch (e) {
  //     emit(ErrorState(e.toString()));
  //     throw Exception('Failed to load historical data: ${e.response?.data}');
  //   }
  // }

  double result = 0.0;
  Future<void> convertCurrency(
      {required String from, required String to}) async {
    try {
      emit(ConvertCurrencyLoadingState());
      final response = await dio.get(
          'https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_f0xPPxtMIsuUwf7NQ4tCBXYLiEozRh7tv9xRKwlV&currencies=$to&base_currency=$from');
      result = response.data["data"][to];
      print(result);
      emit(ConvertCurrencySuccessState());
    } on DioError catch (e) {
      emit(ConvertCurrencyErrorState(e.toString()));
      throw Exception('Failed to convert currency: ${e.response?.data}');
    }
  }
}
