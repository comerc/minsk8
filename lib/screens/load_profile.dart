import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minsk8/import.dart';

class LoadProfileScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/load_profile',
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadProfileBody(),
    );
  }
}

class LoadProfileBody extends StatefulWidget {
  @override
  _LoadProfileBodyState createState() => _LoadProfileBodyState();
}

class _LoadProfileBodyState extends State<LoadProfileBody> {
  User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _run();
  }

  void _run() async {
    await waitCustomUserClaims();
    getRepository<DatabaseRepository>(context).initializeService();
    _load();
  }

  void _load() {
    final data = MemberData(
      displayName: _user.displayName,
      imageUrl: _user.photoURL,
    );
    load(() => getBloc<ProfileCubit>(context).load(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (ProfileState previous, ProfileState current) {
        return previous.status != current.status;
      },
      builder: (BuildContext context, ProfileState state) {
        final cases = {
          ProfileStatus.initial: () => Container(),
          ProfileStatus.loading: () =>
              Center(child: CircularProgressIndicator()),
          ProfileStatus.error: () {
            return Center(
                child: FloatingActionButton(
              onPressed: () {
                BotToast.cleanAll();
                _load();
              },
              child: Icon(Icons.replay),
            ));
          },
          ProfileStatus.ready: () => Container(),
        };
        assert(cases.length == ProfileStatus.values.length);
        return cases[state.status]();
      },
    );
  }

  Future<bool> waitCustomUserClaims([int retry = 0]) async {
    if (retry < 4) {
      await Future.delayed(Duration(milliseconds: 100));
    } else {
      await showDialog(
        context: context,
        child: AlertDialog(
          content: Text('Не удалось получить доступ, попробуйте ещё раз.'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                navigator.pop();
              },
              child: Text('ОК'),
            ),
          ],
        ),
      );
    }
    final idTokenResult = await _user.getIdTokenResult(true);
    final customUserClaims =
        idTokenResult.claims['https://hasura.io/jwt/claims'];
    if (customUserClaims == null) {
      return waitCustomUserClaims(retry + 1);
    }
    return true;
  }
}
