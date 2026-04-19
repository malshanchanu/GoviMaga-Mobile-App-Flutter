import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriMate Sri Lanka',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green[700]!,
          primary: Colors.green[700],
        ),
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: DiseaseDiagnosisScreen(),
    );
  }
}

class DiseaseDiagnosisScreen extends StatefulWidget {
  @override
  _DiseaseDiagnosisScreenState createState() => _DiseaseDiagnosisScreenState();
}

class _DiseaseDiagnosisScreenState extends State<DiseaseDiagnosisScreen> {
  File? _selectedImage;
  Map<String, dynamic>? _diagnosisData;
  List<Map<String, dynamic>> _recentDiagnoses = [];
  bool _isLoading = false;

  String _currentLang = 'SI';

  final Map<String, Map<String, String>> _translations = {
    'EN': {
      'appTitle': 'AgriMate Sri Lanka',
      'takePhotoInfo': 'Take or Upload Photo',
      'chooseBtn': 'Choose Image',
      'diagnoseBtn': 'Diagnose Disease',
      'cancelBtn': 'Cancel',
      'analyzing': 'Analyzing disease...',
      'confidence': 'Confidence',
      'treatment': 'Recommended Treatment',
      'prevention': 'Future Prevention',
      'unknown': 'Unknown Disease',
      'recentDiagnoses': 'Recent Diagnoses',
      'justNow': 'Just now',
      'minsAgo': 'mins ago',
      'hoursAgo': 'hours ago',
      'daysAgo': 'days ago',
      'weeksAgo': 'weeks ago',
      'navHome': 'Home',
      'navDiagnose': 'Diagnose',
      'navMarket': 'Market',
      'navCrops': 'Crops',
      'navWeather': 'Weather',
      'navForum': 'Forum',
      'navProfile': 'Profile',
    },
    'SI': {
      'appTitle': 'AgriMate ශ්‍රී ලංකා',
      'takePhotoInfo': 'පින්තූරයක් ලබා දෙන්න',
      'chooseBtn': 'පින්තූරය තෝරන්න',
      'diagnoseBtn': 'රෝගය හඳුනාගන්න',
      'cancelBtn': 'අවලංගු කරන්න',
      'analyzing': 'රෝගය විශ්ලේෂණය කරමින් පවතී...',
      'confidence': 'විශ්වාසනීයත්වය',
      'treatment': 'නිර්දේශිත ප්‍රතිකාර',
      'prevention': 'අනාගත ආරක්ෂණ ක්‍රම',
      'unknown': 'හඳුනා නොගත් රෝගයකි',
      'recentDiagnoses': 'මෑතකාලීන පරීක්ෂාවන්',
      'justNow': 'දැන්',
      'minsAgo': 'මිනිත්තු ගණනකට පෙර',
      'hoursAgo': 'පැය ගණනකට පෙර',
      'daysAgo': 'දින ගණනකට පෙර',
      'weeksAgo': 'සති ගණනකට පෙර',
      'navHome': 'මුල්පිටුව',
      'navDiagnose': 'පරීක්ෂාව',
      'navMarket': 'වෙළඳපොළ',
      'navCrops': 'බෝග',
      'navWeather': 'කාලගුණය',
      'navForum': 'සංසදය',
      'navProfile': 'ගිණුම',
    },
    'TA': {
      'appTitle': 'AgriMate இலங்கை',
      'takePhotoInfo': 'புகைப்படம் பதிவேற்றவும்',
      'chooseBtn': 'படத்தைத் தேர்ந்தெடுக்கவும்',
      'diagnoseBtn': 'நோயைக் கண்டறியவும்',
      'cancelBtn': 'ரத்து செய்',
      'analyzing': 'பகுப்பாய்வு செய்கிறது...',
      'confidence': 'நம்பிக்கை',
      'treatment': 'பரிந்துரைக்கப்பட்ட சிகிச்சை',
      'prevention': 'எதிர்கால தடுப்பு',
      'unknown': 'அறியப்படாத நோய்',
      'recentDiagnoses': 'சமீபத்திய நோயறிதல்கள்',
      'justNow': 'தற்போது',
      'minsAgo': 'நிமிடங்களுக்கு முன்',
      'hoursAgo': 'மணிநேரங்களுக்கு முன்',
      'daysAgo': 'நாட்களுக்கு முன்',
      'weeksAgo': 'வாரங்களுக்கு முன்',
      'navHome': 'முகப்பு',
      'navDiagnose': 'கண்டறிதல்',
      'navMarket': 'சந்தை',
      'navCrops': 'பயிர்கள்',
      'navWeather': 'வானிலை',
      'navForum': 'மன்றம்',
      'navProfile': 'சுயவிவரம்',
    }
  };

  String _t(String key) {
    return _translations[_currentLang]?[key] ?? key;
  }

  String _timeAgo(DateTime pastTime) {
    final difference = DateTime.now().difference(pastTime);
    if (difference.inDays > 7) {
      int weeks = (difference.inDays / 7).floor();
      return _currentLang == 'EN' ? '$weeks ${_t('weeksAgo')}' : '$weeks ${_t('weeksAgo')}';
    }
    if (difference.inDays > 0) return '${difference.inDays} ${_t('daysAgo')}';
    if (difference.inHours > 0) return '${difference.inHours} ${_t('hoursAgo')}';
    if (difference.inMinutes > 0) return '${difference.inMinutes} ${_t('minsAgo')}';
    return _t('justNow');
  }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _isLoading = true;
      _diagnosisData = null;
    });

    try {
      final model = GenerativeModel(

        model: 'gemini-2.5-flash',
        apiKey: 'AIzaSyD7gMsGcyPxnqa5UVT-O4nFJIJy1WJYFKw',
      );

      final imageBytes = await image.readAsBytes();

      final content = [
        Content.multi([
          TextPart("""Identify the plant disease in this image.
          Provide the result ONLY as a JSON object with translations for English (EN), Sinhala (SI), and Tamil (TA). Use the exact following structure:
          {
            "cropName": { "EN": "Crop Name (e.g. Tomato)", "SI": "Crop Name in Sinhala", "TA": "Crop Name in Tamil" },
            "diseaseName": { "EN": "Disease Name in English", "SI": "Disease Name in Sinhala", "TA": "Disease Name in Tamil" },
            "severity": "HIGH", // HIGH, MEDIUM, or LOW
            "confidence": 92, // Integer
            "treatments": {
              "EN": ["Step 1 EN"], "SI": ["Step 1 SI"], "TA": ["Step 1 TA"]
            },
            "preventions": {
              "EN": ["Prevention 1 EN"], "SI": ["Prevention 1 SI"], "TA": ["Prevention 1 TA"]
            }
          }
          Do not include any formatting blocks like ```json. Just the raw JSON object."""),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);

      setState(() {

        String cleanText = response.text ?? "{}";

        int startIndex = cleanText.indexOf('{');
        int endIndex = cleanText.lastIndexOf('}');

        if (startIndex != -1 && endIndex != -1) {
          cleanText = cleanText.substring(startIndex, endIndex + 1);
        }

        try {
          _diagnosisData = json.decode(cleanText);
          _recentDiagnoses.insert(0, {
            'date': DateTime.now(),
            'data': _diagnosisData
          });
        } catch (formatError) {
          throw Exception("AI පිළිතුරේ දත්ත සැකැස්ම වැරදියි. නැවත උත්සාහ කරන්න.");
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error analyzing image: $e");


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("දෝෂයක් මතු විය: ${e.toString()}"),
            backgroundColor: Colors.red[700],
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _cancelDiagnosis() {
    setState(() {
      _selectedImage = null;
      _diagnosisData = null;
    });
  }

  Widget _langButton(String code, String text) {
    bool isSelected = _currentLang == code;
    return GestureDetector(
      onTap: () {
        setState(() { _currentLang = code; });
      },
      child: Text(
        text,
        style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_outlined, 'key': 'navHome'},
      {'icon': Icons.camera_alt_outlined, 'key': 'navDiagnose'},
      {'icon': Icons.shopping_bag_outlined, 'key': 'navMarket'},
      {'icon': Icons.grass_outlined, 'key': 'navCrops'},
      {'icon': Icons.cloud_outlined, 'key': 'navWeather'},
      {'icon': Icons.chat_bubble_outline, 'key': 'navForum'},
      {'icon': Icons.person_outline, 'key': 'navProfile'},
    ];

    int activeIndex = 1;

    return Container(
      height: 65,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1))
          ]
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: navItems.length,
        itemBuilder: (context, index) {
          bool isActive = index == activeIndex;
          final item = navItems[index];

          return InkWell(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width / 4.5,
              decoration: BoxDecoration(
                color: isActive ? Colors.green[50] : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item.containsKey('iconPath')
                      ? Image.asset(
                    item['iconPath'],
                    width: 24,
                    height: 24,
                    color: isActive ? Colors.green[700] : Colors.blueGrey[400],
                  )
                      : Icon(
                    item['icon'],
                    color: isActive ? Colors.green[700] : Colors.blueGrey[400],
                    size: 24,
                  ),
                  SizedBox(height: 4),
                  Text(
                    _t(item['key']),
                    style: TextStyle(
                        color: isActive ? Colors.green[700] : Colors.blueGrey[400],
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text('AgriMate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
          },
        ),
        actions: [
          Center(
              child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _langButton('SI', 'සිංහල'),
                      Text(" | ", style: TextStyle(color: Colors.white54)),
                      _langButton('TA', 'தமிழ்'),
                      Text(" | ", style: TextStyle(color: Colors.white54)),
                      _langButton('EN', 'EN'),
                    ],
                  )
              )
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade300, width: 1)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    )
                        : Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.green[700]),
                          SizedBox(height: 10),
                          Text(_t('takePhotoInfo'), style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500))
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    if (_selectedImage == null)
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.upload_file),
                        label: Text(_t('chooseBtn'), style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12), minimumSize: Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _analyzeImage(_selectedImage!),
                              child: Text(_t('diagnoseBtn')),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _cancelDiagnosis,
                              child: Text(_t('cancelBtn')),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[700], padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Colors.green[600]),
                        SizedBox(height: 15),
                        Text(_t('analyzing'), style: TextStyle(color: Colors.grey[700]))
                      ],
                    )
                ),
              ),

            if (_diagnosisData != null && !_isLoading) ...[
              SizedBox(height: 20),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200, width: 1)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                                _diagnosisData!['diseaseName'][_currentLang] ?? _t('unknown'),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: _getSeverityColor(_diagnosisData!['severity'] ?? 'LOW').withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                                "${_diagnosisData!['severity'] ?? 'N/A'} SEVERITY",
                                style: TextStyle(color: _getSeverityColor(_diagnosisData!['severity'] ?? 'LOW'), fontSize: 10, fontWeight: FontWeight.bold)
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("${_t('confidence')}: ${_diagnosisData!['confidence'] ?? 0}%", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: (_diagnosisData!['confidence'] ?? 0) / 100, backgroundColor: Colors.grey[200], color: Colors.green[500], minHeight: 6, borderRadius: BorderRadius.circular(3))
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200, width: 1)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 20)),
                          SizedBox(width: 12),
                          Text(_t('treatment'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (_diagnosisData!['treatments'][_currentLang] != null)
                        ...List.generate(
                            (_diagnosisData!['treatments'][_currentLang] as List).length,
                                (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(radius: 12, backgroundColor: Colors.green[50], child: Text("${index + 1}", style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold))),
                                  SizedBox(width: 12),
                                  Expanded(child: Text(_diagnosisData!['treatments'][_currentLang][index].toString(), style: TextStyle(color: Colors.blueGrey[800], height: 1.4, fontSize: 14)))
                                ],
                              ),
                            )
                        )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              if (_diagnosisData!['preventions'][_currentLang] != null)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200, width: 1)),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.check_circle_outline, color: Colors.green[700], size: 20)),
                            SizedBox(width: 12),
                            Text(_t('prevention'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                          ],
                        ),
                        SizedBox(height: 20),
                        ...List.generate(
                            (_diagnosisData!['preventions'][_currentLang] as List).length,
                                (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green[500], size: 22),
                                  SizedBox(width: 12),
                                  Expanded(child: Text(_diagnosisData!['preventions'][_currentLang][index].toString(), style: TextStyle(color: Colors.blueGrey[800], height: 1.4, fontSize: 14)))
                                ],
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                )
            ],

            if (_recentDiagnoses.isNotEmpty) ...[
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(_t('recentDiagnoses'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
              ),
              SizedBox(height: 15),

              ..._recentDiagnoses.map((item) {
                final data = item['data'];
                final date = item['date'] as DateTime;

                return Card(
                  elevation: 0,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                data['cropName'] != null ? data['cropName'][_currentLang] ?? 'Plant' : 'Plant',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])
                            ),
                            SizedBox(height: 4),
                            Text(
                                data['diseaseName'] != null ? data['diseaseName'][_currentLang] ?? 'Unknown' : 'Unknown',
                                style: TextStyle(fontSize: 14, color: Colors.blueGrey[600])
                            ),
                          ],
                        ),
                        Text(
                            _timeAgo(date),
                            style: TextStyle(fontSize: 13, color: Colors.grey[500])
                        )
                      ],
                    ),
                  ),
                );
              }).toList()
            ],
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Color _getSeverityColor(String severity) {
    switch(severity.toUpperCase()) {
      case 'HIGH': return Colors.red;
      case 'MEDIUM': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }
}