import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ConnectivityEvent {}
class CheckConnectivity extends ConnectivityEvent {}
class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityResult result;
  ConnectivityChanged(this.result);
}

// States
abstract class ConnectivityState {}
class ConnectivityInitial extends ConnectivityState {}
class ConnectivityOnline extends ConnectivityState {}
class ConnectivityOffline extends ConnectivityState {}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity connectivity;
  StreamSubscription? connectivitySubscription;

  ConnectivityBloc(this.connectivity) : super(ConnectivityInitial()) {
    on<CheckConnectivity>((event, emit) async {
      final result = await connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        emit(ConnectivityOnline());
      } else {
        emit(ConnectivityOffline());
      }
    });

    on<ConnectivityChanged>((event, emit) {
      if (event.result != ConnectivityResult.none) {
        emit(ConnectivityOnline());
      } else {
        emit(ConnectivityOffline());
      }
    });

    // Listen to connectivity changes
    connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (result) => add(ConnectivityChanged(result as ConnectivityResult)),
    );
  }

  @override
  Future<void> close() {
    connectivitySubscription?.cancel();
    return super.close();
  }
}
