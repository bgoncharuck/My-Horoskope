import 'exports_for_daily_screen.dart';

part 'extensions/data.dart';
part 'extensions/calendar_builder.dart';
part 'extensions/prediction.dart';
part 'extensions/animation.dart';
part 'extensions/misc.dart';
part 'extensions/firebase_events.dart';

class DailyScreen extends StatefulWidget {
  /// current and next NUMBER_OF_DAYS_TO_SHOW days DateTime
  final List<DateTime> day = [];

  /// current day to show index
  final currentIndex = MutableInteger(0);

  DailyScreen({Key key}) : super(key: key) {
    //

    final today = DateTime.fromMillisecondsSinceEpoch(dtDay);
    day.add(today);

    /// fills the list with all other days
    for (int d = 1; d <= NUMBER_OF_DAYS_TO_SHOW; d++) day.add(today.add(new Duration(days: d)));
  }

  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> with SingleTickerProviderStateMixin {
  //
  final dat = DailyStateData();
  DateTime birthDate;

  /// @INIT
  @override
  void initState() {
    /// date init
    dat.labelStr = "${dat.user.model.name.capitalize()} (${localeText.you.capitalize()})";
    dat.sign = dat.user.model.birth.astroSign;
    birthDate = dat.user.model.birth.toDateTime;
    dat.birthRow = Row(
      children: <Widget>[
        SvgPicture.asset("assets/icons/${dat.sign}.svg"),
        Text(" ${birthDate.day}.${birthDate.month}.${birthDate.year} ", style: AppTextStyle.normalText),
      ],
    );
    if (AppGlobal.debug.isNotDebug) AppGlobal.debug.testerField.wrapped = dat.user.isTester;

    /// animation
    initAnimations();
    animationFirstStart();

    super.initState();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  /// @BUILD
  @override
  Widget build(BuildContext context) {
    //
    /// gets planets for current period
    dat.currentPlanets.clear();
    dat.currentPlanets.addAll(planetFor[d[selected].millisecondsSinceEpoch.astroSign][dat.sign]);

    calculateProphecy();

    if (isToday) dat.combination = getSymbolCombination(AppGlobal.prophecyUtil.current);

    //
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: const AppBackground(),
          ),
          Positioned.fill(
            child: SafeArea(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  MyProphetAppBar(
                      width: screen.width,
                      label: appBarLabel(selected: selected, dateTime: d[selected]),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppPath.menu);
                      }),
                  _DailyScreenCalendar(
                    width: screen.width,
                    calendarItemBuilder: dayToWidget,
                  ),
                  const SizedBox(
                    height: SPACE_BETWEEN_CALENDAR_PROPHECY,
                  ),
                  AnimatedBuilder(
                    animation: dat.animationSheetsFadeOutController,
                    builder: (context, child) => FadeTransition(
                      opacity: dat.animationSheetsFadeOut,
                      child: child,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _DailyScreenLabelAndBirth(
                          label: dat.labelStr,
                          birthRow: dat.birthRow,
                        ),
                        ProphecySheet(
                          prophecies: AppGlobal.prophecyUtil.current,
                          planets: dat.currentPlanets,
                          toShow: toShow,
                        ),
                        const SizedBox(
                          height: SPACE_AFTER_PROPHECY,
                        ),
                        if (isToday)
                          PredictionLogic(
                            predictionTextCallback: getPredictionByType,
                            toShow: toShow,
                            child: CardsWidget(
                              combination: dat.combination,
                            ),
                          ),
                        if (isToday && dat.user != null && dat.user.ambiance != null && dat.user.ambiance.isNotEmpty)
                          _DailyScreenAmbianceList(
                            getCompatibility: getCompatibility,
                            focusAmbianceChange: focusAmbianceChange,
                            ambiance: dat.user.ambiance,
                            setAmbianceChangeSubject: setAmbianceChangeSubject,
                          ),
                        if (isToday)
                          AddAmbianceButton(
                            onTap: () => focusAmbianceAdd(),
                          ),
                        if (isToday)
                          const SizedBox(
                            height: SPACE_AFTER_AMBIANCE,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// @POPUPS
          if (isToday)
            if (dat.ambianceAdd || dat.ambianceChange)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => unfocusAmbiancePopup(),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
          if (isToday)
            if (dat.ambianceAdd)
              Align(
                alignment: Alignment.center,
                child: AmbianceSubjectNew(
                  onComplete: () => unfocusAmbiancePopup(),
                ),
              ),
          if (isToday)
            if (dat.ambianceChange)
              Align(
                alignment: Alignment.center,
                child: AmbianceSubjectChange(
                  onComplete: () => unfocusAmbiancePopup(),
                  subject: dat.ambianceChangeSubject,
                ),
              ),
        ],
      ),
    );
  }
}

// @TODO: винести в окремі файли
class _DailyScreenCalendar extends StatelessWidget {
  const _DailyScreenCalendar({
    @required this.width,
    @required this.calendarItemBuilder,
  });
  final double width;
  final Widget Function(BuildContext, int) calendarItemBuilder;

  @override
  Widget build(BuildContext context) => Container(
      height: CALENDAR_HEIGHT,
      width: width,
      child: Container(
        decoration: BoxDecoration(color: AppColors.calendarBackground.withOpacity(0.8), boxShadow: [
          BoxShadow(
            color: AppColors.calendarShadow.withOpacity(0.34),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ]),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: NUMBER_OF_DAYS_TO_SHOW,
          itemBuilder: calendarItemBuilder,
        ),
      ));
}

class _DailyScreenLabelAndBirth extends StatelessWidget {
  const _DailyScreenLabelAndBirth({
    @required this.label,
    @required this.birthRow,
  });
  final String label;
  final Widget birthRow;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// {NAME} {ROLE}
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              left: 16.0,
            ),
            child: Text(
              label,
              style: AppTextStyle.userName,
            ),
          ),

          /// {Astrosign} {Birthdate}
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              bottom: 8.0,
            ),
            child: SizedBox(
              height: 32,
              child: birthRow,
            ),
          ),
        ],
      );
}

class _DailyScreenAmbianceList extends StatelessWidget {
  const _DailyScreenAmbianceList({
    @required this.getCompatibility,
    @required this.ambiance,
    @required this.focusAmbianceChange,
    @required this.setAmbianceChangeSubject,
  });

  final double Function(UserEntity subject) getCompatibility;
  final List<UserEntity> ambiance;
  final Function() focusAmbianceChange;
  final Function(UserEntity subject) setAmbianceChangeSubject;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemCount: ambiance.length,
        itemBuilder: (context, index) {
          final subject = ambiance[index];
          return AmbiacneSubject(
            onOptionsTap: () {
              setAmbianceChangeSubject(subject);
              focusAmbianceChange();
            },
            subject: subject,
            compatibility: getCompatibility(subject),
          );
        },
      );
}
