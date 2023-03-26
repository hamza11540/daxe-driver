import 'package:taker_driver/src/models/status_enum.dart';
import 'package:taker_driver/src/views/screens/rides.dart';
import 'package:taker_driver/src/views/widgets/earnings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../widgets/menu.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EarningsScreenState();
  }
}

class EarningsScreenState extends StateMVC<RidesScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).highlightColor,
          title: Text(
            AppLocalizations.of(context)!.earnings,
            style: khulaSemiBold.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
          ),
          elevation: 1,
          shadowColor: Theme.of(context).primaryColor,
        ),
        drawer: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Drawer(
            child: MenuWidget(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              EarningsWidget(),
              Expanded(
                child: RidesScreen(
                  status: [StatusEnum.completed],
                  checkRides: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
