import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Container(
            color: const Color(0xFFF9FAFB),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '智龄榜',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 我的排名卡片
                    _buildMyRankCard(provider),
                    const SizedBox(height: 24),

                    // 排行榜列表
                    ...provider.leaderboard.asMap().entries.map((entry) {
                      final index = entry.key;
                      final user = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _buildLeaderboardItem(
                          user,
                          index == 3,
                        ), // 第4位是用户自己
                      );
                    }),

                    const SizedBox(height: 100), // 底部导航空间
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyRankCard(AppStateProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '我的排名',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 4),
              Text(
                '#4',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '本周上升 2 位',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '智龄币',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                '${provider.userProfile.smartCoins}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '生物年龄 ${provider.userProfile.biologicalAge}岁',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(user, bool isCurrentUser) {
    Color getRankColor(int rank) {
      switch (rank) {
        case 1:
          return const Color(0xFFFBBF24); // Gold
        case 2:
          return const Color(0xFF9CA3AF); // Silver
        case 3:
          return const Color(0xFFF97316); // Bronze
        default:
          return const Color(0xFF3B82F6); // Blue
      }
    }

    Widget getRankIcon(int rank) {
      if (rank <= 3) {
        return const Icon(Icons.emoji_events, color: Colors.white, size: 24);
      } else {
        return Text(
          '$rank',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFDDEAFE) : Colors.white,
        border: isCurrentUser
            ? Border.all(color: const Color(0xFF3B82F6), width: 2)
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 排名图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: user.rank <= 3
                    ? [getRankColor(user.rank), getRankColor(user.rank)]
                    : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: getRankIcon(user.rank)),
          ),
          const SizedBox(width: 16),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '我',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '生物年龄 ${user.smartAge}岁',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // 积分
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFF97316),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user.coins}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
