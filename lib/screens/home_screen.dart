import 'dart:ui';
import 'package:al_hafidz/globals.dart';
import 'package:al_hafidz/screens/doa_page.dart';
import 'package:al_hafidz/screens/prayer_times_screen.dart';
import 'package:al_hafidz/tabs/surah_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index untuk halaman BottomNavigationBar
  int _selectedIndex = 0;

  // Controller untuk PageView

  // Method untuk berpindah halaman saat bottom navigation di-klik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      // Ketika tombol Doa (index 3) diklik
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PrayerTimesScreen()), // Navigasi ke halaman DoaPage
      );
    }
    if (index == 2) {
      // Ketika tombol Doa (index 3) diklik
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DoaPage()), // Navigasi ke halaman DoaPage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: background,
    appBar: _appbar(),
    bottomNavigationBar: _bottomNavigationBar(),
    body: DefaultTabController(
      length: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _greeting(),
            ),
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: background,
              automaticallyImplyLeading: false,
              shape: Border(
                bottom: BorderSide(
                  width: 3,
                  color: const Color(0xffaaaaaa).withOpacity(.1),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: _tab(),
              ),
            )
          ],
          // Mengganti PageView dengan konten yang tidak bisa digeser
          body: _selectedIndex == 0
              ? TabBarView(
                  physics: const NeverScrollableScrollPhysics(), // Mengunci geseran
                  children: [
                    SurahTab(),  // Konten untuk SurahTab yang bisa menggunakan TabBarView di dalamnya
                  ],
                )
              : Center(
                  child: _getPageContent(_selectedIndex),
                ),
        ),
      ),
    ),
  );
}

Widget _getPageContent(int index) {
  switch (index) {
    case 1:
      return Text('Tips Page'); // Placeholder untuk halaman Tips
    case 2:
      return Text('Prayer Page'); // Placeholder untuk halaman Prayer
    case 3:
      return Text('Doa Page'); // Placeholder untuk halaman Doa
    case 4:
      return Text('Bookmark Page'); // Placeholder untuk halaman Bookmark
    default:
      return Text('Unknown Page'); // Placeholder untuk halaman yang tidak diketahui
  }
}


  TabBar _tab() {
    return TabBar(
      unselectedLabelColor: text,
      labelColor: Colors.white,
      indicatorColor: primary,
     
      tabs: [
        _tabItem(label: "Surah"),

  

      ],
    );
  }

  Tab _tabItem({required String label}) => Tab(
        child: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );

  Column _greeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assalamualaikum",
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w500, color: text),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          "Calon Pengguni surga",
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(
          height: 24,
        ),
        _LastRead()
      ],
    );
  }

  Stack _LastRead() {
    return Stack(
      children: [
        Container(
            height: 131,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, .6, 1],
                  colors: [
                    Color(0xffdf98fa), // Warna pertama
                    Color(0xffb070fd), // Warna kedua
                    Color(0xff9055ff) // Warna ketiga
                  ],
                ))),
        Positioned(
            bottom: 0,
            right: 0,
            child: SvgPicture.asset('assets/svgs/quran.svg')),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/svgs/book.svg'),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Last Read',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Al-Fatihah',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                'Ayat No. 1',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  AppBar _appbar() => AppBar(
        backgroundColor: background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
                onPressed: (() => {}),
                icon: SvgPicture.asset('assets/svgs/menu-icon.svg')),
            const SizedBox(
              width: 24,
            ),
            Text(
              'Al-Hafidz',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Spacer(),
            IconButton(
                onPressed: (() => {}),
                icon: SvgPicture.asset('assets/svgs/search-icon.svg')),
          ],
        ),
      );

  BottomNavigationBar _bottomNavigationBar() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: gray,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Menambahkan fungsi untuk navigasi
        items: [
          _bottomBarItem(icon: "assets/svgs/quran-icon.svg", label: "quran"),
          
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
}
