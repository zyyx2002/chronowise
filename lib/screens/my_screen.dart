import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Container(
            color: const Color(0xFFF9FAFB),
            child: Column(
              children: [
                _buildProfileHeader(provider),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 32), // 与头部重叠
                        _buildAchievementsCard(provider),
                        const SizedBox(height: 24),
                        _buildMyDataCard(provider),
                        const SizedBox(height: 24),
                        _buildFunctionMenuCard(),
                        const SizedBox(height: 24),
                        _buildLevelProgressCard(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(AppStateProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
          child: Column(
            children: [
              // 个人信息头部
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (provider.currentUser?.name?.isNotEmpty ?? false)
                            ? provider.currentUser!.name![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (provider.currentUser?.name?.isNotEmpty ?? false)
                              ? provider.currentUser!.name!
                              : '智龄用户',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '加入 ${provider.currentUser?.totalDays ?? 0} 天',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFDDD6FE),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              color: Color(0xFFFBBF24),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '等级 ${provider.currentUser?.level ?? 1} · 健康达人',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 核心数据展示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '${provider.currentUser?.smartCoins ?? 0}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '智龄币',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDDD6FE),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${provider.currentUser?.biologicalAge ?? 32}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '生物年龄',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDDD6FE),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${provider.currentUser?.streakDays ?? 0}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '连续打卡',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDDD6FE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(AppStateProvider provider) {
    final unlockedCount = provider.achievements.where((a) => a.unlocked).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的成就',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                '$unlockedCount/${provider.achievements.length}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 成就网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final achievement = provider.achievements[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: achievement.unlocked
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFEF3C7), Color(0xFFFBBF24)],
                        )
                      : null,
                  color: achievement.unlocked ? null : const Color(0xFFF3F4F6),
                  border: Border.all(
                    color: achievement.unlocked
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: 24,
                        color: achievement.unlocked ? null : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: achievement.unlocked
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF9CA3AF),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.desc,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (achievement.unlocked && achievement.date != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          achievement.date!,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // 查看全部按钮
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                '查看全部成就 →',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDataCard(AppStateProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),

          // 数据项列表
          _buildDataItem(
            Icons.bar_chart,
            '健康报告',
            '查看详细健康分析',
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 4),
          _buildDataItem(
            Icons.directions_run,
            '运动记录',
            '累计运动 ${((provider.currentUser?.totalDays ?? 0) * 0.7).toInt()}小时',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 4),
          _buildDataItem(
            Icons.psychology,
            '冥想记录',
            '累计冥想 ${((provider.currentUser?.totalDays ?? 0) * 0.5).toInt()}次',
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
        ],
      ),
    );
  }

  Widget _buildFunctionMenuCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '功能菜单',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),

          // 功能菜单项
          _buildMenuItem(Icons.settings, '设置'),
          _buildMenuItem(Icons.card_giftcard, '智龄币商城', hasNew: true),
          _buildMenuItem(Icons.people, '邀请好友'),
          _buildMenuItem(Icons.help_outline, '帮助与反馈'),
          _buildMenuItem(Icons.shield, '隐私政策'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool hasNew = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF6B7280), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (hasNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '新',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelProgressCard(AppStateProvider provider) {
    final totalPoints = provider.currentUser?.totalPoints ?? 0;
    final currentLevelPoints = totalPoints % 3000;
    final nextLevelPoints = 3000 - currentLevelPoints;
    final progressPercentage = currentLevelPoints / 3000;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '等级进度',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),

          // 等级进度展示
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '等级 ${provider.currentUser?.level ?? 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '$totalPoints/3000',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressPercentage,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '距离下一等级还需 $nextLevelPoints 积分',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 统计数据
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${provider.currentUser?.totalDays ?? 0}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      const Text(
                        '总打卡天数',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${(totalPoints / 100).floor()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const Text(
                        '总获得奖励',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
