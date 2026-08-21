import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  Map<String, dynamic>? quranData;
  bool isLoading = true;
  int currentPage = 1;
  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredSurahs = [];
  List<int> filteredJuzs = [];
  int _selectedTab = 0; // 0: Surahs, 1: Juzs, 2: Pages

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadQuranData();
  }

  Future<void> _loadQuranData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/quran_data.json');
      final data = json.decode(response);
      setState(() {
        quranData = data;
        filteredSurahs = data['surahs'];
        filteredJuzs = List.generate(30, (i) => i + 1);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading quran data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterData(String query) {
    if (quranData == null) return;
    setState(() {
      if (_selectedTab == 0) {
        if (query.isEmpty) {
          filteredSurahs = quranData!['surahs'];
        } else {
          filteredSurahs = (quranData!['surahs'] as List).where((surah) {
            final name = surah['name'].toString().toLowerCase();
            final nameEn = surah['name_en'].toString().toLowerCase();
            final num = surah['number'].toString();
            return name.contains(query.toLowerCase()) ||
                nameEn.contains(query.toLowerCase()) ||
                num == query;
          }).toList();
        }
      } else if (_selectedTab == 1) {
        if (query.isEmpty) {
          filteredJuzs = List.generate(30, (i) => i + 1);
        } else {
          filteredJuzs = List.generate(30, (i) => i + 1)
              .where((juz) => juz.toString().contains(query))
              .toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quranData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('quran'.tr(context))),
        body: const Center(child: Text('خطأ في تحميل بيانات المصحف')),
      );
    }

    final totalPages = quranData!['mushaf']['total_pages'] as int;
    final baseUrl = quranData!['cdn']['base_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'holy_quran_title'.tr(context),
          style: TextStyle(
              color: ColorsManager.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: ColorsManager.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted,
                color: ColorsManager.primaryColor),
            onPressed: _showNavigationMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              reverse: true, // Mushaf navigation is RTL
              onPageChanged: (index) {
                setState(() {
                  currentPage = index + 1;
                });
              },
              itemBuilder: (context, index) {
                final pageNum = (index + 1).toString().padLeft(3, '0');
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: '$baseUrl/madina/$pageNum.png',
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, dynamic error) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_outlined,
                                  size: 64.sp, color: Colors.grey),
                              SizedBox(height: 16.h),
                              Text('خطأ في تحميل الصفحات من السيرفر',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14.sp)),
                              TextButton(
                                onPressed: () => setState(() {}),
                                child: const Text('إعادة المحاولة'),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                    Icons.chevron_left,
                    () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut)),
                Column(
                  children: [
                    Text(
                      'صفحة $currentPage من $totalPages',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.primaryColor,
                          fontSize: 14.sp),
                    ),
                    Text(
                      _getSurahForPage(currentPage),
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 11.sp),
                    ),
                  ],
                ),
                _buildNavButton(
                    Icons.chevron_right,
                    () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSurahForPage(int page) {
    if (quranData == null) return '';
    final surahs = quranData!['surahs'] as List;
    for (var surah in surahs) {
      if (page >= surah['start_page'] && page <= surah['end_page']) {
        return 'سورة ${surah['name']}';
      }
    }
    return '';
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
          color: ColorsManager.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r)),
      child: IconButton(
          icon: Icon(icon, color: ColorsManager.primaryColor),
          onPressed: onPressed),
    );
  }

  void _showNavigationMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 0.85.sh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r))),
                  SizedBox(height: 20.h),
                  // Custom Tab Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        _buildTabItem('السور', 0, setModalState),
                        _buildTabItem('الأجزاء', 1, setModalState),
                        _buildTabItem('الصفحات', 2, setModalState),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Search Bar
                  if (_selectedTab != 2)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: _selectedTab == 0
                              ? 'بحث عن سورة...'
                              : 'بحث عن جزء...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide: BorderSide.none),
                        ),
                        onChanged: (val) {
                          _filterData(val);
                          setModalState(() {});
                        },
                      ),
                    ),
                  SizedBox(height: 10.h),
                  Expanded(child: _buildTabContent(setModalState)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabItem(String label, int index, StateSetter setModalState) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            _selectedTab = index;
            _searchController.clear();
            _filterData('');
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: isSelected
                        ? ColorsManager.primaryColor
                        : Colors.transparent,
                    width: 2)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? ColorsManager.primaryColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(StateSetter setModalState) {
    if (_selectedTab == 0) {
      return ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: filteredSurahs.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final surah = filteredSurahs[index];
          return ListTile(
            leading: CircleAvatar(
                backgroundColor:
                    ColorsManager.primaryColor.withValues(alpha: 0.1),
                child: Text('${surah['number']}',
                    style: TextStyle(
                        fontSize: 12.sp, color: ColorsManager.primaryColor))),
            title: Text(surah['name'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('صفحة ${surah['start_page']}'),
            onTap: () {
              Navigator.pop(context);
              _pageController.jumpToPage(surah['start_page'] - 1);
            },
          );
        },
      );
    } else if (_selectedTab == 1) {
      return GridView.builder(
        padding: EdgeInsets.all(20.w),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: filteredJuzs.length,
        itemBuilder: (context, index) {
          final juzNum = filteredJuzs[index];
          return InkWell(
            onTap: () {
              Navigator.pop(context);
              final page = _getPageForJuz(juzNum);
              _pageController.jumpToPage(page - 1);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.05),
                  border: Border.all(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(15.r)),
              child: Center(
                  child: Text('الجزء $juzNum',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.primaryColor))),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: 604,
        itemBuilder: (context, index) {
          final p = index + 1;
          return ListTile(
            title: Text('صفحة $p'),
            onTap: () {
              Navigator.pop(context);
              _pageController.jumpToPage(p - 1);
            },
          );
        },
      );
    }
  }

  int _getPageForJuz(int juz) {
    // Basic mapping for Madina Mushaf
    const juzPages = [
      1,
      22,
      42,
      62,
      82,
      102,
      122,
      142,
      162,
      182,
      202,
      222,
      242,
      262,
      282,
      302,
      322,
      342,
      362,
      382,
      402,
      422,
      442,
      462,
      482,
      502,
      522,
      542,
      562,
      582
    ];
    return juzPages[juz - 1];
  }
}
