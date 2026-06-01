import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'web_image.dart';

/// Returns an ImageProvider (NetworkImage or MemoryImage) based on the URL format.
ImageProvider getUniversalImageProvider(String url) {
  if (url.isEmpty) {
    return const AssetImage('assets/images/placeholder_user.png');
  }

  if (url.startsWith('data:')) {
    try {
      final base64String = url.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      debugPrint('Error decoding base64 image provider: $e');
      return const NetworkImage('');
    }
  }
  return CachedNetworkImageProvider(url);
}

/// A Widget that renders an image from either a URL or a Base64 string.
class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholderOrIcon();
    }

    if (imageUrl.startsWith('data:')) {
      return _buildMemoryImage();
    }

    // Standard Network Image
    if (kIsWeb) {
      // By dynamically using HtmlElementView with an HTML <img> tag, we completely 
      // bypass CanvasKit's strict CORS security policies. The image will load natively!
      return buildWebImage(imageUrl, width, height, fit);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade100,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black26,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('UniversalImage CachedNetworkImage error for URL: $url');
        debugPrint('Error detail: $error');
        // Fallback to standard Image.network which is more reliable on some platforms
        return Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, err, stack) {
            debugPrint('UniversalImage fallback Image.network error: $err');
            return _buildErrorWidget(error: err.toString(), url: imageUrl);
          },
        );
      },
    );
  }

  Widget _buildMemoryImage() {
    try {
      final base64String = imageUrl.split(',').last;
      return Image.memory(
        base64Decode(base64String),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('UniversalImage memory error: $error');
          return _buildErrorWidget(error: error.toString(), url: 'data:...');
        },
      );
    } catch (e) {
      debugPrint('UniversalImage decoding error: $e');
      return _buildErrorWidget(error: e.toString(), url: 'data:...');
    }
  }

  Widget _buildPlaceholderOrIcon() {
    return SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _buildErrorWidget({String? error, String? url}) {
    if (error != null) {
      debugPrint('UniversalImage fallback error caught: $error for $url');
    }
    return Container(
      width: width,
      height: height,
      color: Colors.black87,
      child: Center(
        child: SvgPicture.asset(
          'assets/social_icons/Black and Purple Gradient Coming Soon A4 Landscape.svg',
          fit: BoxFit.cover,
          width: width,
          height: height,
        ),
      ),
    );
  }
}
