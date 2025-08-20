import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排行榜'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, provider, child) {
          final leaderboard = provider.leaderboard;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTopThree(leaderboard),
                const SizedBox(height: 24),
                _buildRankingList(leaderboard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.leaderboard, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '健康排行榜',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '比拼健康指数，获得更多奖励',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree(List<LeaderboardUser> leaderboard) {
    if (leaderboard.length < 3) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '前三甲',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 第二名
            _buildPodiumItem(leaderboard[1], 2, Colors.grey),
            // 第一名
            _buildPodiumItem(leaderboard[0], 1, Colors.amber),
            // 第三名
            _buildPodiumItem(leaderboard[2], 3, Colors.brown),
          ],
        ),
      ],
    );
  }

  Widget _buildPodiumItem(LeaderboardUser user, int rank, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 40 : 35,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Text(
                user.name[0],
                style: TextStyle(
                  fontSize: rank == 1 ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            if (rank == 1)
              Positioned(
                top: -5,
                child: Icon(Icons.emoji_events, color: color, size: 24),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        Text(
          '智币: ${user.coins}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        Text(
          '年龄: ${user.smartAge}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRankingList(List<LeaderboardUser> leaderboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '完整排名',
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaderboard.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final isCurrentUser = user.name == '你';

              return Container(
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Colors.blue.withValues(alpha: 0.05)
                      : Colors.transparent,
                ),
                child: ListTile(
                  leading: _buildRankBadge(user.rank),
                  title: Row(
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isCurrentUser ? Colors.blue : null,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '我',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text('生物年龄: ${user.smartAge}岁'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user.coins}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey;
        icon = Icons.workspace_premium;
        break;
      case 3:
        badgeColor = Colors.brown;
        icon = Icons.workspace_premium;
        break;
      default:
        badgeColor = Colors.blue;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: badgeColor.withValues(alpha: 0.1),
      child: icon != null
          ? Icon(icon, color: badgeColor, size: 20)
          : Text(
              '$rank',
              style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor),
            ),
    );
  }
}
