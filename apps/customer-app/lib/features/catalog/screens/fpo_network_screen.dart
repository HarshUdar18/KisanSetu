import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `fpo_farmer_network_chronicles` backed by `/api/v1/fpos`.
class FpoNetworkScreen extends StatefulWidget {
  const FpoNetworkScreen({super.key});

  @override
  State<FpoNetworkScreen> createState() => _FpoNetworkScreenState();
}

class _FpoNetworkScreenState extends State<FpoNetworkScreen> {
  List<Map<String, dynamic>> _fpos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFpos();
  }

  Future<void> _loadFpos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = context.read<DioClient>();
      final res = await dio.get('/fpos');
      final raw = res.data['data'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _fpos = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load FPO network. Tap retry.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'FPO Farmer Network & Chronicles'),
      body: RefreshIndicator(
        onRefresh: _loadFpos,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VERIFIED FPO NETWORK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tertiaryFixed,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Meet the Collectives Growing Your Morning Basket',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(_error!),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadFpos, child: const Text('Retry')),
                    ],
                  ),
                ),
              )
            else if (_fpos.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No FPO organizations registered yet.'),
                ),
              )
            else
              ..._fpos.map((f) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: const CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.surfaceContainer,
                        child: Icon(Icons.agriculture, color: AppColors.primary),
                      ),
                      title: Text((f['name'] ?? 'FPO Collective').toString(),
                          style: Theme.of(context).textTheme.labelLarge),
                      subtitle: Text(
                        '${f['district'] ?? ''}, ${f['state'] ?? ''} • Reg: ${f['registrationNumber'] ?? '-'}\nMembers: ${f['memberCount'] ?? 0} • Status: ${f['status'] ?? 'ACTIVE'}',
                      ),
                      isThreeLine: true,
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
