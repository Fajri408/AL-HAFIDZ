import 'dart:convert';  
import 'package:http/http.dart' as http;  

class PrayerTimesService {  
  // Data statis waktu sholat untuk kota Jakarta  
  final Map<String, String> prayerTimes = {  
    'Fajr': '04:30',  
    'Dhuhr': '11:45',  
    'Asr': '15:15',  
    'Maghrib': '17:45',  
    'Isha': '19:00'  
  };  

  Future<Map<String, String>> fetchPrayerTimes() async {  
    // Mengembalikan data waktu sholat statis sebagai hasil simulasi API  
    return Future.value(prayerTimes);  
  }  
}  