import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/work_model.dart';
import '../../providers/work_provider.dart';
import '../../widgets/booking_status_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/marketplace_widgets.dart';
import '../../widgets/service_illustration.dart';

class WorkTrackingScreen extends StatefulWidget {
  const WorkTrackingScreen({super.key});
  @override
  State<WorkTrackingScreen> createState() => _WorkTrackingScreenState();
}

class _WorkTrackingScreenState extends State<WorkTrackingScreen>
    with WidgetsBindingObserver {
  late int _workId;
  late WorkProvider _provider;
  WorkModel? _work;
  Timer? _pollTimer;
  bool _initialized = false;
  bool _refreshing = false;
  bool _editing = false;
  bool _cancelling = false;
  String? _loadError;

  bool get _terminal =>
      _work?.status == WorkStatus.completed ||
      _work?.status == WorkStatus.cancelled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _workId = ModalRoute.of(context)!.settings.arguments as int;
    _provider = context.read<WorkProvider>();
    // A previously viewed booking must never appear while this one loads.
    final cached = _provider.currentWork;
    _work = cached?.id == _workId ? cached : null;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refresh();
      _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
        if (!mounted ||
            _terminal ||
            ModalRoute.of(context)?.isCurrent == false) {
          return;
        }
        final lifecycle = WidgetsBinding.instance.lifecycleState;
        if (lifecycle == null || lifecycle == AppLifecycleState.resumed) {
          _refresh();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (_refreshing || _editing || _cancelling) return;
    setState(() => _refreshing = true);
    await _provider.loadWorkById(_workId);
    if (!mounted) return;
    setState(() {
      _refreshing = false;
      _loadError = _provider.errorMessage;
      if (_loadError == null && _provider.currentWork?.id == _workId) {
        _work = _provider.currentWork;
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Cancel this booking?'),
              content: const Text(
                  'This will close your request. You can make a new booking later.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Keep booking')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Cancel booking')),
              ],
            ));
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    final success = await _provider.cancelWork(_workId);
    if (!mounted) return;
    setState(() => _cancelling = false);
    if (success) {
      setState(() => _work = _work?.copyWithStatus(WorkStatus.cancelled));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      if (Navigator.canPop(context)) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_provider.errorMessage ??
              'Couldn’t cancel this booking. Please try again.')));
      _refresh();
    }
  }

  Future<void> _showEditSheet() async {
    final work = _work;
    if (work == null) return;
    setState(() => _editing = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _EditBookingSheet(work: work, provider: _provider),
    );
    if (!mounted) return;
    setState(() => _editing = false);
    await _refresh();
  }

  Future<void> _open(String route, {Object? arguments}) async {
    await Navigator.pushNamed(context, route, arguments: arguments ?? _workId);
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final work = _work;
    final canEdit = work != null &&
        (work.status == WorkStatus.posted ||
            work.status == WorkStatus.notified);
    final canTrack = work != null &&
        const {
          WorkStatus.accepted,
          WorkStatus.workerOnTheWay,
          WorkStatus.arrived
        }.contains(work.status);
    final busy = _refreshing || _editing || _cancelling;
    return Scaffold(
      appBar: AppBar(title: const Text('Your booking'), actions: [
        IconButton(
            tooltip: 'Refresh booking',
            onPressed: busy ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 22)),
        const SizedBox(width: 8),
      ]),
      body: SafeArea(
          child: work == null
              ? _loadError == null
                  ? const LoadingIndicator()
                  : Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: RetryPanel(
                              message: 'We couldn’t load this booking.',
                              onRetry: _refresh)))
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    children: [
                      if (_loadError != null) ...[
                        Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E6),
                                borderRadius: BorderRadius.circular(14)),
                            child: const Row(children: [
                              Icon(Icons.wifi_off_rounded,
                                  size: 18, color: AppColors.textSecondary),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Text(
                                      'Couldn’t refresh. Showing the last known status.',
                                      style: TextStyle(fontSize: 12))),
                            ])),
                        const SizedBox(height: 14),
                      ],
                      BookingStatusCard(status: work.status),
                      if (!_terminal)
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.sync_rounded,
                                      color: AppColors.textSecondary, size: 13),
                                  const SizedBox(width: 6),
                                  Flexible(
                                      child: Text(
                                          _loadError != null
                                              ? 'Pull down to try again'
                                              : 'Status updates automatically',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary))),
                                ])),
                      if (work.status != WorkStatus.cancelled) ...[
                        const SizedBox(height: 24),
                        BookingProgress(status: work.status),
                      ],
                      const SizedBox(height: 26),
                      _BookingDetails(work: work),
                      const SizedBox(height: 20),
                      if (canEdit) ...[
                        const _NextStep(
                            icon: Icons.person_search_outlined,
                            title: 'What happens next?',
                            message:
                                'Once a professional accepts, their location and your service start code will be available here.'),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                              child: TextButton.icon(
                                  onPressed: busy ? null : _showEditSheet,
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 17),
                                  label: const Text('Edit request',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)))),
                          Container(
                              height: 18, width: 1, color: AppColors.border),
                          Expanded(
                              child: TextButton(
                                  onPressed: busy ? null : _confirmCancel,
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary),
                                  child: Text(
                                      _cancelling
                                          ? 'Cancelling…'
                                          : 'Cancel booking',
                                      style: const TextStyle(fontSize: 12)))),
                        ]),
                      ],
                      if (canTrack) ...[
                        const _NextStep(
                            icon: Icons.password_rounded,
                            title: 'Your service start code',
                            message:
                                'Share the code with your professional only when they arrive, so work can begin.'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                            onPressed: () => _open(AppRoutes.workerMap),
                            icon: const Icon(Icons.map_outlined, size: 19),
                            label: const Text('View professional’s location',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13))),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                            onPressed: () =>
                                _open(AppRoutes.showOtp, arguments: work),
                            icon: const Icon(Icons.password_outlined, size: 19),
                            label: const Text('Show start code',
                                style: TextStyle(fontSize: 13))),
                      ],
                      if (work.status == WorkStatus.started)
                        const _NextStep(
                            icon: Icons.handyman_outlined,
                            title: 'Work is underway',
                            message:
                                'Your professional will mark the service complete when the job is finished.'),
                      if (work.status == WorkStatus.completed)
                        ElevatedButton(
                            onPressed: () => _open(AppRoutes.completedWork),
                            child: const Text('View completed booking',
                                textAlign: TextAlign.center)),
                      if (work.status == WorkStatus.cancelled)
                        ElevatedButton(
                            onPressed: () => _open(AppRoutes.selectCategory),
                            child: const Text('Browse services')),
                    ],
                  ))),
    );
  }
}

class _BookingDetails extends StatelessWidget {
  final WorkModel work;
  const _BookingDetails({required this.work});
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(work.createdAt);
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ServiceIllustration(
                category: work.categoryName ?? 'Repair', size: 54),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(work.categoryName ?? 'Home service',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(work.title,
                      style: const TextStyle(
                          fontSize: 17,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.3)),
                ])),
          ]),
          if (work.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Text(work.description!,
                style: const TextStyle(
                    fontSize: 12, height: 1.6, color: AppColors.textSecondary)),
          ],
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: AppColors.border)),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _Detail(
                    label: 'Booking ID',
                    value: '#${work.id.toString().padLeft(4, '0')}')),
            if (date != null)
              Expanded(
                  child: _Detail(
                      label: 'Requested on',
                      value: DateFormat('d MMM yyyy').format(date))),
          ]),
        ]));
  }
}

class _Detail extends StatelessWidget {
  final String label, value;
  const _Detail({required this.label, required this.value});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ]);
}

class _NextStep extends StatelessWidget {
  final IconData icon;
  final String title, message;
  const _NextStep(
      {required this.icon, required this.title, required this.message});
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 18, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(message,
              style: const TextStyle(
                  fontSize: 11, height: 1.6, color: AppColors.textSecondary)),
        ])),
      ]);
}

class _EditBookingSheet extends StatefulWidget {
  final WorkModel work;
  final WorkProvider provider;
  const _EditBookingSheet({required this.work, required this.provider});
  @override
  State<_EditBookingSheet> createState() => _EditBookingSheetState();
}

class _EditBookingSheetState extends State<_EditBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.work.title);
  late final _description =
      TextEditingController(text: widget.work.description ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final success = await widget.provider.updateWork(widget.work.id,
        title: _title.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim());
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = widget.provider.errorMessage ??
            'Couldn’t save your changes. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            22,
            0,
            22,
            MediaQuery.viewInsetsOf(context).bottom +
                MediaQuery.paddingOf(context).bottom +
                22),
        child: Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit your request',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.5)),
                  const SizedBox(height: 8),
                  const Text('A few details help your professional prepare.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 22),
                  TextFormField(
                      controller: _title,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                          labelText: 'What do you need help with?'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please add a short title.'
                              : null),
                  const SizedBox(height: 14),
                  TextFormField(
                      controller: _description,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                          labelText: 'A little more detail (optional)'),
                      minLines: 3,
                      maxLines: 5),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 12))),
                  const SizedBox(height: 22),
                  ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Saving…' : 'Save changes')),
                ])),
      );
}
