part of 'lwa.dart';

class LwaButton extends StatefulWidget {
  final VoidCallback onPressed;

  const LwaButton({
    Key? key,
    required this.onPressed,
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
    return GestureDetector(
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
            child: IconButton(
              icon: Image(image: AssetImage(_btnImage, package: packageName)),
              iconSize: 50,
              onPressed: widget.onPressed,
            )));
  }
}
