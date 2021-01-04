import 'package:flutter/material.dart';
import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:slx_snitch/manager.dart';
import 'package:slx_snitch/models/value.dart';
import 'package:slx_snitch/screens/camera.dart';

class RunScreen extends StatefulWidget {
  static const routeName = '/run';
  final String networkID;

  const RunScreen({ this.networkID });

  @override
  _RunScreenState createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  Manager _manager;
  Value _cameraValue;
  List<Widget> _children;
  String _status = "Please wait...";
  CountDownController _controller = CountDownController();
  int _duration = 10;
  int _values = 0;
  String _name = "";
  double _progress = 0.5;
  int _send = 0;
  int _total = 0;
  bool _showProgress = false;

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
      _manager.configurations.forEach((c) {
          if(c.name == 'Run Time') {
            if(c.value[0] != null) {
              _duration = int.parse(c.value[0].states[0].data);
            }
          } else if(c.name == 'Picture') {
            _cameraValue = c.value[0];
          }
      });
      _manager.sensors.forEach((sen) {
          sen.value.forEach((val) {
              if(val != null) {
                _values++;
              }
          });
      });
      _name = _manager.network.name;
      setState(() {
          _children = List<Widget>();
          _children.add(getStartInfo());
          _children.add(getStartButton());
          if(_cameraValue != null) {
            _children.add(getTakePicture());
          }
      });
    } else {
      updateStatus("Failed to load '${widget.networkID}' because '${_manager.error}'");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List<Widget>();

    if(_children != null) {
      children.addAll(_children);
    } else {
      children.add(
        Text(
          _status,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      );
    }

    if(_showProgress) {
      children.add(getProgress());
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

  Widget getStartInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0
          ),
        ),
        Text(
          "Run measurement for $_duration seconds",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        Text(
          "and measure $_values values",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        )
      ]
    );
  }

  RaisedButton getStartButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.red)
      ),
      onPressed: _run,
      color: Colors.green,
      textColor: Colors.white,
      child: Text("Start Mesurements".toUpperCase(),
        style: TextStyle(fontSize: 14)
      ),
    );
  }

  RaisedButton getTakePicture() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.red)
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraScreen(value: _cameraValue))
      ),
      color: Colors.green,
      textColor: Colors.white,
      child: Text("Take Picture".toUpperCase(),
        style: TextStyle(fontSize: 14)
      ),
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
      onComplete: () async {
        setState(() {
            _children = null;
          }
        );
        updateStatus("Uploading data. Please wait...");
        await _manager.stop();
        _showProgress = false;
        _manager.wappsto.progressStatus(null);

        setState(() {
            _children = List<Widget>();
            _children.add(Text(
                "$_total measurements captured in $_duration seconds",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
            ));
            _children.add(getDoneButton());
          }
        );
      },
    );
  }

  Widget getProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 20,
          )
        ),
        Text(
          "$_send / $_total measurements",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ]
    );
  }

  Future _run() async {
    setState(() {
        _children = null;
    });

    updateStatus("Starting measurements...");

    _manager.wappsto.progressStatus((double p) {
        if(mounted) {
          try {
            setState(() {
              _progress = p;
              _send = _manager.wappsto.sendEvents;
              _total = _manager.wappsto.totalEvents;
            });
          } catch (e) {
            print(e);
          }
        }
    });

    await _manager.start();

    setState(() {
        _children = List<Widget>();
        _children.add(getTimer());
        _showProgress = true;
    });
  }

}
