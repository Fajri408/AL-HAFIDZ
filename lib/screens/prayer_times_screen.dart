import 'dart:async';
import 'package:al_hafidz/globals.dart';
import 'package:al_hafidz/screens/doa_page.dart';
import 'package:al_hafidz/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
import '../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, dynamic>? prayerTimes;
  bool isLoading = true;
  int _selectedIndex = 1;

  DateTime? lastAzanPlayed;
  DateTime currentTime = DateTime.now();
  Timer? timer;

  bool isPlayingAzan = false;
  bool hasShownNotification = false;

  final List<String> prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
  final List<String> customPrayerNames = [
    "Subuh",
    "Dzuhur",
    "Asar",
    "Maghrib",
    "Isya"
  ];

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
    startClock();

    // Cegah pemutaran ulang saat kembali ke halaman jika adzan masih aktif
    if (isPlayingAzan) {
      print("Adzan sedang aktif, tidak akan diputar ulang.");
    } else {
      print("Adzan tidak aktif.");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void checkForAzanTime() {
    if (prayerTimes == null || isPlayingAzan) return;

    for (String prayer in prayerNames) {
      String? prayerTimeString = prayerTimes![prayer];
      if (prayerTimeString != null) {
        DateTime? prayerTime = DateTime.tryParse("1970-01-01 $prayerTimeString");

        if (prayerTime != null && _isNow(prayerTime)) {
          if (lastAzanPlayed != null &&
              currentTime.difference(lastAzanPlayed!).inMinutes < 1) {
            print("Adzan baru saja diputar/dihentikan. Tidak akan diputar ulang.");
            return;
          }

          playAzan();
          lastAzanPlayed = currentTime;
          break;
        }
      }
    }
  }

  Future<void> fetchPrayerTimes() async {
    try {
      Map<String, dynamic> times = await _prayerTimesService.fetchPrayerTimes();
      print("Data prayer times yang diambil: $times");
      setState(() {
        prayerTimes = times;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching prayer times: $e");
    }
  }

  void startClock() {
    if (timer != null && timer!.isActive) {
      print("Timer sudah berjalan.");
      return;
    }

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now();
      });
      checkForAzanTime();
    });
  }

  bool _isNow(DateTime prayerTime) {
    return currentTime.hour == prayerTime.hour &&
        currentTime.minute == prayerTime.minute;
  }

  Future<void> playAzan() async {
    if (isPlayingAzan) {
      print("Adzan sedang aktif. Tidak akan diputar ulang.");
      return;
    }

    print("Playing Azan sound");
    setState(() => isPlayingAzan = true);
    await _audioPlayer.play(AssetSource('audio/azan.mp3'));

    _showAzanNotification();
  }

  void _showAzanNotification() {
    if (hasShownNotification) return;
    setState(() => hasShownNotification = true);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Waktu Azan'),
          content: Text('Azan sedang diputar. Tekan "Matikan" untuk berhenti.'),
          actions: [
            TextButton(
              onPressed: () {
                _stopAzan();
                Navigator.of(context).pop();
              },
              child: Text('Matikan'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() => hasShownNotification = false);
    });
  }

  Future<void> _stopAzan() async {
    await _audioPlayer.stop();
    setState(() {
      isPlayingAzan = false;
      lastAzanPlayed = currentTime;
      print("Adzan dihentikan oleh pengguna.");
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrayerTimesScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoaPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jadwal Sholat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: background,
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF040C23),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 32.0),
                  itemCount: prayerNames.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildCurrentTimeCard();
                    } else if (index == 1) {
                      return SizedBox(height: 100);
                    }
                    String displayName = customPrayerNames[index - 2];
                    String time = prayerTimes![prayerNames[index - 2]] ?? "-";
                    return buildPrayerTimeRow(displayName, time);
                  },
                ),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  BottomNavigationBar _bottomNavigationBar() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: gray,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          _bottomBarItem(icon: "assets/svgs/quran-icon.svg", label: "Quran"),
          _bottomBarItem(icon: "assets/svgs/pray-icon.svg", label: "Prayer"),
          _bottomBarItem(icon: "assets/svgs/doa-icon.svg", label: "Doa"),
        ],
      );

  BottomNavigationBarItem _bottomBarItem(
          {required String icon, required String label}) =>
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          icon,
          color: text,
        ),
        activeIcon: SvgPicture.asset(
          icon,
          color: primary,
        ),
        label: label,
      );

  Widget buildCurrentTimeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:${currentTime.second.toString().padLeft(2, '0')}",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPrayerTimeRow(String name, String time) {
    return Card(
      color: const Color(0xFF121931),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        trailing: Text(
          time,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
