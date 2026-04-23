import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shared_components.dart';

class TodaysRecommendationsSection extends StatelessWidget {
  final String temperature;
  final String humidity;
  final String windSpeed;
  final String language;

  const TodaysRecommendationsSection({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.language,
  });

  String _t(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'title': "Today's Recommendations",
        // High temperature tips
        'high_temp_tip':
            'High temperature ({{temp}}°C). Water crops early morning or late evening to reduce evaporation.',
        // Ideal temperature tips
        'ideal_temp_tip':
            'Ideal temperature ({{temp}}°C) for most crops. Good day for transplanting seedlings.',
        // Mild temperature tips
        'mild_temp_tip':
            'Mild temperature ({{temp}}°C). Suitable for cool-season crops like cabbage, carrots and lettuce.',
        // Cool temperature tips
        'cool_temp_tip':
            'Cool temperature ({{temp}}°C). Protect sensitive crops from cold stress with mulching.',
        // High humidity tips
        'high_humidity_tip':
            'Very high humidity ({{hum}}%). High risk of fungal diseases — apply preventive fungicide and improve airflow.',
        // Moderate humidity tips
        'moderate_humidity_tip':
            'Moderate humidity ({{hum}}%). Monitor crops for early signs of leaf blight or mildew.',
        // Good humidity tips
        'good_humidity_tip':
            'Good humidity level ({{hum}}%). Maintain regular irrigation schedule.',
        // Low humidity tips
        'low_humidity_tip':
            'Low humidity ({{hum}}%). Increase irrigation frequency. Mulch soil to retain moisture.',
        // Low wind tips
        'low_wind_tip':
            'Low wind ({{wind}} km/h). Good conditions for spraying fertilizer or pesticides today.',
        // Moderate wind tips
        'moderate_wind_tip':
            'Moderate wind ({{wind}} km/h). Avoid spraying chemicals — solution may drift away from crops.',
        // Strong wind tips
        'strong_wind_tip':
            'Strong winds ({{wind}} km/h). Secure greenhouse covers and young plants. Avoid field operations.',
        // Pest activity tip
        'pest_tip':
            'Warm and humid conditions — ideal for pest activity. Scout fields for insects today.',
        // Favorable weather tip
        'favorable_tip':
            'Overall favorable weather. Good day for harvesting mature crops.',
      },
      'SI': {
        'title': 'අද දින නිර්දේශ',
        'high_temp_tip':
            'අධික උෂ්ණත්වය ({{temp}}°C). වාෂ්පීකරණය අඩු කිරීම සඳහා උදෑසන හෝ සවස බෝග වලට වතුර දමන්න.',
        'ideal_temp_tip':
            'බොහෝ බෝග සඳහා කදිම උෂ්ණත්වය ({{temp}}°C). බීජ පැල සිටුවීමට සුදුසු දිනයකි.',
        'mild_temp_tip':
            'මෘදු උෂ්ණත්වය ({{temp}}°C). ගෝවා, කැරට් සහ සලාද කොළ වැනි සිසිල් කාලගුණික බෝග සඳහා සුදුසුයි.',
        'cool_temp_tip':
            'සිසිල් උෂ්ණත්වය ({{temp}}°C). වසුන් යෙදීමෙන් සංවේදී බෝග සීතල ආතතියෙන් ආරක්ෂා කරන්න.',
        'high_humidity_tip':
            'ඉතා ඉහළ ආර්ද්රතාවය ({{hum}}%). දිලීර රෝග ඇතිවීමේ ඉහළ අවදානමක් — වැළැක්වීමේ දිලීර නාශක යොදන්න සහ වාතය ගලායාම වැඩි දියුණු කරන්න.',
        'moderate_humidity_tip':
            'මධ්යස්ථ ආර්ද්රතාවය ({{hum}}%). කොළ මැලවීම හෝ කෝඩු රෝගයේ මුල් සලකුණු සඳහා බෝග නිරීක්ෂණය කරන්න.',
        'good_humidity_tip':
            'හොඳ ආර්ද්රතා මට්ටම ({{hum}}%). නිතිපතා වාරිමාර්ග කාලසටහන පවත්වා ගන්න.',
        'low_humidity_tip':
            'අඩු ආර්ද්රතාවය ({{hum}}%). වාරිමාර්ග සංඛ්යාතය වැඩි කරන්න. තෙතමනය රඳවා ගැනීමට පස වසුන් කරන්න.',
        'low_wind_tip':
            'අඩු සුළඟ ({{wind}} km/h). අද පොහොර හෝ පළිබෝධනාශක ඉසීම සඳහා හොඳ කොන්දේසි.',
        'moderate_wind_tip':
            'මධ්යස්ථ සුළඟ ({{wind}} km/h). රසායනික ද්රව්ය ඉසීමෙන් වළකින්න — විසඳුම බෝග වලින් ඉවතට ගසාගෙන යා හැක.',
        'strong_wind_tip':
            'තද සුළං ({{wind}} km/h). හරිතාගාර ආවරණ සහ තරුණ පැල ආරක්ෂා කරන්න. ක්ෂේත්ර මෙහෙයුම් වලින් වළකින්න.',
        'pest_tip':
            'උණුසුම් හා තෙතමනය සහිත තත්වයන් — පළිබෝධ ක්‍රියාකාරකම් සඳහා සුදුසුයි. අද කෘමීන් සඳහා කෙත්වතු පරීක්ෂා කරන්න.',
        'favorable_tip':
            'සමස්තයක් ලෙස හිතකර කාලගුණය. පරිණත බෝග අස්වනු නෙලීමට සුදුසු දිනයකි.',
      },
      'TA': {
        'title': 'இன்றைய பரிந்துரைகள்',
        'high_temp_tip':
            'அதிக வெப்பநிலை ({{temp}}°C). ஆவியாதலைக் குறைக்க காலை அல்லது மாலை வேளையில் பயிர்களுக்கு தண்ணீர் பாய்ச்சவும்.',
        'ideal_temp_tip':
            'பெரும்பாலான பயிர்களுக்கு ஏற்ற வெப்பநிலை ({{temp}}°C). நாற்றுகளை நடவு செய்ய நல்ல நாள்.',
        'mild_temp_tip':
            'லேசான வெப்பநிலை ({{temp}}°C). முட்டைக்கோஸ், கேரட் மற்றும் கீரை போன்ற குளிர்-பருவ பயிர்களுக்கு ஏற்றது.',
        'cool_temp_tip':
            'குளிர்ந்த வெப்பநிலை ({{temp}}°C). தழைக்கூளம் போடுவதன் மூலம் உணர்திறன் பயிர்களை குளிர் அழுத்தத்திலிருந்து பாதுகாக்கவும்.',
        'high_humidity_tip':
            'மிக அதிக ஈரப்பதம் ({{hum}}%). பூஞ்சை நோய்களின் அதிக ஆபத்து — தடுப்பு பூஞ்சைக் கொல்லியைப் பயன்படுத்துங்கள் மற்றும் காற்றோட்டத்தை மேம்படுத்துங்கள்.',
        'moderate_humidity_tip':
            'மிதமான ஈரப்பதம் ({{hum}}%). இலை கருகல் அல்லது படர்தாமரையின் ஆரம்ப அறிகுறிகளுக்கு பயிர்களை கண்காணிக்கவும்.',
        'good_humidity_tip':
            'நல்ல ஈரப்பதம் நிலை ({{hum}}%). வழக்கமான பாசன அட்டவணையை பராமரிக்கவும்.',
        'low_humidity_tip':
            'குறைந்த ஈரப்பதம் ({{hum}}%). பாசன அதிர்வெண்ணை அதிகரிக்கவும். ஈரப்பதத்தைத் தக்கவைக்க மண்ணைத் தழைக்கூளம் செய்யவும்.',
        'low_wind_tip':
            'குறைந்த காற்று ({{wind}} km/h). இன்று உரம் அல்லது பூச்சிக்கொல்லிகளை தெளிப்பதற்கு நல்ல நிலைமைகள்.',
        'moderate_wind_tip':
            'மிதமான காற்று ({{wind}} km/h). ரசாயனங்களை தெளிப்பதைத் தவிர்க்கவும் — கரைசல் பயிர்களிலிருந்து விலகிச் செல்லக்கூடும்.',
        'strong_wind_tip':
            'பலத்த காற்று ({{wind}} km/h). பசுமை இல்ல அட்டைகள் மற்றும் இளம் தாவரங்களைப் பாதுகாக்கவும். கள நடவடிக்கைகளைத் தவிர்க்கவும்.',
        'pest_tip':
            'வெப்பமான மற்றும் ஈரப்பதமான நிலைமைகள் — பூச்சி செயல்பாட்டிற்கு ஏற்றது. இன்று பூச்சிகளுக்கு வயல்களை ஆய்வு செய்யுங்கள்.',
        'favorable_tip':
            'ஒட்டுமொத்த சாதகமான வானிலை. முதிர்ந்த பயிர்களை அறுவடை செய்வதற்கு நல்ல நாள்.',
      },
    };

    String text = translations[language]?[key] ?? translations['EN']![key]!;
    // Replace placeholders
    text = text.replaceAll('{{temp}}', temperature);
    text = text.replaceAll('{{hum}}', humidity);
    text = text.replaceAll('{{wind}}', windSpeed);
    return text;
  }

  List<Map<String, dynamic>> _getRecommendations() {
    List<Map<String, dynamic>> tips = [];
    int temp = int.tryParse(temperature) ?? 25;
    int hum = int.tryParse(humidity) ?? 60;
    int wind = int.tryParse(windSpeed) ?? 10;

    if (temp >= 30) {
      tips.add({
        'text': _t('high_temp_tip'),
        'icon': Icons.thermostat_rounded,
        'color': AppColors.warmOrange,
      });
    } else if (temp >= 22 && temp < 30) {
      tips.add({
        'text': _t('ideal_temp_tip'),
        'icon': Icons.check_circle_outline_rounded,
        'color': AppColors.accent,
      });
    } else if (temp >= 15 && temp < 22) {
      tips.add({
        'text': _t('mild_temp_tip'),
        'icon': Icons.eco_rounded,
        'color': AppColors.accentDark,
      });
    } else if (temp < 15) {
      tips.add({
        'text': _t('cool_temp_tip'),
        'icon': Icons.ac_unit_rounded,
        'color': AppColors.coolBlue,
      });
    }

    if (hum >= 80) {
      tips.add({
        'text': _t('high_humidity_tip'),
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.alertAmber,
      });
    } else if (hum >= 60 && hum < 80) {
      tips.add({
        'text': _t('moderate_humidity_tip'),
        'icon': Icons.water_drop_outlined,
        'color': AppColors.coolBlue,
      });
    } else if (hum >= 40 && hum < 60) {
      tips.add({
        'text': _t('good_humidity_tip'),
        'icon': Icons.opacity_rounded,
        'color': AppColors.accent,
      });
    } else if (hum < 40) {
      tips.add({
        'text': _t('low_humidity_tip'),
        'icon': Icons.water_drop_outlined,
        'color': AppColors.alertAmber,
      });
    }

    if (wind <= 15) {
      tips.add({
        'text': _t('low_wind_tip'),
        'icon': Icons.air_rounded,
        'color': AppColors.accent,
      });
    } else if (wind > 15 && wind <= 30) {
      tips.add({
        'text': _t('moderate_wind_tip'),
        'icon': Icons.air_rounded,
        'color': AppColors.alertAmber,
      });
    } else {
      tips.add({
        'text': _t('strong_wind_tip'),
        'icon': Icons.storm_rounded,
        'color': AppColors.alertRed,
      });
    }

    if (temp >= 25 && hum >= 70) {
      tips.add({
        'text': _t('pest_tip'),
        'icon': Icons.bug_report_outlined,
        'color': AppColors.alertAmber,
      });
    }

    if (temp >= 20 && temp <= 28 && hum >= 50 && hum < 75 && wind <= 20) {
      tips.add({
        'text': _t('favorable_tip'),
        'icon': Icons.agriculture_rounded,
        'color': AppColors.accent,
      });
    }

    return tips;
  }

  @override
  Widget build(BuildContext context) {
    final tips = _getRecommendations();
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: _t('title'),
            icon: Icons.tips_and_updates_rounded,
            iconColor: AppColors.accent,
            language: language,
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            final tip = entry.value;
            final Color tipColor = tip['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceLight,
                      AppColors.surfaceMid.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tipColor.withValues(alpha: 0.22),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: tipColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: tipColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        tip['icon'] as IconData,
                        color: tipColor,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          tip['text'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
