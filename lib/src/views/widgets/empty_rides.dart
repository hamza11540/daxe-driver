import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taker_driver/src/helper/dimensions.dart';
import 'package:taker_driver/src/helper/styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyRidesWidget extends StatelessWidget {
  final double? height;
  EmptyRidesWidget({
    Key? key,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: AlignmentDirectional.center,
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Theme.of(context).focusColor.withOpacity(0.7),
                          Theme.of(context).focusColor.withOpacity(0.05),
                        ])),
                child: Icon(
                  FontAwesomeIcons.car,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  size: 50,
                ),
              ),
              Positioned(
                right: -30,
                bottom: -50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                top: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 25),
          Opacity(
            opacity: 0.75,
            child: Text(
              AppLocalizations.of(context)!.youDontHaveAnyRides,
              textAlign: TextAlign.center,
              style: khulaBold.merge(TextStyle(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).primaryColor)),
            ),
          ),
        ],
      ),
    );
  }
}
