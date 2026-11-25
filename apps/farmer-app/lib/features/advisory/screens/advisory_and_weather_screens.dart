import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/farmer_header.dart';

/// Module 14: Farming AI Assistance & Crop Calendar.
class AdvisoryDashboardScreen extends StatelessWidget {
  const AdvisoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Kisan Advisory & Crop Calendar'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Text(
              'Note: AI & agronomic advisories are decision-support guidance only, not guaranteed crop outcomes.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mic, color: AppColors.primary),
              title: const Text('Voice AI Multilingual Assistant'),
              subtitle: const Text('Ask soil, fertilizer, or irrigation questions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/advisory/voice-ai'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.primary),
              title: const Text('AI Crop Price Forecast'),
              subtitle: const Text('Selling window guidance for Spinach & Tomato'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/advisory/price-forecast'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined, color: AppColors.error),
              title: const Text('Pest Outbreak AI Diagnosis'),
              subtitle: const Text('Fall Armyworm & Downy Mildew Mulshi alerts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/advisory/pest-alerts'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.satellite_alt, color: AppColors.primary),
              title: const Text('Drone Scouting Multispectral Map'),
              subtitle: const Text('Plot B-2 NDVI moisture & chlorophyll view'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/advisory/drone-map'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent, color: AppColors.primary),
              title: const Text('Ask Agronomist & Share Field Tip'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/advisory/ask-agronomist'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.forum_outlined, color: AppColors.primary),
              title: const Text('Community FPO Forum & Audio Q&A'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/community'),
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceAiAssistantScreen extends StatefulWidget {
  const VoiceAiAssistantScreen({super.key});

  @override
  State<VoiceAiAssistantScreen> createState() => _VoiceAiAssistantScreenState();
}

class _VoiceAiAssistantScreenState extends State<VoiceAiAssistantScreen> {
  final _ctrl = TextEditingController();
  String? _statusMsg;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Voice AI Farming Assistant'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask a question in Marathi, Hindi, or English (connects to FastAPI AI Service on port 8000 when running).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. When should I irrigate Rabi spinach in Mulshi?',
                suffixIcon: Icon(Icons.mic, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _statusMsg =
                        'AI Service (localhost:8000) is not connected in offline mode. Start `scripts/start-ai.bat` to receive live RAG guidance.';
                  });
                },
                child: const Text('Ask Kisan AI'),
              ),
            ),
            if (_statusMsg != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(_statusMsg!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PriceForecastScreen extends StatelessWidget {
  const PriceForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'AI Crop Price Forecast'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              title: Text('गावरान पालक (Baby Spinach)'),
              subtitle: Text('Guidance: Harvest at 5:00 AM for Grade A+ retention.'),
              trailing: Chip(label: Text('Guidance')),
            ),
          ),
        ],
      ),
    );
  }
}

class DroneScoutingScreen extends StatelessWidget {
  const DroneScoutingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Drone Scouting NDVI Map'),
      body: const Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.satellite_alt, size: 54, color: AppColors.primary),
                SizedBox(height: 10),
                Text('Plot B-2: Desi Tomatoes (NDVI 0.78 - Healthy)'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PestAlertsScreen extends StatelessWidget {
  const PestAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Pest Outbreak Alerts'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.warning_amber, color: AppColors.error),
              title: Text('Downy Mildew Watch — Mulshi Belt'),
              subtitle: Text('Advisory: Inspect lower leaves after morning dew.'),
            ),
          ),
        ],
      ),
    );
  }
}

class AskAgronomistScreen extends StatelessWidget {
  const AskAgronomistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Ask Agronomist'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Describe crop symptom or share a field tip',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Submitted to Mulshi FPO Agronomist.')),
                  );
                  context.pop();
                },
                child: const Text('Send to Agronomist'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityForumScreen extends StatelessWidget {
  const CommunityForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Community FPO Forum'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: const [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.record_voice_over)),
              title: Text('Babanrao Jadhav • Mulshi FPO'),
              subtitle: Text('Audio Tip (0:42): Vermicompost dosage for Rabi Spinach'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Module 15: Weather Intelligence (honest provider status).
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const FarmerStackAppBar(title: 'Weather Intelligence'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MULSHI MICRO-CLIMATE',
                    style: TextStyle(
                        color: AppColors.tertiaryFixed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('21°C • Mild Morning Dew',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                Text('फवारणीसाठी अतिशय अनुकूल वेळ (Low Wind • 82% Humidity)',
                    style: TextStyle(color: AppColors.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.primary),
              title: Text('Weather Provider Integration'),
              subtitle: Text(
                  'Live IMD/OpenWeather telemetry syncs when backend weather gateway is configured.'),
            ),
          ),
        ],
      ),
    );
  }
}
