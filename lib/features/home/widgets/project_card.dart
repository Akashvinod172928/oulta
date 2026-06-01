import 'package:flutter/material.dart';

class Project {
  final String name;
  final String imageAsset;
  final String shortDescription;
  final String longDescription;
  final List<String> galleryImages;
  final String? websiteUrl;

  const Project({
    required this.name,
    required this.imageAsset,
    required this.shortDescription,
    required this.longDescription,
    this.galleryImages = const [],
    this.websiteUrl,
  });
}
