import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';

import 'package:arknightstools/utils/Consts.dart';

class AutomaticRecruitmentHelpDialog extends StatefulWidget {
  @override
  _AutomaticRecruitmentHelpDialogState createState() =>
      _AutomaticRecruitmentHelpDialogState();
}

class _AutomaticRecruitmentHelpDialogState
    extends State<AutomaticRecruitmentHelpDialog> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
        'https://firebasestorage.googleapis.com/v0/b/arknights-tools.appspot.com/o/videos%2Fautomatic_recruitment_help_hd.mp4?alt=media&token=83f7dbd2-82a2-4afb-8ff2-d7927a5fdd72');

    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width - 10,
          height: MediaQuery.of(context).size.height - 10,
          padding: EdgeInsets.only(
            top: Consts.operatorsDialogPadding,
            bottom: Consts.operatorsDialogPadding,
            left: Consts.operatorsDialogPadding,
            right: Consts.operatorsDialogPadding,
          ),
          decoration: new BoxDecoration(
            color: Consts.operatorsBackgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.operatorsDialogPadding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Center(
            child: Scaffold(
              body: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    );
                  } else {
                    return Center(
                      child: SpinKitWave(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  index.isEven ? Colors.grey : Colors.white70,
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.operatorsDialogPadding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
