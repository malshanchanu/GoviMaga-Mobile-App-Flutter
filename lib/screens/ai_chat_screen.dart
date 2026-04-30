import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory(); 
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? history = prefs.getString('chat_history');
    if (history != null) {
      if (mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(jsonDecode(history));
        });
      }
      _scrollToBottom();
    } else {
      _addInitialMessage();
    }
  }


  void _addInitialMessage() {

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      final locale = Localizations.localeOf(context);
      String welcomeText = "ආයුබෝවන්! මම ගොවිමඟ සහායකයා. 🌱"; // Default

      if (locale.languageCode == 'ta') {
        welcomeText = "வணக்கம்! நான் கோவிமக உதவி ரோபோ. 🌱";
      } else if (locale.languageCode == 'en') {
        welcomeText = "Hello! I am GoviMaga Assistant. 🌱";
      }

      if (mounted) {
        setState(() {
          _messages.add({'text': welcomeText, 'isUser': false});
        });
      }
      _saveChatHistory();
    });
  }


  Future<void> _speak(String text) async {
    final locale = Localizations.localeOf(context);
    String ttsLang = "si-LK"; 
    
    if (locale.languageCode == 'ta') ttsLang = "ta-IN";
    else if (locale.languageCode == 'en') ttsLang = "en-US";

    await _flutterTts.setLanguage(ttsLang);
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(_messages));
  }



  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    if (mounted) {
      setState(() {
        _messages.add({'text': userMessage, 'isUser': true});
        _isLoading = true;
      });
    }
    _messageController.clear();
    _scrollToBottom();
    _saveChatHistory();

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GROQ_API_KEY is not set in .env file.');
      }

      // Build message history for Deepseek
      List<Map<String, String>> apiMessages = [
        {"role": "system", "content": "You are GoviMaga Assistant. Respond in the language user asks."}
      ];

      for (var msg in _messages) {
        apiMessages.add({
          "role": msg['isUser'] ? "user" : "assistant",
          "content": msg['text']
        });
      }

      int retries = 3;
      String lastError = '';
      http.Response? response;

      while (retries > 0) {
        try {
          response = await http.post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              "model": "llama-3.3-70b-versatile",
              "messages": apiMessages,
              "temperature": 0.7,
            }),
          ).timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            break; // Success
          } else if (response.statusCode == 429 || response.statusCode >= 500) {
            lastError = 'Server busy (${response.statusCode}). Retrying...';
            retries--;
            if (retries > 0) {
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }
          } else {
            throw Exception('API Error: ${response.statusCode} - ${response.body}');
          }
        } on TimeoutException catch (_) {
          lastError = 'Connection timeout. The server took too long to respond.';
          retries--;
          if (retries > 0) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
        } catch (e) {
          lastError = e.toString();
          if (lastError.contains('ClientException') || lastError.contains('SocketException')) {
            retries--;
            if (retries > 0) {
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }
          } else if (retries == 3) {
            throw e; // Non-retryable error immediately
          }
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception(lastError.isNotEmpty ? lastError : 'Failed to connect to Groq API');
      }

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final botResponse = responseData['choices'][0]['message']['content'] ?? 'Error generating response';

      if (mounted) {
        setState(() {
          _messages.add({'text': botResponse, 'isUser': false});
        });
      }
      
      _speak(botResponse); 

    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'text': "Connection Error: ${e.toString().replaceAll('Exception: ', '')}", 'isUser': false});
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _scrollToBottom();
      _saveChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {

    final locale = Localizations.localeOf(context);
    String headerTitle = "ගොවිමඟ AI සහායකයා";
    
    if (locale.languageCode == 'ta') {
      headerTitle = "கோவிமக AI உதவியாளர்";
    } else if (locale.languageCode == 'en') {
      headerTitle = "GoviMaga AI Assistant";
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.smart_toy_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(headerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('chat_history');
                    if (mounted) setState(() => _messages.clear());
                    _addInitialMessage();
                  },
                )
              ],
            ),
          ),
          
          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) 
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.volume_up, size: 18, color: Colors.grey),
                          onPressed: () => _speak(msg['text']),
                        ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFF1B5E20) : Colors.grey[100],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isUser ? 18 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 18),
                          ),
                        ),
                        child: Text(
                          msg['text'], 
                          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading) 
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(backgroundColor: Colors.transparent, color: Color(0xFF1B5E20)),
            ),

          // Input Area
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 15, right: 15, top: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF1B5E20),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
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