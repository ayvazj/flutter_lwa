part of 'lwa.dart';

class LwaButton extends StatefulWidget {
  final VoidCallback onPressed;

  const LwaButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  _LwaButtonState createState() => _LwaButtonState();
}

class _LwaButtonState extends State<LwaButton> {
  static const String btnImageUnpressed =
      'assets/images/btnlwa_gold_loginwithamazon.png';
  static const String btnImagePressed =
      'assets/images/btnlwa_gold_loginwithamazon_pressed.png';
  String _btnImage = btnImageUnpressed;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTapDown: (tap) {
        setState(() {
          setState(() {
            _btnImage = btnImagePressed;
          });
        });
      },
      onTapUp: (tap) {
        setState(() {
          setState(() {
            _btnImage = btnImageUnpressed;
          });
        });
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_btnImage, package: package_name),
          ),
        ),
        child: new FlatButton(
            padding: EdgeInsets.all(0.0),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: this.widget.onPressed,
            child: null),
      ),
    );
  }
}
