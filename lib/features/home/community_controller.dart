import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';

// ─────────────────────────────────────────────
// Community Model
// ─────────────────────────────────────────────

class CommunityData {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String category; // 'state' | 'special'
  final bool alwaysJoined;
  // Optional gradient colours for the cover banner
  final List<int> gradientStart;
  final List<int> gradientEnd;

  const CommunityData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.category,
    this.alwaysJoined = false,
    this.gradientStart = const [30, 30, 30],
    this.gradientEnd = const [80, 80, 80],
  });
}

// ─────────────────────────────────────────────
// Master Community List
// ─────────────────────────────────────────────

const List<CommunityData> kAllCommunities = [
  CommunityData(
    id: 'india',
    name: 'India',
    emoji: '🇮🇳',
    description: 'The national community for all impact-driven citizens.',
    category: 'special',
    alwaysJoined: true,
    gradientStart: [255, 140, 0],
    gradientEnd: [19, 136, 8],
  ),
  CommunityData(
    id: 'innovation',
    name: 'Innovation',
    emoji: '💡',
    description: 'Ideas, startups, and breakthrough thinking across India.',
    category: 'special',
    gradientStart: [255, 193, 7],
    gradientEnd: [255, 87, 34],
  ),
  CommunityData(
    id: 'spacetech',
    name: 'SpaceTech',
    emoji: '🚀',
    description: 'India\'s space revolution – ISRO, startups & the cosmos.',
    category: 'special',
    gradientStart: [13, 27, 90],
    gradientEnd: [65, 18, 120],
  ),
  CommunityData(
    id: 'kerala',
    name: 'Kerala',
    emoji: '🌴',
    description: 'God\'s Own Country – discuss issues and impact for Kerala.',
    category: 'state',
    gradientStart: [0, 150, 100],
    gradientEnd: [0, 100, 60],
  ),
  CommunityData(
    id: 'tamilnadu',
    name: 'Tamil Nadu',
    emoji: '🏛️',
    description: 'Land of Temples – community for Tamil Nadu changemakers.',
    category: 'state',
    gradientStart: [183, 28, 28],
    gradientEnd: [100, 10, 10],
  ),
  CommunityData(
    id: 'karnataka',
    name: 'Karnataka',
    emoji: '🌿',
    description: 'One State, Many Worlds – innovation & impact for Karnataka.',
    category: 'state',
    gradientStart: [230, 81, 0],
    gradientEnd: [130, 40, 0],
  ),
  CommunityData(
    id: 'maharashtra',
    name: 'Maharashtra',
    emoji: '🏙️',
    description: 'Spirit of Mumbai and beyond – Maharashtra impact community.',
    category: 'state',
    gradientStart: [21, 101, 192],
    gradientEnd: [10, 50, 130],
  ),
  CommunityData(
    id: 'telangana',
    name: 'Telangana',
    emoji: '💎',
    description: 'Rising state community for Telangana changemakers.',
    category: 'state',
    gradientStart: [74, 20, 140],
    gradientEnd: [40, 10, 80],
  ),
  CommunityData(
    id: 'andhra_pradesh',
    name: 'Andhra Pradesh',
    emoji: '🌊',
    description: 'Community for impact-driven voices from Andhra Pradesh.',
    category: 'state',
    gradientStart: [0, 131, 176],
    gradientEnd: [0, 80, 120],
  ),
  CommunityData(
    id: 'delhi',
    name: 'Delhi',
    emoji: '🏛️',
    description: 'The capital\'s community for civic action and social change.',
    category: 'state',
    gradientStart: [55, 55, 55],
    gradientEnd: [20, 20, 20],
  ),
  CommunityData(
    id: 'gujarat',
    name: 'Gujarat',
    emoji: '🦁',
    description: 'Land of entrepreneurs – Gujarat community for change.',
    category: 'state',
    gradientStart: [245, 127, 23],
    gradientEnd: [180, 70, 0],
  ),
  CommunityData(
    id: 'rajasthan',
    name: 'Rajasthan',
    emoji: '🏜️',
    description: 'Desert resilience – community for Rajasthan changemakers.',
    category: 'state',
    gradientStart: [230, 162, 0],
    gradientEnd: [180, 80, 0],
  ),
  CommunityData(
    id: 'west_bengal',
    name: 'West Bengal',
    emoji: '🐅',
    description: 'City of Joy and beyond – West Bengal impact community.',
    category: 'state',
    gradientStart: [0, 105, 92],
    gradientEnd: [0, 60, 50],
  ),
  CommunityData(
    id: 'punjab',
    name: 'Punjab',
    emoji: '🌾',
    description: 'Land of Five Rivers – Punjab community for social impact.',
    category: 'state',
    gradientStart: [26, 115, 232],
    gradientEnd: [10, 60, 180],
  ),
  CommunityData(
    id: 'uttarpradesh',
    name: 'Uttar Pradesh',
    emoji: '🕌',
    description: 'Heart of India – UP community for changemakers.',
    category: 'state',
    gradientStart: [0, 96, 100],
    gradientEnd: [0, 50, 60],
  ),
  CommunityData(
    id: 'madhya_pradesh',
    name: 'Madhya Pradesh',
    emoji: '🌳',
    description: 'Heart of India – MP community for impact & growth.',
    category: 'state',
    gradientStart: [46, 125, 50],
    gradientEnd: [20, 70, 25],
  ),
  CommunityData(
    id: 'odisha',
    name: 'Odisha',
    emoji: '🪷',
    description: 'Soul of India – Odisha community for social change.',
    category: 'state',
    gradientStart: [173, 20, 87],
    gradientEnd: [100, 10, 50],
  ),
];

// ─────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────

class CommunityController extends GetxController {
  final NameController _nameController = Get.find<NameController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Member counts keyed by community id  (loaded from Firestore)
  final RxMap<String, int> memberCounts = <String, int>{}.obs;

  RxList<String> get joinedIds => _nameController.joinedCommunities;

  bool isJoined(String id) => id == 'india' || joinedIds.contains(id);

  int memberCount(String id) =>
      memberCounts[id] ?? (id == 'india' ? 2300 : 0);

  @override
  void onInit() {
    super.onInit();
    _loadMemberCounts();
  }

  // ── Fetch all community member counts ─────────────────────

  Future<void> _loadMemberCounts() async {
    try {
      final snap = await _firestore.collection('communities').get();
      final map = <String, int>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        map[doc.id] = (data['memberCount'] as int?) ?? 0;
      }
      memberCounts.assignAll(map);
    } catch (e) {
      // Counts will show 0 if unavailable — non-fatal
    }
  }

  // ── Join ───────────────────────────────────────────────────

  Future<void> joinCommunity(String id) async {
    if (isJoined(id)) return;
    joinedIds.add(id);
    // Optimistic UI update
    memberCounts[id] = (memberCounts[id] ?? 0) + 1;
    await _persistUser();
    await _incrementCount(id, 1);
  }

  // ── Leave ──────────────────────────────────────────────────

  Future<void> leaveCommunity(String id) async {
    if (id == 'india') return;
    if (!joinedIds.contains(id)) return;
    joinedIds.remove(id);
    // Optimistic UI update
    final current = memberCounts[id] ?? 0;
    memberCounts[id] = current > 0 ? current - 1 : 0;
    await _persistUser();
    await _incrementCount(id, -1);
  }

  Future<void> toggleCommunity(String id) async {
    if (id == 'india') return;
    if (isJoined(id)) {
      await leaveCommunity(id);
    } else {
      await joinCommunity(id);
    }
  }

  // ── Persist joined list to user's Firestore doc ───────────

  Future<void> _persistUser() async {
    final uid = _nameController.userId;
    if (uid.isEmpty) return;
    try {
      final toSave = joinedIds.toSet()..add('india');
      await _firestore.collection('users').doc(uid).update({
        'joinedCommunities': toSave.toList(),
      });
    } catch (e) {
      // ignore
    }
  }

  // ── Increment / decrement the community counter ───────────

  Future<void> _incrementCount(String id, int delta) async {
    try {
      final ref = _firestore.collection('communities').doc(id);
      await ref.set(
        {'memberCount': FieldValue.increment(delta)},
        SetOptions(merge: true),
      );
    } catch (e) {
      // ignore
    }
  }
}
