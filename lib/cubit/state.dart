abstract class AppState {}

class InitialState extends AppState {}

class FetchCurrenciesLoadingState extends AppState {}

class FetchCurrenciesSuccessState extends AppState {}

class FetchCurrenciesErrorState extends AppState {
  FetchCurrenciesErrorState(String e);
}

class LoadCurrenciesFromDbLoadingState extends AppState {}

class LoadCurrenciesFromDbSuccessState extends AppState {}

class LoadCurrenciesFromDbErrorState extends AppState {
  LoadCurrenciesFromDbErrorState(String e);
}

class ConvertCurrencyLoadingState extends AppState {}

class ConvertCurrencySuccessState extends AppState {}

class ConvertCurrencyErrorState extends AppState {
  ConvertCurrencyErrorState(String e);
}

