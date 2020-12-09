import 'package:flutter/material.dart';
import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:slx_snitch/manager.dart';

class RunScreen extends StatefulWidget {
  static const routeName = '/run';
  final String networkID;

  const RunScreen({ this.networkID });

  @override
  _RunScreenState createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  Manager _manager;
  Widget _child;
  String _status = "Please wait...";
  CountDownController _controller = CountDownController();
  int _duration = 10;

  @override
  void initState() {
    super.initState();

    _manager = Manager(state: this, networkID: widget.networkID);
    setup();
  }

  @override
  void dispose() {
    _manager.stop();
    super.dispose();
  }

  void updateStatus(msg) {
    setState(() => _status = msg);
  }

  Future<void> setup() async {
    if(await _manager.setup()) {
      updateStatus("Run for ${widget.networkID}");
      _duration = 10;
      setState(() {
          _child = getStartButton();
      });
    } else {
      updateStatus("Failed to load '${widget.networkID}' because '${_manager.error}'");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List<Widget>();

    if(_child != null) {
      children.add(_child);
    } else {
      children.add(Text(
          _status,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Run measurement'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: _done,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children
        ),
      ),
    );
  }

  void _done() {
    Navigator.of(context).pop(false);
  }

  RaisedButton getStartButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.red)),
      onPressed: _run,
      color: Colors.green,
      textColor: Colors.white,
      child: Text("Start Mesurements".toUpperCase(),
        style: TextStyle(fontSize: 14)),
    );
  }

  RaisedButton getDoneButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.red)),
      onPressed: _done,
      color: Colors.green,
      textColor: Colors.white,
      child: Text("All Done!".toUpperCase(),
        style: TextStyle(fontSize: 14)),
    );
  }

  CircularCountDownTimer getTimer() {
    return CircularCountDownTimer(
      // Countdown duration in Seconds
      duration: _duration,
      // Controller to control (i.e Pause, Resume, Restart) the Countdown
      controller: _controller,

      // Width of the Countdown Widget
      width: MediaQuery.of(context).size.width / 2,

      // Height of the Countdown Widget
      height: MediaQuery.of(context).size.height / 2,

      // Default Color for Countdown Timer
      color: Colors.white,

      // Filling Color for Countdown Timer
      fillColor: Colors.red,

      // Background Color for Countdown Widget
      backgroundColor: null,

      // Border Thickness of the Countdown Circle
      strokeWidth: 5.0,

      // Text Style for Countdown Text
      textStyle: TextStyle(
        fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold),

      // true for reverse countdown (max to 0), false for forward countdown (0 to max)
      isReverse: true,

      // true for reverse animation, false for forward animation
      isReverseAnimation: true,

      // Optional [bool] to hide the [Text] in this widget.
      isTimerTextShown: true,

      // Function which will execute when the Countdown Ends
      onComplete: () {
        _manager.stop();
        setState(() {
            _child = getDoneButton();
          }
        );
      },
    );
  }

  Future _run() async {
    setState(() {
        _child = null;
    });

    updateStatus("Starting measurements...");

    await _manager.start();

    setState(() {
        _child = getTimer();
    });
  }

}
