import 'dart:async';
import 'package:aigro/secret.dart';
import 'package:aigro/widgets/grid_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class KhetiSathi extends StatefulWidget {
  const KhetiSathi({super.key});

  @override
  State<KhetiSathi> createState() => _KhetiSathiState();
}

class _KhetiSathiState extends State<KhetiSathi> {
  int count = 0;
  bool imgup = false;
  bool suggest = false;
  bool isTyping = false; // Indicates if the bot is typing
  bool isListening = false; // Indicates if the mic is actively listening
  String listeningText = ''; // Holds the current listening text

  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  final List<String> _predefinedBotMessages = [
    'Hi, I am your Krishi AI, I am a chatbot created by team Kheti Sathi to assist farmers like you with your queries. How can I help you today?',
  ];

  void _sendInitialBotMessage(String message) {
    Timer(const Duration(seconds: 0), () {
      _streamBotMessage(message);
    });
  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add({'sender': 'user', 'message': message});
      isTyping = true; // Bot is "typing"
    });
    _sendGemini(message);
  }

  void _streamBotMessage(String message) {
    List<String> words = message.split(' ');
    String accumulatedMessage = '';
    int index = 0;

    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (index < words.length) {
        setState(() {
          accumulatedMessage += (index == 0 ? '' : ' ') + words[index];
          if (_messages.isNotEmpty && _messages.last['sender'] == 'bot') {
            _messages.last['message'] = accumulatedMessage;
          } else {
            _messages.add({
              'sender': 'bot',
              'message': accumulatedMessage,
            });
          }
        });
        index++;
      } else {
        timer.cancel();
        setState(() {
          isTyping = false; // Bot finished typing
        });
      }
    });
  }

  Future<void> _sendGemini(String message) async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GEMINI_API_KEY,
    );

    final prompt =
        'You are a helpful chatbot, your task is to answer farming related questions. You have been made by team Kheti Sathi consisting of team members Arunava and Pretisha in Frontend, Satyaki in Full Stack Development, Rishi in Machine Learning and Priyanshu and Shinjan in App development. Just return the answer in plain text strictly and no markdown. Here is my question: $message';

    final content = [
      Content.text(prompt),
    ];

    final response = await model.generateContent(content);
    _streamBotMessage(response.text!);
  }

  FlutterTts flutterTts = FlutterTts();

  _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint('Status: $status'),
      onError: (error) => debugPrint('Error: $error'),
    );

    if (available) {
      setState(() {
        isListening = true;
        listeningText = 'Listening...'; // Indicate listening mode
      });
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            listeningText = result.recognizedWords;
            _controller.text = result.recognizedWords;
          });
        },
      );
    } else {
      debugPrint('Speech recognition not available');
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
      listeningText = ''; // Clear listening text
    });
  }

  @override
  void initState() {
    _sendInitialBotMessage(_predefinedBotMessages[count++]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Your Krishi AI'),
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: GridPatternPainter(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length + (isTyping || isListening ? 1 : 0),
                    itemBuilder: (context, index) {
                      if ((isTyping || isListening) && index == _messages.length) {
                        // Loader message for typing or listening
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: context.theme.primaryColorDark,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isListening ? listeningText : 'Krishi AI is typing...',
                                style: TextStyle(
                                  color: context.theme.primaryColorDark,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final isUser = _messages[index]['sender'] == 'user';
                      final name = isUser ? 'You' : 'Krishi AI';
                      final time = DateTime.now()
                          .toLocal()
                          .toString()
                          .substring(11, 16);

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 250,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isUser) {
                                      _speak(_messages[index]['message']!);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? context.theme.cardColor
                                          : context.theme.highlightColor,
                                      borderRadius: isUser
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(0),
                                            )
                                          : const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(20),
                                            ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                name,
                                                style: TextStyle(
                                                  color: isUser
                                                      ? context.theme
                                                          .highlightColor
                                                      : context.theme.cardColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            if (!isUser)
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor: context
                                                    .theme.focusColor,
                                                child: const Icon(
                                                  FeatherIcons.volume2,
                                                  size: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _messages[index]['message']!,
                                          style: TextStyle(
                                              color: isUser
                                                  ? context
                                                      .theme.highlightColor
                                                  : context
                                                      .theme.primaryColorDark,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: context.theme.splashColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey,

                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Type your message...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          FeatherIcons.mic,
                          color: isListening
                              ? Colors.red
                              : context.theme.focusColor,
                        ),
                        onPressed: () {
                          isListening ? _stopListening() : _startListening();
                        },
                      ),
                      IconButton(
                        icon: const Icon(FeatherIcons.send),
                        onPressed: () {
                          final text = _controller.text;
                          if (text.isNotEmpty) {
                            _sendMessage(text);
                            _controller.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
