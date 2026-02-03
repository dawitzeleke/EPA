import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/status_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'status_detail_view.dart';
// Bottom nav is provided by the app shell; don't import it in this page.

class StatusView extends GetView<StatusController> {
  const StatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(
        title: 'Report Status',
        showBack: true,
        forceHomeOnBack: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final sel = controller.selectedFilter.value;

          // Build scrollable content to avoid overflow in landscape
          Widget buildScrollable(List<Widget> sliverContent) {
            return RefreshIndicator(
              onRefresh: () => controller.refreshComplaints(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 6),
                              _filterChip('All', sel == 'All'),
                              const SizedBox(width: 10),
                              _filterChip('Pending', sel == 'Pending'),
                              const SizedBox(width: 10),
                              _filterChip('Under Review', sel == 'Under Review'),
                              const SizedBox(width: 10),
                              _filterChip('Verified', sel == 'Verified'),
                              const SizedBox(width: 10),
                              _filterChip('Under Investigation', sel == 'Under Investigation'),
                              const SizedBox(width: 10),
                              _filterChip('Closed', sel == 'Closed'),
                              const SizedBox(width: 10),
                              _filterChip('Rejected', sel == 'Rejected'),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ...sliverContent,
                ],
              ),
            );
          }

          // Loading state
          if (controller.isLoading.value) {
            return buildScrollable([
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
            ]);
          }

          // Error state
          if (controller.errorMessage.value != null) {
            return buildScrollable([
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => controller.refreshComplaints(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]);
          }

          final reports = controller.filteredReports;

          // Empty state
          if (reports.isEmpty) {
            return buildScrollable([
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reports found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]);
          }

          // List state
          return buildScrollable([
            SliverList.builder(
              itemCount: reports.length + 1,
              itemBuilder: (context, index) {
                if (index == reports.length) {
                  return const SizedBox(height: 80);
                }
                final r = reports[index];
                return _complaintCard(report: r);
              },
            ),
          ]);
        }),
      ),
    );
  }

  // Compact filter chip (matches screenshot chips)
  Widget _filterChip(String label, bool isActive) {
    return InkWell(
      onTap: () => controller.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          // border: isActive ? null : Border.all(color: const Color(0xFFECEFF6)),
          // boxShadow: isActive
          //     ? [BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]
          //     : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Complaint Card — updated to match the design in the provided image
  Widget _complaintCard({
  required ReportItem report,
}) {
  final description = report.description;
  final date = report.date;
  final time = report.time ?? '';
  final reportType = report.reportType ?? 'N/A';

  // ─────────────────────────────────────────────
  // STRICT STATUS LOGIC
  // ─────────────────────────────────────────────
  // Normalize helper
  String normalize(String s) {
    final n = s.toLowerCase().replaceAll('_', ' ').trim();
    if (n.contains('under review') || n.contains('in review') || n.contains('progress')) return 'Under Review';
    if (n.contains('investigation')) return 'Under Investigation'; // covers under_investigation, investigation_submitted
    if (n.contains('verified')) return 'Verified';
    if (n.contains('complete') || n.contains('closed')) return 'Complete';
    if (n.contains('rejected')) return 'Rejected';
    if (n.contains('pending')) return 'Pending';
    return s;
  }

  final logs = report.activityLogs;
  String statusLabel;
  if (logs != null && logs.isNotEmpty) {
    // Choose the newest log by createdAt; ignore unparsable dates
    ActivityLog? newest;
    int newestTs = -1;
    for (final log in logs) {
      final ts = DateTime.tryParse(log.createdAt ?? '')?.millisecondsSinceEpoch;
      if (ts != null && ts > newestTs) {
        newestTs = ts;
        newest = log;
      }
    }
    final chosen = newest ?? logs.last; // fallback to list order
    statusLabel = normalize((chosen.newStatus ?? report.status).trim());
  } else {
    // No activity logs → fall back to report.status (normalize)
    statusLabel = normalize(report.status.trim());
  }

  // ─────────────────────────────────────────────
  // STATUS COLORS (unchanged)
  // ─────────────────────────────────────────────
  Color pillBg;
  Color pillText;

  switch (statusLabel.toLowerCase()) {
    case "under review":
      pillBg = const Color(0xFF3F8ECF);
      pillText = AppColors.onPrimary;
      break;
    case "verified":
      pillBg = const Color(0xFF1E88E5);
      pillText = AppColors.onPrimary;
      break;
    case "under investigation":
    case "under_investigation":
      pillBg = const Color.fromRGBO(59, 161, 245, 1);
      pillText = AppColors.onPrimary;
      break;
    case "complete":
    case "completed":
    case "closed":
      pillBg = const Color.fromRGBO(55, 165, 55, 1);
      pillText = AppColors.onPrimary;
      break;
    case "closed by penality":
      pillBg = const Color(0xFFE04343);
      pillText = AppColors.onPrimary;
      break;
    case "closed by pollutant not found":
      pillBg = const Color(0xFFAAAAAA);
      pillText = AppColors.onPrimary;
      break;
    case "rejected":
      pillBg = const Color.fromRGBO(245, 46, 50, 1);
      pillText = AppColors.onPrimary;
      break;
    default:
      // 🔹 Pending
      pillBg = const Color.fromRGBO(255, 174, 65, 1);
      pillText = AppColors.onPrimary;
  }

  const outerGlow = Color(0xFFE8F1FF);

  return InkWell(
    onTap: () {
      Get.to(() => StatusDetailView(report: report));
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 13, right: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: outerGlow.withOpacity(0.8),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + STATUS BADGE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reportType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: pillText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // DATE + TIME ROW
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today,
                    color: Color(0xFF1E9B47), size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF5A5F66),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.access_time,
                    color: Color(0xFF1E9B47), size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                time.isNotEmpty ? time : '--',
                style: const TextStyle(
                  color: Color(0xFF5A5F66),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // DESCRIPTION
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8A8F95),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}




}