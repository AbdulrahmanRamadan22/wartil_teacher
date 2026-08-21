import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart' as intl;
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/networking/api_constants.dart';
import '../data/models/chat_message.dart';
import '../logic/ai_chat_cubit.dart';
import '../logic/ai_chat_state.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  bool _showSendButton = false;
  int _selectedCategory = 0;

  // مفتاح Groq API
  static final String _apiKey = ApiConstants.groqApiKey;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'التجويد', 'icon': Icons.menu_book_rounded},
    {'label': 'التطبيق', 'icon': Icons.phone_android_rounded},
    {'label': 'الجلسات', 'icon': Icons.people_alt_rounded},
  ];

  static const List<List<String>> _suggestions = [
    // التجويد
    [
      'ما هي أحكام النون الساكنة؟',
      'اشرح لي مخارج الحروف',
      'ما الفرق بين الإخفاء والإدغام؟',
      'ما أحكام الميم الساكنة؟',
      'اشرح المد وأنواعه',
      'ما هو الوقف الاضطراري؟',
      'ما معنى الترتيل والتجويد؟',
      'ما هي أحكام القلقلة؟',
    ],
    // التطبيق
    [
      'كيف أتابع تقدمي في التطبيق؟',
      'كيف أسجل دخولي في ورتل؟',
      'كيف أغيّر بياناتي الشخصية؟',
      'كيف أبحث عن طالب مناسب؟',
      'كيف أشاهد الجلسات المتاحة؟',
      'كيف أضيف مواعيد للجدول؟',
      'كيف أتابع إحصائياتي؟',
      'كيف أشكو من مشكلة في التطبيق؟',
    ],
    // الجلسات
    [
      'كيف أبدأ جلسة مع الطالب؟',
      'كيف تتم جلسة التلاوة الجماعية؟',
      'ما الفرق بين الجلسة الخاصة والعامة؟',
      'كيف أراجع جلسة سابقة؟',
      'ما مدة جلسة التلاوة العادية؟',
      'كيف أقيّم الطالب بعد الجلسة؟',
      'كيف أشارك في مقرأة مباشرة؟',
      'هل يمكنني إلغاء موعد جلسة؟',
    ],
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _showSendButton) {
        setState(() => _showSendButton = hasText);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiChatCubit(_apiKey),
      child: Builder(
        builder: (context) => BlocConsumer<AiChatCubit, AiChatState>(
          listener: (context, state) {
            if (state is AiChatUpdated || state is AiChatInitial) {
              _scrollToBottom();
            }
            if (state is AiChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message,
                      style: const TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: ColorsManager.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  margin: EdgeInsets.all(16.w),
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<AiChatCubit>();
            return Scaffold(
              backgroundColor: const Color(0xFFF7FAFA),
              body: Column(
                children: [
                  _buildAppBar(context, state, cubit),
                  Expanded(
                    child: state.messages.isEmpty
                        ? _buildEmptyState(context)
                        : _buildMessageList(state),
                  ),
                  _buildQuickSuggestions(cubit),
                  _buildInputArea(state, cubit, context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(
      BuildContext context, AiChatState state, AiChatCubit cubit) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: 16.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorsManager.primaryDark, ColorsManager.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18.sp),
            ),
          ),
          SizedBox(width: 12.w),

          // AI Avatar with pulse
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: 0.1 + _pulseController.value * 0.1),
                  ),
                ),
              ),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20.sp),
              ),
            ],
          ),
          SizedBox(width: 12.w),

          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ورتل الذكي',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    letterSpacing: 0.3,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.only(left: 4.w),
                      decoration: BoxDecoration(
                        color: state.isTyping
                            ? ColorsManager.accentColor
                            : ColorsManager.successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      state.isTyping ? 'يفكر الآن...' : 'متصل',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Clear button
          GestureDetector(
            onTap: () => cubit.clearChat(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child:
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final suggestions = [
      'ما هي أحكام النون الساكنة؟',
      'اشرح لي مخارج الحروف',
      'كيف أتابع تقدمي في التطبيق؟',
      'كيف أبدأ جلسة مع الطالب؟',
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),

          // Icon
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorsManager.primaryColor.withValues(alpha: 0.12),
                  ColorsManager.greenLight.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.15),
                  width: 1.5),
            ),
            child: Icon(Icons.auto_awesome_rounded,
                size: 40.sp, color: ColorsManager.primaryColor),
          ),
          SizedBox(height: 20.h),

          Text(
            'مساعد ورتل الذكي',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: ColorsManager.textPrimaryColor,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اسألني عن القرآن الكريم، التجويد، أو أي شيء في التطبيق',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorsManager.textSecondaryColor,
              fontSize: 13.sp,
              fontFamily: 'Cairo',
              height: 1.7,
            ),
          ),
          SizedBox(height: 32.h),

          // Divider
          Row(
            children: [
              Expanded(
                  child:
                      Divider(color: ColorsManager.borderColor, thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'اقتراحات',
                  style: TextStyle(
                    color: ColorsManager.textSecondaryColor,
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              Expanded(
                  child:
                      Divider(color: ColorsManager.borderColor, thickness: 1)),
            ],
          ),
          SizedBox(height: 16.h),

          ...suggestions.map((s) => _buildSuggestionChip(context, s)),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return GestureDetector(
      onTap: () => context.read<AiChatCubit>().sendMessage(text),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: ColorsManager.primaryColor.withValues(alpha: 0.15),
              width: 1),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 14.sp, color: ColorsManager.primaryColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: ColorsManager.textPrimaryColor,
                  fontSize: 13.sp,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12.sp, color: ColorsManager.textSecondaryColor),
          ],
        ),
      ),
    );
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  Widget _buildMessageList(AiChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isTyping) {
          return _buildTypingBubble();
        }
        return _buildMessageBubble(state.messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // AI avatar
            Container(
              width: 32.w,
              height: 32.w,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.primaryDark,
                    ColorsManager.primaryColor
                  ],
                ),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14.sp),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  constraints: BoxConstraints(maxWidth: 0.75.sw),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.white : ColorsManager.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft: isUser ? Radius.circular(18.r) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : Radius.circular(18.r),
                    ),
                    border: isUser
                        ? Border.all(color: ColorsManager.borderColor, width: 1)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? Colors.black.withValues(alpha: 0.04)
                            : ColorsManager.primaryColor
                                .withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          message.text,
                          style: TextStyle(
                            color: ColorsManager.textPrimaryColor,
                            fontSize: 14.sp,
                            fontFamily: 'Cairo',
                            height: 1.6,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'Cairo',
                              height: 1.6,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            h1: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                            code: TextStyle(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    intl.DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(
                      color: ColorsManager.textSecondaryColor,
                      fontSize: 9.sp,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            // User avatar
            Container(
              width: 32.w,
              height: 32.w,
              margin: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsManager.lightMint,
                border: Border.all(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.person_rounded,
                  color: ColorsManager.primaryColor, size: 16.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [ColorsManager.primaryDark, ColorsManager.primaryColor],
              ),
            ),
            child: Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 14.sp),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i / 3;
                  final val = ((_pulseController.value + delay) % 1.0);
                  final opacity =
                      (val < 0.5 ? val * 2 : (1.0 - val) * 2).clamp(0.3, 1.0);
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Suggestions ────────────────────────────────────────────────────

  Widget _buildQuickSuggestions(AiChatCubit cubit) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
            child: Row(
              children: List.generate(_categories.length, (i) {
                final selected = i == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(left: 8.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? ColorsManager.primaryColor
                          : ColorsManager.lightMint,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected
                            ? ColorsManager.primaryColor
                            : ColorsManager.primaryColor
                                .withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categories[i]['icon'] as IconData,
                          size: 13.sp,
                          color: selected
                              ? Colors.white
                              : ColorsManager.primaryColor,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          _categories[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : ColorsManager.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 8.h),
          // Question chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
            child: Row(
              children: _suggestions[_selectedCategory].map((q) {
                return GestureDetector(
                  onTap: () => cubit.sendMessage(q),
                  child: Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color:
                            ColorsManager.primaryColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      q,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.primaryDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: ColorsManager.borderColor),
        ],
      ),
    );
  }

  // ─── Input Area ───────────────────────────────────────────────────────────

  Widget _buildInputArea(
      AiChatState state, AiChatCubit cubit, BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: ColorsManager.borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 120.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: ColorsManager.borderColor, width: 1),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  hintStyle: TextStyle(
                    color: ColorsManager.textSecondaryColor,
                    fontSize: 13.sp,
                    fontFamily: 'Cairo',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Cairo',
                  color: ColorsManager.textPrimaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showSendButton
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        cubit.sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                    child: Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        gradient: ColorsManager.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ColorsManager.primaryColor
                                .withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.send_rounded,
                          color: Colors.white, size: 20.sp),
                    ),
                  )
                : Container(
                    key: const ValueKey('mic'),
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: ColorsManager.lightMint,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: ColorsManager.primaryColor
                              .withValues(alpha: 0.2)),
                    ),
                    child: Icon(Icons.mic_none_rounded,
                        color: ColorsManager.primaryColor, size: 20.sp),
                  ),
          ),
        ],
      ),
    );
  }
}
