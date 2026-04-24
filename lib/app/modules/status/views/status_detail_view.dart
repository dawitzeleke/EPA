import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eprs/core/utils/secure_log.dart';
import '../controllers/status_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class StatusDetailView extends StatefulWidget {
  final ReportItem report;

  const StatusDetailView({super.key, required this.report});

  @override
  State<StatusDetailView> createState() => _StatusDetailViewState();
}

class _StatusDetailViewState extends State<StatusDetailView> {
  ReportItem? _fullReport;
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchFullReport();
  }

  Future<void> _fetchFullReport() async {
    if (widget.report.id == null) {
      setState(() {
        _fullReport = widget.report;
        _isLoading = false;
      });
      return;
    }

    try {
      final controller = Get.find<StatusController>();
      final fullReport = await controller.fetchComplaintById(widget.report.id!);
      
      setState(() {
        if (fullReport != null) {
          _fullReport = fullReport;
        } else {
          // If fetch fails, use the original report
          _fullReport = widget.report;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fullReport = widget.report;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _fullReport ?? widget.report;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: 'Report Status'.tr,
        showBack: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Report Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8F1FF).withValues(alpha: 0.8),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (full width) and badges below to avoid cramped wrapping
                    Text(
                      report.reportType ?? 'N/A',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ID Badge (Blue) - Use report_id
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0047BA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ID: ${report.reportId ?? report.id ?? 'N/A'}',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status, report),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            report.status,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    Text(
                      "Description".tr,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    // Description
                    Builder(
                      builder: (context) {
                        final description = report.description.trim();
                        final isLong = description.length > 220;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              maxLines: _isDescriptionExpanded ? null : 4,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppFonts.primaryFont,
                                fontSize: 14,
                                color: const Color(0xFF8A8F95),
                                height: 1.5,
                              ),
                            ),
                            if (isLong)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isDescriptionExpanded =
                                        !_isDescriptionExpanded;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(top: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _isDescriptionExpanded
                                      ? 'Show less'.tr
                                      : 'Read more'.tr,
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Green divider line
                    Container(
                      height: 1,
                      color: AppColors.primary,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Timeline
                    _buildTimeline(report),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ReportItem report) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'under review':
        return const Color(0xFF3F8ECF);
      case 'verified':
        return const Color(0xFF1E88E5);
      case 'under investigation':
      case 'under_investigation':
        return const Color.fromRGBO(59, 161, 245, 1);
      case 'complete':
      case 'completed':
      case 'closed':
        return const Color.fromRGBO(55, 165, 55, 1);
      case 'closed by penality':
        return const Color(0xFFE04343);
      case 'closed by pollutant not found':
        return const Color(0xFFAAAAAA);
      case 'rejected':
        return const Color.fromRGBO(245, 46, 50, 1);
      default: // Pending
        return const Color.fromRGBO(255, 174, 65, 1);
    }
  }

  /// Build a map of status -> formatted date/time using activity logs when available
  Map<String, String> _buildStatusDates(ReportItem report) {
    final map = <String, String>{};
    final logs = report.activityLogs;
    
    // First, add pending status from report creation date
    final base = _buildDateTimeLabel(report.date, report.time);
    if (base.isNotEmpty) {
      map['pending'] = base;
    }
    
    // Then, add dates from activity logs - each activity log represents a status transition
    // The new_status in the log is the status that was achieved at that time
    if (logs != null && logs.isNotEmpty) {
      for (final log in logs) {
        final newStatus = log.newStatus?.trim() ?? '';
        final createdAt = log.createdAt?.trim() ?? '';
        if (newStatus.isEmpty || createdAt.isEmpty) continue;
        
        // Normalize status name for matching (e.g., "Under Review" -> "under review")
        final normalizedStatus = _normalizeStatusName(newStatus);
        final formattedDate = _formatIsoToDateTimeLabel(createdAt);
        if (formattedDate.isNotEmpty) {
          // Store the date for this normalized status
          // This will be used when displaying the timeline
          map[normalizedStatus] = formattedDate;
        }
      }
    }
    
    return map;
  }

  /// Normalize status name to match timeline stage names
  String _normalizeStatusName(String status) {
    if (status.isEmpty) return '';
    // Trim and normalize to lowercase, replace underscores with spaces
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ');
    // Map variations to standard names (exact matches first, then contains)
    if (normalized == 'pending') {
      return 'pending';
    } else if (normalized == 'under review' || normalized.contains('under review')) {
      return 'under review';
    } else if (normalized == 'verified' || normalized.contains('verified')) {
      return 'verified';
    } else if (normalized == 'under investigation' || normalized.contains('under investigation')) {
      return 'under investigation';
    } else if (normalized == 'complete' || normalized == 'completed' || normalized == 'closed') {
      return 'closed';
    } else if (normalized == 'rejected' || normalized.contains('rejected')) {
      return 'rejected';
    }
    return normalized;
  }

  /// Format ISO date string to match _buildDateTimeLabel format: "HH:MM:SS AM/PM · Mon d, yyyy"
  String _formatIsoToDateTimeLabel(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      
      // Format time: "HH:MM:SS AM/PM"
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final hh = hour12.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final timeStr = '$hh:$mm:$ss $ampm';
      
      // Format date: "Mon d, yyyy"
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final dateStr = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      
      return '$timeStr · $dateStr';
    } catch (_) {
      return '';
    }
  }

  Widget _buildTimeline(ReportItem report) {
    final baseDateTimeLabel = _buildDateTimeLabel(report.date, report.time);
    final statusDates = _buildStatusDates(report);
    final logs = report.activityLogs;

    // ─────────────────────────────────────────────────────
    // Build stages dynamically from actual activity logs
    // ─────────────────────────────────────────────────────

    // Collect log entries sorted oldest → newest
    final sortedLogs = <ActivityLog>[];
    if (logs != null && logs.isNotEmpty) {
      sortedLogs.addAll(logs);
      sortedLogs.sort((a, b) {
        try {
          final aTime = a.createdAt != null
              ? DateTime.parse(a.createdAt!).millisecondsSinceEpoch
              : 0;
          final bTime = b.createdAt != null
              ? DateTime.parse(b.createdAt!).millisecondsSinceEpoch
              : 0;
          return aTime.compareTo(bTime); // oldest first
        } catch (_) {
          return 0;
        }
      });
    }

    // Build the list of stages from logs (de-duplicated, preserving order)
    final stages = <Map<String, String>>[];
    final seenKeys = <String>{};

    // Always start with "Pending" (report creation)
    stages.add({'name': 'Pending', 'key': 'pending'});
    seenKeys.add('pending');

    // Add each activity log status as a stage
    for (final log in sortedLogs) {
      final rawStatus = log.newStatus?.trim() ?? '';
      if (rawStatus.isEmpty) continue;
      final normalizedKey = _normalizeStatusName(rawStatus);
      if (seenKeys.contains(normalizedKey)) continue; // skip duplicates
      seenKeys.add(normalizedKey);

      // Determine display name
      String displayName;
      switch (normalizedKey) {
        case 'under review':
          displayName = 'Under Review';
          break;
        case 'verified':
          displayName = 'Verified';
          break;
        case 'under investigation':
          displayName = 'Under Investigation';
          break;
        case 'complete':
          displayName = 'Closed';
          break;
        case 'rejected':
          displayName = 'Rejected';
          break;
        default:
          // Capitalize first letter of each word for unknown statuses
          displayName = rawStatus
              .replaceAll('_', ' ')
              .split(' ')
              .map((w) => w.isEmpty
                  ? w
                  : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
              .join(' ');
      }
      stages.add({'name': displayName, 'key': normalizedKey});
    }

    // If the current report.status is not yet represented, add it as the
    // final (current / in-progress) stage
    final currentKey = _normalizeStatusName(report.status);
    if (!seenKeys.contains(currentKey)) {
      String displayName;
      switch (currentKey) {
        case 'under review':
          displayName = 'Under Review';
          break;
        case 'verified':
          displayName = 'Verified';
          break;
        case 'under investigation':
          displayName = 'Under Investigation';
          break;
        case 'complete':
          displayName = 'Closed';
          break;
        case 'rejected':
          displayName = 'Rejected';
          break;
        case 'pending':
          displayName = 'Pending';
          break;
        default:
          displayName = report.status;
      }
      stages.add({'name': displayName, 'key': currentKey});
    }

    // ─────────────────────────────────────────────────────
    // Determine completed vs active stage
    // ─────────────────────────────────────────────────────
    final isTerminal =
        currentKey == 'closed' || currentKey == 'rejected';
    final isRejected = currentKey == 'rejected';

    // All stages that came from activity logs are "completed".
    // The number of completed stages = all stages if terminal,
    // otherwise everything except the last one (which is current/active).
    int completedStages;
    int activeStageIndex;

    if (isTerminal) {
      completedStages = stages.length;
      activeStageIndex = -1; // no spinner
    } else {
      // The last stage is the "in-progress" one
      completedStages = stages.length - 1;
      activeStageIndex = stages.length - 1;
    }

    // Debug
    secureLog('🔍 Timeline Debug: stages=${stages.map((s) => s['name']).toList()}, '
        'completed=$completedStages, activeStage=$activeStageIndex, '
        'isTerminal=$isTerminal');

    return Column(
      children: List.generate(stages.length, (index) {
        final stage = stages[index];
        final stageName = stage['name']!;
        final stageKey = stage['key']!;
        final isCompleted = index < completedStages;
        final isCurrent = index == activeStageIndex;
        final isLast = index == stages.length - 1;
        final showRejectionMessage = isRejected && isLast && isCompleted;
        final stageDate = statusDates[stageKey];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                // Circle icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? (isRejected && isLast ? Colors.red : AppColors.primary)
                        : (isCurrent ? AppColors.primary : const Color(0xFFE0E0E0)),
                  ),
                  child: isCurrent && !isCompleted
                      ? Center(
                          child: Transform.scale(
                            scale: 1.5,
                            child: SizedBox.square(
                              dimension: 16,
                              child: Image.asset(
                                'assets/progress.png',
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        )
                      : isCompleted
                          ? Icon(
                              isRejected && isLast ? Icons.close : Icons.done,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                ),
                // Vertical line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: isCompleted
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Stage content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stageName,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isCurrent
                          ? Colors.black
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                  if (isCurrent && !isCompleted) // Show message for active stage
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'We are preparing your Doc with care',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (showRejectionMessage) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.description,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: const Color(0xFF8A8F95),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Show date/time — use activity log date for non-pending,
                  // report creation date for pending
                  if (isCompleted || isCurrent)
                    if (stageDate != null)
                      Text(
                        stageDate,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: isRejected && isLast
                              ? Colors.grey
                              : AppColors.primary,
                        ),
                      )
                    else if (stageKey == 'pending' &&
                        baseDateTimeLabel.isNotEmpty)
                      Text(
                        baseDateTimeLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                  if (!isLast) const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

String _buildDateTimeLabel(String date, String? time) {
  final trimmedTime = time?.trim() ?? '';
  if (trimmedTime.isEmpty) return date;
  return '$trimmedTime · $date';
}

