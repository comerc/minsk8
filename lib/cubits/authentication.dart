import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:minsk8/import.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit(this.authenticationRepository)
      : assert(authenticationRepository != null),
        super(const AuthenticationState.unknown()) {
    _userSubscription = authenticationRepository.user.listen(
      (UserModel user) => changeUser(user),
    );
  }

  final AuthenticationRepository authenticationRepository;
  StreamSubscription<UserModel> _userSubscription;

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  void changeUser(UserModel user) {
    final result = user == UserModel.empty
        ? const AuthenticationState.unauthenticated()
        : AuthenticationState.authenticated(user);
    emit(result);
  }

  void requestLogout() {
    authenticationRepository.logOut();
  }
}

// class AuthenticationBloc
//     extends Bloc<AuthenticationEvent, AuthenticationState> {
//   AuthenticationBloc({
//     @required AuthenticationRepository authenticationRepository,
//   })  : assert(authenticationRepository != null),
//         _authenticationRepository = authenticationRepository,
//         super(const AuthenticationState.unknown()) {
//     _userSubscription = _authenticationRepository.user.listen(
//       (user) => add(AuthenticationUserChanged(user)),
//     );
//   }

//   final AuthenticationRepository _authenticationRepository;
//   StreamSubscription<UserModel> _userSubscription;

//   @override
//   Stream<AuthenticationState> mapEventToState(
//     AuthenticationEvent event,
//   ) async* {
//     if (event is AuthenticationUserChanged) {
//       yield _mapAuthenticationUserChangedToState(event);
//     } else if (event is AuthenticationLogoutRequested) {
//       unawaited(_authenticationRepository.logOut());
//     }
//   }

//   @override
//   Future<void> close() {
//     _userSubscription?.cancel();
//     return super.close();
//   }

//   AuthenticationState _mapAuthenticationUserChangedToState(
//     AuthenticationUserChanged event,
//   ) {
//     return event.user != UserModel.empty
//         ? AuthenticationState.authenticated(event.user)
//         : const AuthenticationState.unauthenticated();
//   }
// }

// abstract class AuthenticationEvent extends Equatable {
//   const AuthenticationEvent();

//   @override
//   List<Object> get props => [];
// }

// class AuthenticationUserChanged extends AuthenticationEvent {
//   const AuthenticationUserChanged(this.user);

//   final UserModel user;

//   @override
//   List<Object> get props => [user];
// }

// class AuthenticationLogoutRequested extends AuthenticationEvent {}

enum AuthenticationStatus { authenticated, unauthenticated, unknown }

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user = UserModel.empty,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(UserModel user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final UserModel user;

  @override
  List<Object> get props => [status, user];
}
