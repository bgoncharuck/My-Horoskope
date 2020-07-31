import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:impact_model/impact_model.dart';
import 'package:prophecies_repository/prophecies_repository.dart';
import 'package:language/language.dart';
import 'package:app/theme/app_colors.dart';

class ProphecyRecord extends StatelessWidget {
  final ProphecyEntity prophecy;

  ProphecyRecord({Key key, @required this.prophecy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final impactsCount = prophecy.changes.length;

    double value = prophecy.model.value ?? 0.0;
    // add impacts to prophecy value if any
    for (ImpactModel impact in prophecy.changes) value += impact.value;

    var valuePercent = value / 10;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      height: 68.0 + (128 * impactsCount),
      child: Column(
        children: <Widget>[
          Container(
            height: 60.0 + (128 * impactsCount),
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      lang.prophecyId[prophecy.model.id],
                      style: TextStyle(
                        fontSize: 18.0,
                        color: AppColors.textPrimary,
                      ),
                    )),
                    Center(
                      child: Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w400,
                          color: chooseNumberColor(value),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: ChangesList(prophecy.changes)),
              ],
            ),
          ),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              gradient: LinearGradient(colors: [
                AppColors.prophecyValueProgressGradient[0],
                AppColors.prophecyValueProgressGradient[1],
                AppColors.prophecyValueProgressGradient[2],
                AppColors.prophecyValueProgressGradient[3],
                AppColors.prophecyValueProgressGradient[4],
                AppColors.prophecyValueProgressGradient[5],
                AppColors.prophecyValueProgressGradient[6],
                AppColors.prophecyValueProgressGradient[7],
                AppColors.prophecyValueProgressGradient[8],
                AppColors.prophecyValueProgressGradient[8],
                Colors.transparent
              ], stops: [
                0.0,
                0.1,
                (valuePercent > 0.3) ? 0.3 : valuePercent,
                (valuePercent > 0.4) ? 0.4 : valuePercent,
                (valuePercent > 0.5) ? 0.5 : valuePercent,
                (valuePercent > 0.6) ? 0.6 : valuePercent,
                (valuePercent > 0.7) ? 0.7 : valuePercent,
                (valuePercent > 0.8) ? 0.8 : valuePercent,
                (valuePercent > 0.9) ? 0.9 : valuePercent,
                (valuePercent > 1.0) ? 1.0 : valuePercent,
                valuePercent,
              ]),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.prophecyGradientStart.withOpacity(0.7),
              AppColors.prophecyGradientEnd.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(8.0)),
    );
  }
}

class ChangesList extends StatelessWidget {
  final List<ImpactModel> changes;
  ChangesList(this.changes);
  @override
  Widget build(BuildContext context) {
    if (changes.isNotEmpty) {
      final curImp = changes[0];
      final sign = (curImp.value >= 0.0) ? '+' : '';
      return Container(
        padding: EdgeInsets.only(top: 8),
        child: Wrap(
          children: <Widget>[
            SvgPicture.asset(
              "assets/icons/${curImp.iconName}.svg",
              width: 14,
              height: 14,
              color: (curImp.value < 0.0)
                  ? AppColors.accentDark
                  : AppColors.prophecyValueNumber[2],
            ),
            Text(
              " ( $sign${curImp.value.toStringAsFixed(1)} )",
              style: TextStyle(
                  fontSize: 14.0,
                  color: (curImp.value < 0.0)
                      ? AppColors.accentDark
                      : AppColors.prophecyValueNumber[2]),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              height: 116,
              child: ListView(
                children: <Widget>[
                  Text("${curImp.text}",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.textPrimary,
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    } else
      return Container();
  }
}

Color chooseNumberColor(double value) {
  return chooseNumberColorFromThreeVariants(value);
}
