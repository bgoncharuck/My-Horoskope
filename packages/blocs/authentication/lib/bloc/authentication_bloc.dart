import 'dart:async';

import 'package:authentication/bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:auth/auth.dart';
import 'package:user_model/user_model.dart';
import 'package:users_repository/users_repository.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';
export 'authentication_event.dart';
export 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  @override
  AuthenticationState get initialState => Uninitialized();
  final Auth auth;

  AuthenticationBloc({@required Auth this.auth});

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is AuthEvent) {
      yield* _mapAuthEventToState(
        event.model,
        event.internalStrIsEnabled,
        event.moodletIsEnabled,
        event.ambitionIsEnabled,
        event.intelligenceIsEnabled,
        event.luckIsEnabled,
      );
    }
  }

  /// tries to use initializing methods
  /// from auth data controller
  /// on the app start
  /// if authenticated user was found
  /// return state Authenticated
  /// return Unauthenticated otherwise
  Stream<AuthenticationState> _mapAppStartedToState() async* {
    /// if some user isn't already authenticated
    if (!await auth.isAuthenticated) {
      //
      /// auth initilization methods are used here
      final user = await auth.initialize;

      /// if authd user is found/not found
      if (user == null)
        yield Unauthenticated();
      else {
        /// must print user data from Transition
        yield Authenticated(user);
      }
    } else {
      yield Authenticated(auth.curUser);
    }
  }

  Stream<AuthenticationState> _mapAuthEventToState(
    UserModel model,
    bool internalStrIsEnabled,
    bool moodletIsEnabled,
    bool ambitionIsEnabled,
    bool intelligenceIsEnabled,
    bool luckIsEnabled,
  ) async* {
    /// use auth authentication methods
    /// to login with given user model
    /// or create new Entity from it
    UserEntity user;
    try {
      user = await auth.authenticate(
        model,
        intelligenceIsEnabled: intelligenceIsEnabled,
        moodletIsEnabled: moodletIsEnabled,
        ambitionIsEnabled: ambitionIsEnabled,
        internalStrIsEnabled: intelligenceIsEnabled,
        luckIsEnabled: luckIsEnabled,
      );
    } catch (_) {
      print("Error was catched: $_");
    }

    if (user == null)

      /// on any error user will be equal null
      yield Unauthenticated();
    else {
      yield Authenticated(user);
    }
  }
}
