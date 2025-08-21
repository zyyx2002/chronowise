import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/user.dart'; // 🆕 添加User导入

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, provider, child) {
          final user = provider.currentUser;
          if (user == null) {
            return const Center(child: Text('用户信息加载中...'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUserHeader(user, provider), // 🆕 现在user是User类型
                const SizedBox(height: 24),
                _buildStatsCards(provider),
                const SizedBox(height: 24),
                _buildSettingsSection(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🆕 修改方法签名：接受User而不是UserItem
  Widget _buildUserHeader(User user, AppStateProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '等级 ${user.level}', // 🆕 直接从User对象获取
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '已使用 ${user.totalDays} 天', // 🆕 直接从User对象获取
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(AppStateProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            title: '智币',
            value: '${provider.currentUser?.smartCoins ?? 0}', // 🆕 直接从User获取
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_down,
            title: '生物年龄',
            value:
                '${provider.currentUser?.biologicalAge ?? 32}岁', // 🆕 直接从User获取
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AppStateProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '设置',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.person,
                title: '个人信息',
                onTap: () => _showEditProfileDialog(context, provider),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                icon: Icons.history,
                title: '积分历史',
                onTap: () => _showPointHistoryDialog(context, provider),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                icon: Icons.refresh,
                title: '重置今日数据',
                onTap: () => _showResetDialog(context, provider),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                icon: Icons.info,
                title: '关于应用',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, AppStateProvider provider) {
    final nameController = TextEditingController(
      text: provider.currentUser?.name ?? '', // 🆕 直接从User获取
    );
    final ageController = TextEditingController(
      text: provider.currentUser?.age.toString() ?? '', // 🆕 直接从User获取
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑个人信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: '年龄'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              provider.updateUserName(nameController.text);
              provider.updateUserAge(ageController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('个人信息已更新')));
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showPointHistoryDialog(
    BuildContext context,
    AppStateProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('积分历史'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: provider.pointHistory.length,
            itemBuilder: (context, index) {
              final transaction = provider.pointHistory[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    transaction.isPositive ? Icons.add : Icons.remove,
                    color: transaction.isPositive ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(transaction.description),
                subtitle: Text(transaction.typeDisplay),
                trailing: Text(
                  transaction.pointsDisplay,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isPositive ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppStateProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置今日数据'),
        content: const Text('确定要重置今日的所有数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await provider.resetTodayData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('今日数据已重置')));
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 ChronoWise'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('ChronoWise 是一款智能健康管理应用，帮助您建立健康的生活习惯。'),
            SizedBox(height: 8),
            Text('功能特色：'),
            Text('• 健康数据跟踪'),
            Text('• 任务打卡系统'),
            Text('• 积分奖励机制'),
            Text('• 社区互动交流'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
