import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oulta/features/domain/account/entities/account_user.dart';

class AccountUserModel extends AccountUser {
  const AccountUserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.photoUrl,
    super.tagline,
    super.location,
    super.website,
    super.isVerified,
    super.dharma,
    super.followerCount,
    super.followingCount,
    super.earnedBadgeIds,
    super.takenStandIds,
    super.joinedCommunities,
    super.profileType,
    super.ngoName,
    super.ngoMission,
    super.ngoLogo,
    super.registrationNumber,
    super.contactInfo,
    super.featuredCampaign,
    super.legalType,
    super.registrationDate,
    super.focusAreas,
    super.shortAbout,
    super.keyProgram,
    super.impactSnapshot,
    super.phone,
    super.address,
    super.instagramLink,
    super.companyName,
    super.companyLogo,
    super.companyIndustry,
    super.csrDetails,
  });

  factory AccountUserModel.fromMap(Map<String, dynamic> data, String uid) {
    return AccountUserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      tagline: data['tagline'] ?? '',
      location: () {
        final locData = data['location'];
        if (locData is Map) {
          return UserLocation.fromMap(Map<String, dynamic>.from(locData));
        } else if (locData is String) {
          return UserLocation(
            name: data['name'] ?? '',
            state: locData,
            district: '',
            place: '',
          );
        }
        return const UserLocation();
      }(),
      website: data['website'] ?? '',
      isVerified: _parseBool(data['isVerrified']),
      dharma: data['dharma'] ?? 0,
      followerCount: data['followerCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      earnedBadgeIds: List<String>.from(data['badges'] ?? []),
      takenStandIds: List<String>.from(data['takenStandIds'] ?? []),
      joinedCommunities: () {
        final raw = data['joinedCommunities'];
        if (raw is List && raw.isNotEmpty) {
          return List<String>.from(raw);
        }
        return ['india']; // default for existing users with no field
      }(),
      profileType: data['profileType'] ?? 'user',
      ngoName: data['ngoName'] ?? '',
      ngoMission: data['ngoMission'] ?? '',
      ngoLogo: data['ngoLogo'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      featuredCampaign: data['featuredCampaign'] ?? '',
      legalType: data['legalType'] ?? '',
      registrationDate: data['registrationDate'] ?? '',
      focusAreas: List<String>.from(data['focusAreas'] ?? []),
      shortAbout: data['shortAbout'] ?? '',
      keyProgram: data['keyProgram'] ?? '',
      impactSnapshot: data['impactSnapshot'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      instagramLink: data['instagramLink'] ?? '',
      companyName: data['companyName'] ?? '',
      companyLogo: data['companyLogo'] ?? '',
      companyIndustry: data['companyIndustry'] ?? '',
      csrDetails: data['csrDetails'] ?? '',
    );
  }

  factory AccountUserModel.fromEntity(AccountUser user) {
    return AccountUserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl,
      tagline: user.tagline,
      location: user.location,
      website: user.website,
      isVerified: user.isVerified,
      dharma: user.dharma,
      followerCount: user.followerCount,
      followingCount: user.followingCount,
      earnedBadgeIds: user.earnedBadgeIds,
      takenStandIds: user.takenStandIds,
      joinedCommunities: user.joinedCommunities,
      profileType: user.profileType,
      ngoName: user.ngoName,
      ngoMission: user.ngoMission,
      ngoLogo: user.ngoLogo,
      registrationNumber: user.registrationNumber,
      contactInfo: user.contactInfo,
      featuredCampaign: user.featuredCampaign,
      legalType: user.legalType,
      registrationDate: user.registrationDate,
      focusAreas: user.focusAreas,
      shortAbout: user.shortAbout,
      keyProgram: user.keyProgram,
      impactSnapshot: user.impactSnapshot,
      phone: user.phone,
      address: user.address,
      instagramLink: user.instagramLink,
      companyName: user.companyName,
      companyLogo: user.companyLogo,
      companyIndustry: user.companyIndustry,
      csrDetails: user.csrDetails,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'name_lowercase': name.toLowerCase(),
      'email': email,
      'photoUrl': photoUrl,
      'tagline': tagline,
      'location': location.toMap(),
      'website': website,
      'isVerrified': isVerified,
      'dharma': dharma,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'badges': earnedBadgeIds,
      'takenStandIds': takenStandIds,
      'joinedCommunities': joinedCommunities,
      'profileType': profileType,
      'ngoName': ngoName,
      'ngoName_lowercase': ngoName.toLowerCase(),
      'ngoMission': ngoMission,
      'ngoLogo': ngoLogo,
      'registrationNumber': registrationNumber,
      'contactInfo': contactInfo,
      'featuredCampaign': featuredCampaign,
      'legalType': legalType,
      'registrationDate': registrationDate,
      'focusAreas': focusAreas,
      'shortAbout': shortAbout,
      'keyProgram': keyProgram,
      'impactSnapshot': impactSnapshot,
      'phone': phone,
      'address': address,
      'instagramLink': instagramLink,
      'companyName': companyName,
      'companyName_lowercase': companyName.toLowerCase(),
      'companyLogo': companyLogo,
      'companyIndustry': companyIndustry,
      'csrDetails': csrDetails,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value == 'true';
    return false;
  }
}
