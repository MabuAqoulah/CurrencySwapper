import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_observer.dart';
import 'cubit/cubit.dart';
import 'cubit/state.dart';
import 'module/home.dart';

void main() {
  runApp(const MyApp());
  Bloc.observer = AppBlocObserver();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => CurrencyBloc()
            ..fetchCurrencies()
            ..loadCurrenciesFromDb(),
        ),
      ],
      child: BlocBuilder<CurrencyBloc, AppState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              primarySwatch: Colors.teal,
            ),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
