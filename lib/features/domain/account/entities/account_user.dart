class UserLocation {
  final String name;
  final String state;
  final String district;
  final String place;

  const UserLocation({
    this.name = '',
    this.state = '',
    this.district = '',
    this.place = '',
  });

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      name: map['name'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      place: map['place'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': state,
      'district': district,
      'place': place,
    };
  }

  bool get isEmpty => name.isEmpty && state.isEmpty && district.isEmpty && place.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    final parts = <String>[];
    if (place.isNotEmpty) parts.add(place);
    if (district.isNotEmpty) parts.add(district);
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }
}

class AccountUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String tagline;
  final UserLocation location;
  final String website;
  final bool isVerified;
  final int dharma;
  final int followerCount;
  final int followingCount;
  final List<String> earnedBadgeIds;
  final List<String> takenStandIds; // IDs of impact stands taken by user
  final List<String> joinedCommunities; // IDs of communities the user has joined
  final String profileType;

  // NGO specific
  final String ngoName;
  final String ngoMission;
  final String ngoLogo;
  final String registrationNumber;
  final String contactInfo;
  final String featuredCampaign;
  final String legalType;
  final String registrationDate;
  final List<String> focusAreas;
  final String shortAbout;
  final String keyProgram;
  final String impactSnapshot;
  final String phone;
  final String address;
  final String instagramLink;

  // Company specific
  final String companyName;
  final String companyLogo;
  final String companyIndustry;
  final String csrDetails;

  const AccountUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.tagline = '',
    this.location = const UserLocation(),
    this.website = '',
    this.isVerified = false,
    this.dharma = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.earnedBadgeIds = const [],
    this.takenStandIds = const [],
    this.joinedCommunities = const ['india'],
    this.profileType = 'user',
    this.ngoName = '',
    this.ngoMission = '',
    this.ngoLogo = '',
    this.registrationNumber = '',
    this.contactInfo = '',
    this.featuredCampaign = '',
    this.legalType = '',
    this.registrationDate = '',
    this.focusAreas = const [],
    this.shortAbout = '',
    this.keyProgram = '',
    this.impactSnapshot = '',
    this.phone = '',
    this.address = '',
    this.instagramLink = '',
    this.companyName = '',
    this.companyLogo = '',
    this.companyIndustry = '',
    this.csrDetails = '',
  });

  bool get isNgo => profileType == 'ngo';
  bool get isCompany => profileType == 'company';

  // Helper to create an empty user
  factory AccountUser.empty() {
    return const AccountUser(uid: '', name: '', email: '', photoUrl: '');
  }
}
