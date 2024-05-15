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
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
            // Note: useMaterial3 is deprecated
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _lastWords = '';

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
    //_stop();
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 1),
    );
    setState(() {});
  }

  void _stopListening() async {
    //_stop();
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
    await _flutterTts.speak(text);
  }

  void _stop() async {
    await _flutterTts.stop();
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
          Text(_lastWords),
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
                          color: const Color.fromARGB(255, 255, 0, 0));
                    } else {
                      return const Text("No messages yet!");
                    }
                  } else if (state is MessageLoading) {
                    return LoadingWidget(
                        offsetAnimations:
                            _animations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final animatable = entry.value;
                          return _animationControllers[index].drive(animatable);
                        }).toList(),
                        color: const Color.fromARGB(255, 255, 255, 255));
                  } else if (state is MessageFailure) {
                    return Center(child: Text('Error: ${state.error}'));
                  } else {
                    return const Center(child: Text('No messages yet'));
                  }
                },
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () => context.read<MessageBloc>().add(MessageClear()),
              child: const Text("clear context"))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechEnabled
            ? () {
                if (!_speechToText.isListening) {
                  _startListening();
                } else {
                  _stopListening();
                }
              }
            : null,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
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
