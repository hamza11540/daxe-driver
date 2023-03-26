import 'dart:async';

import 'package:taker_driver/src/models/status_enum.dart';
import 'package:taker_driver/src/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../controllers/user_controller.dart';
import '../widgets/menu.dart';
import '../widgets/ride_available.dart';
import 'home_map.dart';
import 'rides.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  final bool saveLocation;
  const HomeScreen({Key? key, this.index = 0, this.saveLocation = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends StateMVC<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late UserController _con;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  Timer? _timer;
  final GlobalKey<RideAvailableState> _rideAvailableState =
      GlobalKey<RideAvailableState>();

  HomeScreenState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setLocationListener();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  Future<void> setLocationListener() async {
    if (widget.saveLocation) {
      await _con.doUpdateLocation().catchError((error) async {
        if (currentUser.value.driver?.active ?? false) {
          await _con.doUpdateRideActive(false);
        }
        return;
      });
    }
    if (currentUser.value.driver?.active ?? false) {
      getLocationPeriodically();
    }
    currentUser.addListener(() {
      if (currentUser.value.driver?.active ?? false) {
        getLocationPeriodically();
      } else {
        if (_timer != null) {
          _timer!.cancel();
        }
      }
    });
  }

  Future<void> getLocationPeriodically() async {
    bool timerFinished = true;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = new Timer.periodic(Duration(seconds: 30), (Timer timer) async {
      if (timerFinished) {
        timerFinished = false;
        await _con
            .doUpdateLocation(dialogsRequired: true)
            .catchError((error) async {
          if (currentUser.value.driver?.active ?? false) {
            await _con.doUpdateRideActive(false);
          }
          setState(() {
            currentUser.value.driver?.active;
          });
        }).whenComplete(() => timerFinished = true);
      }
    });
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _key,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Drawer(
            child: MenuWidget(
              onSwitchTab: (tab) {
                if (tab == 'Home') {
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).pushReplacementNamed(
                    '/$tab',
                  );
                }
              },
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: RideAvailable(
                  key: _rideAvailableState,
                  refreshOnStart: false,
                ),
              ),
              Divider(
                color: Color.fromRGBO(224, 224, 224, 1),
                thickness: 2.5,
                height: 0,
              ),
              Expanded(
                  child: RidesScreen(
                status: [
                  StatusEnum.pending,
                  StatusEnum.accepted,
                  StatusEnum.in_progress
                ],
              )),
            ],
          ),
        ),
        body: HomeMapScreen(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
