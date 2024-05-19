import 'package:agent/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:agent/bloc/message_bloc.dart';
import 'package:agent/repository/PromptRepository.dart';
import 'package:agent/service/PromptDataProvider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => PromptRepository(PromptDataProvider()),
      child: BlocProvider(
        create: (context) => MessageBloc(context.read<PromptRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Free Doctor',
          theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
              appBarTheme: const AppBarTheme(
                  color: Color.fromRGBO(81, 45, 168, 1),
                  centerTitle: true,
                  foregroundColor: Colors.white)),
          home: const MyHomePage(title: 'YOUR PERSONAL DOCTOR'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isTalking = false;
  String _lastWords = '';
  String _spokenWords = "";

  late final List<AnimationController> _animationControllers;
  late final List<Animatable<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initSetting();
    _animationControllers = _createAnimationControllers();
    _animations = _createAnimations();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 1),
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _getPromptResponse();
    });
  }

  void _speak(String text) async {
    if (text != _spokenWords) {
      await _flutterTts.speak(text);
      setState(() {
        _spokenWords = text;
        _isTalking = true;
      });
    }
  }

  void _stop() async {
    if (_isTalking) {
      await _flutterTts.stop();
      setState(() {
        _isTalking = false;
      });
    }
  }

  void _initSetting() async {
    await _flutterTts.setVolume(0.9);
    await _flutterTts.setPitch(1.2);
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.setLanguage("en-US");
  }

  void _getPromptResponse() {
    if (!_speechToText.isListening && _lastWords != "") {
      context.read<MessageBloc>().add(MessageUpdate(userPrompt: _lastWords));
      context.read<MessageBloc>().add(MessageFetch());
      setState(() {
        _lastWords = "";
      });
    }
  }

  List<AnimationController> _createAnimationControllers() {
    return [
      AnimationController(duration: const Duration(seconds: 2), vsync: this)
        ..repeat(reverse: true),
      AnimationController(duration: const Duration(seconds: 3), vsync: this)
        ..repeat(reverse: true),
      AnimationController(duration: const Duration(seconds: 4), vsync: this)
        ..repeat(reverse: true),
      AnimationController(duration: const Duration(seconds: 5), vsync: this)
        ..repeat(reverse: true),
    ];
  }

  List<Animatable<Offset>> _createAnimations() {
    return List.generate(
      4,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: const Offset(0, -0.25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              color: Colors.deepPurpleAccent.shade100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _speechToText.isListening
                    ? Text(
                        "Speak in to the microphone",
                        style: TextStyle(
                            color: Colors.deepPurple.shade900, fontSize: 20),
                      )
                    : Text(
                        "Press the microphone the right button to start speaking with the doctor",
                        style: TextStyle(
                          color: Colors.deepPurple.shade900,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  if (state is MessageSuccess) {
                    if (state.message.length > 1) {
                      _speak(state.message.last.content);
                      return LoadingWidget(
                          offsetAnimations:
                              _animations.asMap().entries.map((entry) {
                            final index = entry.key;
                            final animatable = entry.value;
                            return _animationControllers[index]
                                .drive(animatable);
                          }).toList(),
                          color: const Color.fromRGBO(83, 109, 254, 1));
                    } else {
                      return LoadingWidget(
                          offsetAnimations:
                              _animations.asMap().entries.map((entry) {
                            final index = entry.key;
                            final animatable = entry.value;
                            return _animationControllers[index]
                                .drive(animatable);
                          }).toList(),
                          color: const Color.fromRGBO(189, 189, 189, 1));
                    }
                  } else if (state is MessageFailure) {
                    return LoadingWidget(
                        offsetAnimations:
                            _animations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final animatable = entry.value;
                          return _animationControllers[index].drive(animatable);
                        }).toList(),
                        color: const Color.fromARGB(255, 255, 0, 0));
                  } else {
                    return LoadingWidget(
                        offsetAnimations:
                            _animations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final animatable = entry.value;
                          return _animationControllers[index].drive(animatable);
                        }).toList(),
                        color: const Color.fromRGBO(189, 189, 189, 1));
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton(
                  onPressed: () => {
                    if (_isTalking) {_stop()}
                  },
                  tooltip: 'Speaking',
                  backgroundColor: const Color.fromRGBO(83, 109, 254, 1),
                  child: Icon(_isTalking ? Icons.stop : Icons.play_arrow),
                ),
                ElevatedButton(
                  onPressed: () =>
                      context.read<MessageBloc>().add(MessageClear()),
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Color.fromRGBO(83, 109, 254, 1)),
                      foregroundColor: WidgetStatePropertyAll(Colors.white)),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "Clear Context",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: _speechEnabled
                      ? () {
                          if (!_speechToText.isListening) {
                            setState(() {
                              _isTalking = false;
                            });
                            _startListening();
                          } else {
                            _stopListening();
                          }
                        }
                      : null,
                  tooltip: 'Listen',
                  backgroundColor: const Color.fromRGBO(83, 109, 254, 1),
                  child: Icon(
                      _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _createAnimationControllers()) {
      controller.dispose();
    }
    super.dispose();
  }
}
