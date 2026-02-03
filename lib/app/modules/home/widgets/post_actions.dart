import 'package:flutter/material.dart';

class PostActions extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostActions({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PostActionButton(
            icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: '$likeCount',
            color: isLiked ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
            onTap: onLike,
            filled: isLiked,
          ),
          PostActionButton(
            icon: Icons.comment_outlined,
            label: '$commentCount',
            color: const Color(0xFF6B7280),
            onTap: onComment,
          ),
          const SizedBox(width: 4),
          PostActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            color: const Color(0xFF6B7280),
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const PostActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
            fill: filled ? 1.0 : 0.0,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


