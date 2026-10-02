import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KisanAiChatCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const KisanAiChatCard({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        // Glowing Neon Shadow for true Highlight / Spotlight effect
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          // Rich, High-Contrast Solid Deep Emerald Gradient
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF063A2F), // Vibrant Deep Jade
                Color(0xFF042B23), // Midnight Forest
                Color(0xFF064436), // Rich Emerald
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            // Highlighting Neon Border
            border: Border.all(
              color: const Color(0xFF34D399).withValues(alpha: 0.70),
              width: 1.6,
            ),
          ),
          child: Stack(
            children: [
              // Ambient Glowing Highlight Blobs
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 10,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF59E0B).withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Live Ribbon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF34D399).withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF22C55E),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                '24×7 लाइव स्मार्ट AI',
                                style: TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                              SizedBox(width: 3),
                              Text(
                                'मंडी + डॉक्टर',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Middle Row: AI Avatar + Title/Pitch + Glowing CTA Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Futuristic AI Avatar
                        _buildAiAvatar(),
                        const SizedBox(width: 12),

                        // Title & Subtitle with Razor-Sharp Contrast
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'किसान मित्र AI चैट',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'सटीक मंडी भाव व हर फसल रोग की असली दवा',
                                style: TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Glowing Amber CTA Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/chat'),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD54F), Color(0xFFF59E0B)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'चैट करें',
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF1E293B),
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Bottom Row: Crisp, High-Contrast Interactive Prompt Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildPromptChip(
                            context: context,
                            icon: '🩺',
                            text: 'चने में इल्ली दवा',
                            query: 'चने में इल्ली दवा',
                          ),
                          const SizedBox(width: 8),
                          _buildPromptChip(
                            context: context,
                            icon: '💰',
                            text: 'नीमच लहसुन भाव',
                            query: 'नीमच में लहसुन भाव',
                          ),
                          const SizedBox(width: 8),
                          _buildPromptChip(
                            context: context,
                            icon: '🌾',
                            text: 'इंदौर सोयाबीन',
                            query: 'इंदौर में सोयाबीन भाव',
                          ),
                          const SizedBox(width: 8),
                          _buildPromptChip(
                            context: context,
                            icon: '⚡',
                            text: 'सरसों में माहू',
                            query: 'सरसों में माहू दवा',
                          ),
                        ],
                      ),
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

  Widget _buildAiAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF6EE7B7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.6),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildPromptChip({
    required BuildContext context,
    required String icon,
    required String text,
    required String query,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/chat', extra: query),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF02241C), // Deep Rich Dark Jade
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF34D399).withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12.5)),
              const SizedBox(width: 5),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
