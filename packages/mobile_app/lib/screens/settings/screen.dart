import 'index.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final name = MutableString("");
  final month = MutableString("");
  final day = MutableString("");
  final year = MutableString("");
  final sex = MutableInteger(0);
  final indexToSex = {
    0: lang.notSelectedSex.capitalize(),
    1: lang.male.capitalize(),
    2: lang.female.capitalize(),
    3: lang.other.capitalize(),
  };
  final country = MutableString("");
  final place = MutableString("");

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  SingleProvider sp;
  UserModel user;

  @override
  void initState() {
    /// getting single provider
    sp = context.read<SingleProvider>();

    /// setting current values
    user = sp.usersRepo.current.model;
    widget.name.wrapped = user.name;
    final birthDate = DateTime.fromMillisecondsSinceEpoch(user.birth);
    widget.month.wrapped = (birthDate.month).toString();
    if (widget.month.wrapped.length == 1)
      widget.month.wrapped = "0${widget.month.wrapped}";
    widget.day.wrapped = birthDate.day.toString();
    widget.year.wrapped = birthDate.year.toString();
    widget.sex.wrapped = user.sex;
    widget.country.wrapped = user.country;
    widget.place.wrapped = user.place;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: ListView(
          children: [
            myProphetAppBar(
                width: screen.width,
                label: lang.profileSettings.capitalize(),
                onTap: () {
                  Navigator.pushNamed(context, '/menu');
                }),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                lang.personalInformation.capitalize(),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: userSettingsList(
                name: widget.name,
                month: widget.month,
                day: widget.day,
                year: widget.year,
                sex: widget.sex,
                indexToSex: widget.indexToSex,
                country: widget.country,
                place: widget.place,
                onUnvalidInformation: () {
                  showOverCurrentScreen(
                      context: context,
                      child: wrongInformation(lang.notAllFieldsFilled));
                },
                onValidInformation: () {
                  final birthDateEntered = DateTime.utc(
                    int.parse(widget.year.wrapped),
                    int.parse(widget.month.wrapped),
                    int.parse(widget.day.wrapped),
                  ).millisecondsSinceEpoch;

                  if (user.birth == birthDateEntered) {
                    sp.usersRepo.current.model = UserModel(
                      name: widget.name.wrapped,
                      birth: birthDateEntered,
                      sex: widget.sex.wrapped,
                      country: widget.country.wrapped,
                      place: widget.place.wrapped,
                    );
                    sp.usersRepo.write();
                  }

                  Navigator.pushNamed(context, '/daily');
                },
                buttonText: lang.save.toUpperCase(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
