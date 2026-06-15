import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ranking_provider.dart';
import '../theme/app_theme.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RankingProvider>().loadBids();
    });
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  static const _tabLabels = ['Trieurs', 'Ramasseurs', 'Livreurs'];
  static const _tabIcons = [Icons.sort_rounded, Icons.cleaning_services_rounded, Icons.local_shipping_rounded];
  static const _tabKeys = ['trieur', 'ramasseur', 'livreur'];

  @override
  Widget build(BuildContext context) {
    final ranking = context.watch<RankingProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        title: const Text('Classement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.green,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: List.generate(3, (i) => Tab(
            icon: Icon(_tabIcons[i], size: 20),
            text: _tabLabels[i],
          )),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: List.generate(3, (i) => _buildRankingTab(ranking, _tabKeys[i])),
      ),
    );
  }

  Widget _buildRankingTab(RankingProvider ranking, String category) {
    final users = ranking.getRankedUsers(category);
    final auth = context.watch<AuthProvider>();
    final currentEmail = auth.user?.email ?? '';
    final myBid = ranking.getUserBid(category, currentEmail);
    final pointsToBeat = ranking.getPointsToBeat(category);
    final myPoints = auth.user?.points ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current leader info
          if (users.isNotEmpty)
            _buildLeaderCard(users.first, currentEmail)
          else
            _buildEmptyLeaderCard(),

          const SizedBox(height: 24),

          // My bid card
          _buildMyBidCard(category, ranking, currentEmail, myBid, pointsToBeat, myPoints, auth),

          const SizedBox(height: 24),

          // Ranking list header
          Row(
            children: [
              const Icon(Icons.leaderboard_rounded, color: AppColors.yellow, size: 20),
              const SizedBox(width: 8),
              Text(
                'Classement ${category == 'trieur' ? 'des Trieurs' : category == 'ramasseur' ? 'des Ramasseurs' : 'des Livreurs'}',
                style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (users.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.softBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.emoji_events_rounded, color: AppColors.grey.withValues(alpha: 0.5), size: 48),
                  const SizedBox(height: 12),
                  const Text('Aucun enchérisseur pour le moment',
                      style: TextStyle(color: AppColors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Sois le premier à enchérir !',
                      style: TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            ...List.generate(users.length, (i) => _buildRankingTile(users[i], currentEmail)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLeaderCard(RankedUser leader, String currentEmail) {
    final isMe = leader.email == currentEmail;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.yellow.withValues(alpha: 0.15),
            AppColors.softBlack,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.yellow, size: 40),
          const SizedBox(height: 8),
          Text('Leader actuel', style: TextStyle(color: AppColors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
            backgroundImage: leader.photoUrl != null ? NetworkImage(leader.photoUrl!) : null,
            child: leader.photoUrl == null
                ? Text(leader.name.isNotEmpty ? leader.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.yellow, fontSize: 24, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(height: 8),
          Text(leader.name,
              style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${leader.points} pts',
              style: const TextStyle(color: AppColors.yellow, fontSize: 22, fontWeight: FontWeight.bold)),
          if (isMe)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('C\'est toi !', style: TextStyle(color: AppColors.yellow, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: AppColors.grey.withValues(alpha: 0.5), size: 40),
          const SizedBox(height: 8),
          const Text('Aucun leader', style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Enchéris pour devenir #1 !',
              style: TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMyBidCard(String category, RankingProvider ranking, String currentEmail,
      int myBid, int pointsToBeat, int myPoints, AuthProvider auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.green, size: 20),
              const SizedBox(width: 8),
              const Text('Mes points', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('$myPoints pts', style: TextStyle(color: AppColors.green, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (myBid > 0)
            Row(
              children: [
                const Text('Mon enchère : ', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                Text('$myBid pts', style: const TextStyle(color: AppColors.yellow, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          const SizedBox(height: 4),
          if (pointsToBeat > 0)
            Row(
              children: [
                const Text('À battre : ', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                Text('${pointsToBeat + 1} pts min',
                    style: const TextStyle(color: AppColors.orange, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: ranking.isLoading || myPoints == 0
                  ? null
                  : () => _showBidDialog(category, pointsToBeat, myPoints, auth),
              icon: const Icon(Icons.gavel_rounded, size: 18),
              label: Text(myBid > 0 ? 'Sur-enchérir' : 'Enchérir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTile(RankedUser user, String currentEmail) {
    final isMe = user.email == currentEmail;
    final isTop3 = user.rank <= 3;

    IconData medal;
    Color medalColor;
    if (user.rank == 1) {
      medal = Icons.emoji_events_rounded;
      medalColor = AppColors.yellow;
    } else if (user.rank == 2) {
      medal = Icons.workspace_premium_rounded;
      medalColor = const Color(0xFFC0C0C0);
    } else if (user.rank == 3) {
      medal = Icons.workspace_premium_rounded;
      medalColor = const Color(0xFFCD7F32);
    } else {
      medal = Icons.circle_rounded;
      medalColor = AppColors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.green.withValues(alpha: 0.08) : AppColors.softBlack,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: AppColors.green.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Icon(medal, color: medalColor, size: isTop3 ? 22 : 8),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.green.withValues(alpha: 0.15),
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                        )),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('MOI', style: TextStyle(color: AppColors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text('${user.points} pts',
              style: const TextStyle(color: AppColors.yellow, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showBidDialog(String category, int pointsToBeat, int myPoints, AuthProvider auth) {
    final minBid = pointsToBeat + 1;
    final ctrl = TextEditingController(text: '$minBid');
    final ranking = context.read<RankingProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.softBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bidAmount = int.tryParse(ctrl.text) ?? 0;
            final isValid = bidAmount >= minBid && bidAmount <= myPoints;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.gavel_rounded, color: AppColors.green, size: 22),
                      const SizedBox(width: 8),
                      const Text('Placer une enchère',
                          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Minimum $minBid pts pour prendre la tête',
                      style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Points à enchérir',
                      hintText: 'Entre le nombre de points',
                      prefixIcon: const Icon(Icons.monetization_on_rounded, color: AppColors.green),
                      suffixText: 'pts',
                      suffixStyle: const TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Disponible : $myPoints pts',
                    style: TextStyle(
                      color: myPoints >= minBid ? AppColors.green : AppColors.red,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: !isValid || ranking.isLoading
                          ? null
                          : () async {
                              final email = auth.user?.email ?? '';
                              final name = auth.user?.name ?? '';
                              final photoUrl = auth.user?.photoUrl;
                              final ok = await ranking.placeBid(category, bidAmount, email, name, photoUrl);
                              if (ok && ctx.mounted) {
                                Navigator.pop(ctx);
                                auth.refreshUser();
                                setState(() {});
                              } else if (!ok && ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ranking.error ?? 'Erreur'),
                                    backgroundColor: AppColors.red,
                                  ),
                                );
                                ranking.clearError();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: ranking.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Enchérir $bidAmount pts'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
