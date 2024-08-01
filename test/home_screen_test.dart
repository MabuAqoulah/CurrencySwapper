import 'package:CurrencySwapper/cubit/state.dart';
import 'package:CurrencySwapper/cubit/cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([Dio, DatabaseHelper, Database])
void main() {
  late CurrencyBloc currencyBloc;
  late MockDio mockDio;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDio = MockDio();
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();

    when(mockDatabaseHelper.getDatabase).thenAnswer((_) async => mockDatabase);

    currencyBloc = CurrencyBloc()
      ..dio = mockDio
      ..dbHelper = mockDatabaseHelper;
  });

  group('CurrencyBloc', () {
    test('initial state is InitialState', () {
      expect(currencyBloc.state, InitialState());
    });

    group('fetchCurrencies', () {
      final responseData = {
        'data': {
          'USD': {'name': 'United States Dollar'},
          'EUR': {'name': 'Euro'}
        }
      };

      setUp(() {
        when(mockDio.get(any)).thenAnswer(
              (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);
      });

      test('emits FetchCurrenciesLoadingState and FetchCurrenciesSuccessState on successful fetch', () async {
        final expectedStates = [
          FetchCurrenciesLoadingState(),
          FetchCurrenciesSuccessState(),
        ];

        expectLater(currencyBloc.stream, emitsInOrder(expectedStates));

        await currencyBloc.fetchCurrencies();
      });

      test('stores fetched currencies in the database', () async {
        await currencyBloc.fetchCurrencies();

        verify(mockDatabase.insert('currencies', {'code': 'USD', 'name': 'United States Dollar'})).called(1);
        verify(mockDatabase.insert('currencies', {'code': 'EUR', 'name': 'Euro'})).called(1);
      });

      test('emits FetchCurrenciesErrorState on fetch failure', () async {
        when(mockDio.get(any)).thenThrow(DioError(
          requestOptions: RequestOptions(path: ''),
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
        ));

        final expectedStates = [
          FetchCurrenciesLoadingState(),
          FetchCurrenciesErrorState('DioError [DioErrorType.response]: Http status error [404]'),
        ];

        expectLater(currencyBloc.stream, emitsInOrder(expectedStates));

        await currencyBloc.fetchCurrencies();
      });
    });

    group('loadCurrenciesFromDb', () {
      final dbCurrencies = [
        {'code': 'USD', 'name': 'United States Dollar'},
        {'code': 'EUR', 'name': 'Euro'}
      ];

      setUp(() {
        when(mockDatabase.query('currencies')).thenAnswer((_) async => dbCurrencies);
      });

      test('emits LoadCurrenciesFromDbLoadingState and LoadCurrenciesFromDbSuccessState on successful load', () async {
        final expectedStates = [
          LoadCurrenciesFromDbLoadingState(),
          LoadCurrenciesFromDbSuccessState(),
        ];

        expectLater(currencyBloc.stream, emitsInOrder(expectedStates));

        await currencyBloc.loadCurrenciesFromDb();
      });

      test('fetches currencies from the database and updates currenciesList', () async {
        await currencyBloc.loadCurrenciesFromDb();

        expect(currencyBloc.currenciesList, {
          'USD': {'name': 'United States Dollar'},
          'EUR': {'name': 'Euro'}
        });
      });

      test('fetches currencies from the API if the database is empty', () async {
        when(mockDatabase.query('currencies')).thenAnswer((_) async => []);

        final expectedStates = [
          LoadCurrenciesFromDbLoadingState(),
          FetchCurrenciesLoadingState(),
          FetchCurrenciesSuccessState(),
        ];

        expectLater(currencyBloc.stream, emitsInOrder(expectedStates));

        await currencyBloc.loadCurrenciesFromDb();
      });

      test('emits LoadCurrenciesFromDbErrorState on load failure', () async {
        when(mockDatabase.query('currencies')).thenThrow(Exception('Database error'));

        final expectedStates = [
          LoadCurrenciesFromDbLoadingState(),
          LoadCurrenciesFromDbErrorState('Exception: Database error'),
        ];

        expectLater(currencyBloc.stream, emitsInOrder(expectedStates));

        await currencyBloc.loadCurrenciesFromDb();
      });
    });

    group('convertCurrency', () {
      final responseData = {
        'data': {'EUR': 0.85}
      };

      setUp(() {
        when(mockDio.get(any)).thenAnswer(
              (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      });

      test('emits ConvertCurrencyLoadingState and ConvertCurrencySuccessState on successful conversion', () async {
        final expectedStates = [
          ConvertCurrencyLoadingState(),
          ConvertCurrencySuccessState(),
        ];

        expectLater(currencyBloc.stream, emitsInOrder(expectedStates));

        await currencyBloc.convertCurrency(from: 'USD', to: 'EUR');
      });

      test('sets result on successful conversion', () async {
        await currencyBloc.convertCurrency(from: 'USD', to: 'EUR');

        expect(currencyBloc.result, 0.85);
      });

      test('emits ConvertCurrencyErrorState on conversion failure', () async {
        when(mockDio.get(any)).thenThrow(DioError(
          requestOptions: RequestOptions(path: ''),
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
        ));

        final expectedStates = [
          ConvertCurrencyLoadingState(),
          ConvertCurrencyErrorState('DioError [DioErrorType.response]: Http status error [404]'),
        ];

        expectLater(currencyBloc.stream, emitsInOrder(expectedStates));

        await currencyBloc.convertCurrency(from: 'USD', to: 'EUR');
      });
    });
  });
}
