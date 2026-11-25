import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';

/// Implements Stitch Collection, Weighbridge, QC Lab & Cold-Chain screens.
class CollectionDashboardScreen extends StatelessWidget {
  const CollectionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Collection & Quality Center'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_2, color: AppColors.primary),
              title: const Text('Collection Slot & Gate Pass'),
              subtitle: const Text('Mulshi Dawn Hub • Tomorrow 5:15 AM'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/collection/gate-pass'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.handshake_outlined, color: AppColors.primary),
              title: const Text('Farmgate Dispatch Handover'),
              subtitle: const Text('Confirm crate handover to transporter'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/collection/handover'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.scale_outlined, color: AppColors.primary),
              title: const Text('Weighbridge Intake & Tare Slip'),
              subtitle: const Text('Digital net-weight verification slip'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/collection/weighbridge'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.science_outlined, color: AppColors.primary),
              title: const Text('APMC Lab Assay & Grade Card'),
              subtitle: const Text('Residue-free & Brix moisture report'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/qc/assay'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel_outlined, color: AppColors.error),
              title: const Text('QC Grade Dispute & Re-Sampling'),
              subtitle: const Text('Request independent re-assay'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/qc/dispute'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ac_unit, color: AppColors.primary),
              title: const Text('Cold-Chain Logistics & GPS'),
              subtitle: const Text('Reefer telemetry & live transporter'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/logistics'),
            ),
          ),
        ],
      ),
    );
  }
}

class GatePassScreen extends StatelessWidget {
  const GatePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Collection Hub Gate Pass'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_2, size: 130, color: AppColors.primary),
                const SizedBox(height: 10),
                Text('GATE PASS #GP-MUL-408',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Text('Mulshi Dawn Hub • Slot: 5:15 AM – 6:00 AM'),
                const SizedBox(height: 12),
                const Chip(label: Text('Confirmed & Reserved')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FarmgateHandoverScreen extends StatefulWidget {
  const FarmgateHandoverScreen({super.key});

  @override
  State<FarmgateHandoverScreen> createState() => _FarmgateHandoverScreenState();
}

class _FarmgateHandoverScreenState extends State<FarmgateHandoverScreen> {
  bool _handedOver = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Farmgate Dispatch Handover'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Lot #LOT-SP-9021 • Baby Spinach'),
                subtitle: const Text('12 Crates (120 kg) • Transporter: Tukaram Garud'),
                trailing: Chip(
                  label: Text(_handedOver ? 'HANDED OVER' : 'READY'),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handedOver
                    ? null
                    : () => setState(() => _handedOver = true),
                child: Text(_handedOver
                    ? 'Produce Handed Over'
                    : 'Confirm Crate Handover'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeighbridgeSlipScreen extends StatelessWidget {
  const WeighbridgeSlipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Weighbridge Intake & Tare Slip'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mulshi Dawn Hub Weighbridge',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Divider(height: 20),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Gross Weight'), Text('134.5 kg')]),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Crate Tare Weight'), Text('14.5 kg')]),
                const Divider(height: 20),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Net Verified Weight',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('120.0 kg',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApmcAssayScreen extends StatelessWidget {
  const ApmcAssayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'APMC Lab Assay & Grade Card'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fresh Baby Spinach • Grade A+',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Pesticide Residue: 0.00 ppm (PASS)'),
                  const Text('Leaf Moisture: 91.2% (Optimal)'),
                  const Text('Inspected By: Pune APMC Quality Lab'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QcDisputeScreen extends StatefulWidget {
  const QcDisputeScreen({super.key});

  @override
  State<QcDisputeScreen> createState() => _QcDisputeScreenState();
}

class _QcDisputeScreenState extends State<QcDisputeScreen> {
  bool _raised = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'QC Grade Dispute & Re-Sampling'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: ListTile(
                title: Text('Lot #SP-412 Moisture Adjustment'),
                subtitle: Text('Deduction: -2.1 kg (-₹88.20)'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _raised ? null : () => setState(() => _raised = true),
                child: Text(_raised
                    ? 'Re-Sampling Request Submitted'
                    : 'Request Independent Re-Sampling'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColdChainLogisticsScreen extends StatelessWidget {
  const ColdChainLogisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Cold-Chain Logistics Overview'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping, color: AppColors.primary),
              title: const Text('Live Transporter GPS'),
              subtitle: const Text('Tukaram Garud • MH-12-KS-8810'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/logistics/gps'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.thermostat, color: AppColors.primary),
              title: const Text('Reefer Temperature & Humidity'),
              subtitle: const Text('8.4°C • 85% RH (Within Target)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/logistics/telemetry'),
            ),
          ),
        ],
      ),
    );
  }
}

class TransporterGpsScreen extends StatelessWidget {
  const TransporterGpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Live Transporter Status'),
      body: const Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping, size: 54, color: AppColors.primary),
                SizedBox(height: 10),
                Text('Tukaram Garud • MH-12-KS-8810',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text('Route: Mulshi Dawn Hub -> Kothrud Cold Storage'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Temperature & Humidity Telemetry'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('Crate Sensor #TH-204'),
              subtitle: Text('Temperature: 8.4°C • Humidity: 85% RH'),
              trailing: Chip(label: Text('Optimal')),
            ),
          ),
        ],
      ),
    );
  }
}
