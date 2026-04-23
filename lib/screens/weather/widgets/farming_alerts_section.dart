import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shared_components.dart';

class FarmingAlertsSection extends StatelessWidget {
  final String temperature;
  final String humidity;
  final String windSpeed;
  final List<dynamic> forecastData;
  final String language;

  const FarmingAlertsSection({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.forecastData,
    required this.language,
  });

  String _t(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'title': 'Farming Alerts',
        'rain_alert':
            'Rainy conditions expected in the next few days. Check your drainage systems.',
        'high_temp_alert':
            'High temperature ({{temp}}°C)! Provide shade for young plants and supply extra water.',
        'low_temp_alert':
            'Low temperatures detected ({{temp}}°C). Apply mulch to protect crops from the cold.',
        'high_humidity_alert':
            'Very high humidity ({{hum}}%)! High risk of fungal diseases spreading. Monitor your crops closely.',
        'strong_wind_alert':
            'Strong winds ({{wind}} km/h). Protect greenhouses and tall crops from wind damage.',
        'no_risk_alert':
            'No significant weather risks at the moment. Favorable conditions for farming today!',
      },
      'SI': {
        'title': 'ගොවිතැන් අනතුරු ඇඟවීම්',
        'rain_alert':
            'ඉදිරි දින කිහිපය තුළ වැසි සහිත කාලගුණයක් අපේක්ෂා කෙරේ. ඔබේ ජලාපවහන පද්ධති පරීක්ෂා කරන්න.',
        'high_temp_alert':
            'අධික උෂ්ණත්වය ({{temp}}°C)! තරුණ පැල සඳහා සෙවන සපයන්න සහ අමතර ජලය සපයන්න.',
        'low_temp_alert':
            'අඩු උෂ්ණත්වයක් අනාවරණය විය ({{temp}}°C). සීතලෙන් බෝග ආරක්ෂා කර ගැනීමට වසුන් යොදන්න.',
        'high_humidity_alert':
            'ඉතා ඉහළ ආර්ද්රතාවය ({{hum}}%)! දිලීර රෝග පැතිරීමේ ඉහළ අවදානමක්. ඔබේ බෝග සමීපව නිරීක්ෂණය කරන්න.',
        'strong_wind_alert':
            'තද සුළං ({{wind}} km/h). සුළං හානිවලින් හරිතාගාර සහ උස බෝග ආරක්ෂා කරන්න.',
        'no_risk_alert':
            'මේ මොහොතේ සැලකිය යුතු කාලගුණික අවදානම් නොමැත. අද ගොවිතැනට හිතකර කොන්දේසි!',
      },
      'TA': {
        'title': 'விவசாய எச்சரிக்கைகள்',
        'rain_alert':
            'அடுத்த சில நாட்களில் மழை பெய்யும். உங்கள் வடிகால் அமைப்புகளை சரிபார்க்கவும்.',
        'high_temp_alert':
            'அதிக வெப்பநிலை ({{temp}}°C)! இளம் தாவரங்களுக்கு நிழல் கொடுங்கள் மற்றும் கூடுதல் தண்ணீர் கொடுங்கள்.',
        'low_temp_alert':
            'குறைந்த வெப்பநிலை கண்டறியப்பட்டது ({{temp}}°C). குளிர்ச்சியிலிருந்து பயிர்களைப் பாதுகாக்க தழைக்கூளம் போடவும்.',
        'high_humidity_alert':
            'அதிக ஈரப்பதம் ({{hum}}%)! பூஞ்சை நோய்கள் பரவும் அதிக ஆபத்து. உங்கள் பயிர்களை உன்னிப்பாக கண்காணிக்கவும்.',
        'strong_wind_alert':
            'பலத்த காற்று ({{wind}} km/h). காற்று சேதத்திலிருந்து பசுமை இல்லங்கள் மற்றும் உயரமான பயிர்களைப் பாதுகாக்கவும்.',
        'no_risk_alert':
            'இப்போது குறிப்பிடத்தக்க வானிலை ஆபத்துகள் இல்லை. இன்று விவசாயத்திற்கு சாதகமான நிலைமைகள்!',
      },
    };

    String text = translations[language]?[key] ?? translations['EN']![key]!;
    // Replace placeholders
    text = text.replaceAll('{{temp}}', temperature);
    text = text.replaceAll('{{hum}}', humidity);
    text = text.replaceAll('{{wind}}', windSpeed);
    return text;
  }

  List<Map<String, dynamic>> _getDynamicAlerts() {
    List<Map<String, dynamic>> alerts = [];
    int temp = int.tryParse(temperature) ?? 25;
    int hum = int.tryParse(humidity) ?? 60;
    int wind = int.tryParse(windSpeed) ?? 10;

    bool hasRain = false;
    for (var item in forecastData) {
      var weatherList = item['weather'];
      String weatherCondition = (weatherList is List && weatherList.isNotEmpty)
          ? weatherList[0]['main']?.toString().toLowerCase() ?? ""
          : "";
      if (weatherCondition.contains("rain") ||
          weatherCondition.contains("storm") ||
          weatherCondition.contains("thunderstorm")) {
        hasRain = true;
        break;
      }
    }

    if (hasRain) {
      alerts.add({
        'text': _t('rain_alert'),
        'icon': Icons.umbrella_rounded,
        'color': AppColors.coolBlue,
        'bgColor': const Color(0xFFEFF8FF),
        'borderColor': const Color(0xFFBFE3F9),
      });
    }

    if (temp >= 35) {
      alerts.add({
        'text': _t('high_temp_alert'),
        'icon': Icons.thermostat_rounded,
        'color': AppColors.alertRed,
        'bgColor': const Color(0xFFFFF5F5),
        'borderColor': const Color(0xFFFECACA),
      });
    } else if (temp <= 15) {
      alerts.add({
        'text': _t('low_temp_alert'),
        'icon': Icons.ac_unit_rounded,
        'color': AppColors.coolBlue,
        'bgColor': const Color(0xFFEFF8FF),
        'borderColor': const Color(0xFFBFE3F9),
      });
    }

    if (hum >= 80) {
      alerts.add({
        'text': _t('high_humidity_alert'),
        'icon': Icons.water_drop_rounded,
        'color': AppColors.alertAmber,
        'bgColor': AppColors.alertAmberBg,
        'borderColor': AppColors.alertAmberBorder,
      });
    }

    if (wind >= 30) {
      alerts.add({
        'text': _t('strong_wind_alert'),
        'icon': Icons.storm_rounded,
        'color': AppColors.alertRed,
        'bgColor': const Color(0xFFFFF5F5),
        'borderColor': const Color(0xFFFECACA),
      });
    }

    if (alerts.isEmpty) {
      alerts.add({
        'text': _t('no_risk_alert'),
        'icon': Icons.check_circle_rounded,
        'color': AppColors.accent,
        'bgColor': AppColors.accentGlow,
        'borderColor': AppColors.accentBorder,
      });
    }

    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final currentAlerts = _getDynamicAlerts();

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: _t('title'),
            icon: Icons.notification_important_rounded,
            iconColor: AppColors.alertAmber,
            language: language,
          ),
          const SizedBox(height: 16),
          ...currentAlerts.map((alert) {
            final color = alert['color'] as Color;
            final bgColor =
                alert['bgColor'] as Color? ?? color.withValues(alpha: 0.07);
            final borderColor =
                alert['borderColor'] as Color? ?? color.withValues(alpha: 0.25);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        alert['icon'] as IconData,
                        color: color,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          alert['text'] as String,
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
