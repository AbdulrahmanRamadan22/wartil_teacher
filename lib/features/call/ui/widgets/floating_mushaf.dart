import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';

class FloatingMushaf extends StatefulWidget {
  final VoidCallback onClose;
  const FloatingMushaf({super.key, required this.onClose});

  @override
  State<FloatingMushaf> createState() => _FloatingMushafState();
}

class _FloatingMushafState extends State<FloatingMushaf> {
  Map<String, dynamic>? quranData;
  bool isLoading = true;
  bool showIndex = false;
  int currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredSurahs = [];

  @override
  void initState() {
    super.initState();
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
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading quran data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterSurahs(String query) {
    if (quranData == null) return;
    setState(() {
      if (query.isEmpty) {
        filteredSurahs = quranData!['surahs'];
      } else {
        filteredSurahs = (quranData!['surahs'] as List).where((surah) {
          final name = surah['name'].toString().toLowerCase();
          final num = surah['number'].toString();
          return name.contains(query.toLowerCase()) || num == query;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.h,
      left: 15.w,
      right: 15.w,
      bottom: 150.h,
      child: Material(
        elevation: 15,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: ColorsManager.primaryColor, width: 2.w),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(18.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              showIndex
                                  ? Icons.menu_book
                                  : Icons.format_list_bulleted,
                              color: Colors.white,
                              size: 20.sp),
                          onPressed: () =>
                              setState(() => showIndex = !showIndex),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          showIndex ? 'الفهرس' : 'holy_quran_title'.tr(context),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                      onPressed: widget.onClose,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    )
                  ],
                ),
              ),
              // Content
              Expanded(
                child: showIndex ? _buildIndex() : _buildBody(),
              ),
              // Footer / Pagination
              if (quranData != null && !showIndex)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(18.r)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: ColorsManager.primaryColor),
                        onPressed:
                            currentPage < quranData!['mushaf']['total_pages']
                                ? () => setState(() => currentPage++)
                                : null,
                      ),
                      Text(
                        'صفحة $currentPage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.primaryColor,
                          fontSize: 13.sp,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: ColorsManager.primaryColor),
                        onPressed: currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndex() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontSize: 12.sp),
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة...',
              isDense: true,
              prefixIcon: Icon(Icons.search, size: 16.sp),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none),
            ),
            onChanged: _filterSurahs,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: filteredSurahs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final surah = filteredSurahs[index];
              return ListTile(
                dense: true,
                title: Text(surah['name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
                trailing: Text('ص ${surah['start_page']}',
                    style: TextStyle(
                        fontSize: 11.sp, color: ColorsManager.primaryColor)),
                onTap: () {
                  setState(() {
                    currentPage = surah['start_page'];
                    showIndex = false;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quranData == null) {
      return const Center(child: Text('خطأ في تحميل البيانات'));
    }

    final baseUrl = quranData!['cdn']['base_url'];
    final pageNum = currentPage.toString().padLeft(3, '0');

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          '$baseUrl/madina/$pageNum.png',
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_not_supported_outlined,
                  color: Colors.grey),
              Text('خطأ تحميل',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
