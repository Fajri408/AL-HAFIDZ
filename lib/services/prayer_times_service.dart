import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  // API endpoint untuk mengambil waktu sholat untuk Jakarta, Indonesia
  final String apiUrl =
      'http://api.aladhan.com/v1/timingsByCity?city=Jakarta&country=Indonesia&method=2';

  // Data statis waktu sholat untuk kota Jakarta
  final Map<String, String> prayerTimes = {
    'Fajr': '04:23',
    'Dhuhr': '11:52',
    'Asr': '15:21',
    'Maghrib': '17:58',
    'Isha': '19:16'
  };

  // Fungsi untuk mengambil waktu sholat dari API
  Future<Map<String, String>> fetchPrayerTimes() async {
    try {
      // Melakukan request ke API untuk mendapatkan waktu sholat
      final response = await http.get(Uri.parse(apiUrl));

      // Jika request berhasil dan status code adalah 200
      if (response.statusCode == 200) {
        // Mengubah data JSON menjadi Map
        final data = json.decode(response.body);

        // Menyusun data waktu sholat dari response API
        Map<String, String> fetchedPrayerTimes = {
          'Fajr': data['data']['timings']['Fajr'],
          'Dhuhr': data['data']['timings']['Dhuhr'],
          'Asr': data['data']['timings']['Asr'],
          'Maghrib': data['data']['timings']['Maghrib'],
          'Isha': data['data']['timings']['Isha'],
        };

        return fetchedPrayerTimes; // Mengembalikan waktu sholat yang diambil dari API
      } else {
        // Jika terjadi error (misalnya status code bukan 200)
        print('Failed to load prayer times: ${response.statusCode}');
        return prayerTimes; // Mengembalikan data statis jika terjadi error
      }
    } catch (e) {
      // Jika terjadi exception (misalnya masalah jaringan)
      print('Error fetching prayer times: $e');
      return prayerTimes; // Mengembalikan data statis jika terjadi error
    }
  }
}
