import 'package:algorithm/planets.dart';
import 'package:base/int_datetime.dart';
import 'package:flutter/material.dart';
import 'package:my_horoskope/logic/daily_screen/calendar_logic.dart';
import 'package:my_horoskope/logic/daily_screen/foreseer.dart';
import 'package:my_horoskope/logic/daily_screen/user_details_for_daily_screen.dart';
import 'package:my_horoskope/widgets/prophecy/prophecies.dart';

class ProphecySheet extends StatelessWidget {
  const ProphecySheet();

  @override
  Widget build(BuildContext context) {
    final foreseer = Foreseer.of(context);
    final userDetails = UserDetailsForDailyScreen.of(context);
    final currentDaySinceEpoch = CalendarLogic.of(context).currentDay.millisecondsSinceEpoch;
    final Map<bool, String> currentPlanets = planetFor[currentDaySinceEpoch.astroSign][userDetails.astroSign];

    foreseer.calculateProphecy(dt: currentDaySinceEpoch);

    return Prophecies(
      prophecies: foreseer.currentProphecy,
      planets: currentPlanets,
      toShow: userDetails.propheciesToShow,
    );
  }
}
