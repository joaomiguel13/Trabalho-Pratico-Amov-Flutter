import 'package:flutter/material.dart';

class LikeInfo extends StatelessWidget {
  const LikeInfo({
    super.key,
    required this.likeCount,
    required this.isLiked,
    required this.onLike,
    required this.dislikeCount,
    required this.isDisliked,
    required this.onDislike,
  });

  final int likeCount;
  final bool isLiked;
  final VoidCallback onLike;
  final int dislikeCount;
  final bool isDisliked;
  final VoidCallback onDislike;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.thumb_up),
              color: isLiked ? Colors.green : Colors.black,
              onPressed: isDisliked ? null : onLike,
            ),
            const SizedBox(width: 8.0),
            Text(
              likeCount.toString(),
            ),
          ],
        ),
        const SizedBox(width: 48.0),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.thumb_down),
              color: isDisliked ? Colors.red : Colors.black,
              onPressed: isLiked ? null : onDislike,
            ),
            const SizedBox(width: 8.0),
            Text(
              dislikeCount.toString(),
            ),
          ],
        ),
      ],
    );
  }
}
