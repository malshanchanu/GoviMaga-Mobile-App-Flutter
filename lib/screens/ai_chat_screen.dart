import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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
  GenerativeModel? _model;
  ChatSession? _chatSession;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _loadChatHistory(); 
    _setupAI();
  }

  
  void _initTTS() async {
    await _flutterTts.setLanguage("si-LK");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  
  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(_messages));
  }

  
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? history = prefs.getString('chat_history');
    if (history != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(jsonDecode(history));
      });
      _scrollToBottom();
    } else {
      _addInitialMessage();
    }
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add({
        'text': 'ආයුබෝවන්! මම ගොවිමඟ සහායකයා. ඔයාගේ වගාවන් ගැන මගෙන් ඕනෑම දෙයක් අහන්න. 🌱',
        'isUser': false
      });
    });
    _saveChatHistory();
  }

  void _setupAI() {
    final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "AIzaSyDb6hit3LEq9qh5JnItrVa5aJ0w3YqdWvo";
    try {
      _model = GenerativeModel(
        model: 'gemini-pro', 
        apiKey: apiKey,
        systemInstruction: Content.system('ඔයා ගොවිමඟ සහායකයා. සිංහලෙන් උදව් කරන්න.'),
      );
      _chatSession = _model!.startChat();
    } catch (e) {
      debugPrint("AI Setup Error: $e");
    }
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
    setState(() {
      _messages.add({'text': userMessage, 'isUser': true});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();
    _saveChatHistory();

    try {
      if (_chatSession != null) {
        final response = await _chatSession!.sendMessage(Content.text(userMessage));
        final botResponse = response.text ?? 'මට ඒක තේරුණේ නැහැ.';
        
        setState(() {
          _messages.add({'text': botResponse, 'isUser': false});
        });
        
        _speak(botResponse); 
      }
    } catch (e) {
      setState(() {
        _messages.add({'text': 'සොරි මචං, පොඩි Connection අවුලක්. පස්සේ ආයේ ට්‍රයි කරමු.', 'isUser': false});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
      _saveChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Row(
                  children: [
                    Icon(Icons.smart_toy_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text("ගොවිමඟ AI සහායකයා", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                  onPressed: () async {
                    // History එක සම්පූර්ණයෙන්ම මකා දැමීම
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('chat_history');
                    setState(() => _messages.clear());
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
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1B5E20) : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                      ],
                    ),
                    child: InkWell(
                      onLongPress: () => _speak(msg['text']),
                      child: Text(
                        msg['text'], 
                        style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14.5),
                      ),
                    ),
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
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
              left: 15, 
              right: 15,
              top: 10
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "ප්‍රශ්නය මෙතන ලියන්න...",
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