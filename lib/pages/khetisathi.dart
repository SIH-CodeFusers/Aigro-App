import 'dart:async';
import 'dart:io';
import 'package:aigro/secret.dart';
import 'package:aigro/widgets/grid_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class KhetiSathi extends StatefulWidget {
  const KhetiSathi({super.key});

  @override
  State<KhetiSathi> createState() => _KhetiSathiState();
}

class _KhetiSathiState extends State<KhetiSathi> {
  int count=0;
  bool imgup=false;
  bool suggest=false;
  
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  final List<String> _predefinedBotMessages = [
    'Hi, I am your KhetiSathi, I am a chatbot created by team Aigro to assist farmers like you with your queries. How can I help you today ?',
  ];


  void _sendInitialBotMessage(String message) {
    Timer(const Duration(seconds: 0), () {
      _streamBotMessage(message);
    });

  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add({'sender': 'user', 'message': message}); 
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
      }
    });
  }

  Future<void> _sendGemini(String message) async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GEMINI_API_KEY,
    );

    final prompt = 'You are a helpful chatbot, your task is to answer farming related questions. You have been made by team Aigro consisting of team members Arunava and Pretisha in Frontend, Satyaki in Full stack Development, Rishi in machine learning and priyanshu and Shinjan in App development. just return answer in plain text strictly. Here is my question \n $message';
    final content = [
      Content.text(prompt),
    ];

    final response = await model.generateContent(content);
    _streamBotMessage(response.text!); 

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
      
        title: Text('Your KhetiSathi'),
      ),
      body: Stack(
        children: [
           CustomPaint(
            size: Size.infinite, // Take the full available space
            painter: GridPatternPainter(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final isUser = _messages[index]['sender'] == 'user';
                      final isImage = _messages[index]['type'] == 'image';
                      final name = isUser ? 'You' : 'KhetiSathi';
                      final time =
                          DateTime.now().toLocal().toString().substring(11, 16);
          
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment:
                              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                  maxWidth: 250,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: isUser
                                              ? context.theme.highlightColor
                                              : context.theme.cardColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(                   
                                        _messages[index]['message']!,  
                                        style: TextStyle(color: isUser
                                              ? context.theme.highlightColor
                                              : context.theme.primaryColorDark,),         
                                      )
                                    ],
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
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                         child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), 
                                borderSide: BorderSide(
                                  color: context.theme.primaryColorDark,
                                  width: 2.0, 
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: context.theme.cardColor,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: context.theme.cardColor, 
                                  width: 2.0,
                                ),
                              ),
                              filled: true, 
                              fillColor: context.theme.highlightColor, 
                            ),
                            style: TextStyle(
                              color: context.theme.primaryColorDark, 
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Container(
                          decoration: BoxDecoration(
                            color: context.theme.cardColor, 
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            color: context.theme.highlightColor,
                            icon: Icon(FeatherIcons.arrowRight),
                            onPressed: () {
                              final message = _controller.text.trim();
                              if (message.isNotEmpty) {
                                _sendMessage(message);
                                // _sendGemini(message);
                                _controller.clear();
                              }
                            },
                          ),
                        )
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
