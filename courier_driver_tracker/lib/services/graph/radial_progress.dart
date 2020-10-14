import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import 'package:courier_driver_tracker/services/api_handler/api.dart';

class RadialProgress extends StatefulWidget {
  @override
  _RadialProgressState createState() => _RadialProgressState();
}

class _RadialProgressState extends State<RadialProgress>
    with SingleTickerProviderStateMixin {
  AnimationController _radialProgressAnimationController;
  Animation<double> _progressAnimation;
  final Duration fadeInDuration = Duration(milliseconds: 500);
  final Duration fillDuration = Duration(seconds: 2);
  ApiHandler _api = ApiHandler();
  double score = 0;
  String message = '';
  Color color1 = Colors.black;
  Color color2 = Colors.black;

  double progressDegrees = 0;
  var count = 0;

  @override
  void initState() {
    super.initState();
    setScore();
    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: fillDuration);
    _progressAnimation = Tween(begin: 0.0, end: 360.0).animate(CurvedAnimation(
        parent: _radialProgressAnimationController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {
          progressDegrees = this.score / 100 * _progressAnimation.value;
        });
      });

    _radialProgressAnimationController.forward();
  }

  @override
  void dispose() {
    _radialProgressAnimationController.dispose();
    super.dispose();
  }

  setScore() async {
    this.score = await _api.getDriverScore();
    if (this.score < 25.0) {
      this.message = "bad";
      this.color1 = Colors.red;
    } else if (this.score >= 25.0 && this.score <= 50.0) {
      this.message = "average";
      this.color1 = Colors.orange;
    } else if (this.score > 50.0 && this.score < 75.0) {
      this.message = "good";
      this.color1 = Colors.green;
    } else if (this.score >= 75.0) {
      this.message = "Excellent";
      this.color1 = Colors.blue;
    }
  }

  String stringScore() {
    return this.score.toString();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(
        height: 200.0,
        width: 200.0,
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: AnimatedOpacity(
          opacity: progressDegrees > 30 ? 1.0 : 0.0,
          duration: fadeInDuration,
          child: Column(
            children: <Widget>[
              Text(
                'SCORE',
                style: TextStyle(
                    fontSize: 24.0,
                    letterSpacing: 1.5,
                    fontFamily: "Montserrat"),
              ),
              SizedBox(
                height: 4.0,
              ),
              Container(
                height: 5.0,
                width: 80.0,
                decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                stringScore(),
                style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat"),
              ),
              Text(
                message,
                style: TextStyle(
                    fontSize: 14.0,
                    color: color1,
                    letterSpacing: 1.5,
                    fontFamily: "Montserrat"),
              ),
            ],
          ),
        ),
      ),
      painter: RadialPainter(progressDegrees),
    );
  }
}

class RadialPainter extends CustomPainter {
  RadialPainter(double progressInDegrees) {
    this.progressInDegrees = progressInDegrees;
  }
  double progressInDegrees;

  void paint(Canvas canvas, Size size) async {
    Paint paint = Paint()
      ..color = Colors.black12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, paint);

    Paint progressPaint = Paint()
      ..shader = LinearGradient(
              colors: [Colors.green, Colors.orange, Colors.red])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 3))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90),
        math.radians(progressInDegrees),
        false,
        progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
