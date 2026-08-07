import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Credits, ported from the old app's static "About" tab (tab3_card.dart)
/// into its own screen reachable from Settings, with cleaner layout.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ContentBounds(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 4),
            const _CreditSection(
              imageAsset: 'assets/dzo.png',
              title: 'སློབ་སྟོན།',
              body:
                  'རྫོང་ཁའི་ཡི་གུ་མཛུབ་གནོན་རྐྱབ་ནིའི་དོན་ལུ་ རྫོང་ཁ་ཡོད་པའི་ལྡེ་སྒྲོམ་བཙུགས་གནང།\n\n'
                  'To type in Dzongkha, install a Dzongkha-compatible keyboard '
                  'on your device.',
            ),
            const _CreditSection(
              imageAsset: 'assets/ddc.jpg',
              title: 'རིམ་ལུགས་ཀྱི་སྐོར།',
              body:
                  'འགྲུལ་འཕྲིན་རིམ་ལུགས་འདི་ནང་ རྫོང་ཁ་གོང་འཕེལ་ལྷན་ཚོགས་ཀྱི་རྫོང་ཁའི་ཚིག་མཛོད།\n'
                  'རྫོང་ཁ་ཨིང་སྐད་དང་ཨིང་སྐད་རྫོང་ཁ་ཚུ་ཡོདཔ་ཨིན།\n\n'
                  '© རྫོང་ཁ་གོང་འཕེལ་ལྷན་ཚོགས། ༢༠༢༠\n'
                  '༩༧༥-༠༢༣༢༢༦༦༣\n'
                  'www.dzongkha.gov.bt\n'
                  'ddc@dzongkha.gov.bt',
            ),
            const _CreditSection(
              imageAsset: 'assets/ddc.jpg',
              title: 'མི་མང་གི་དོན་ལུ་རིམ་ལུགས་བཟོ་མི།',
              body: 'གཞུང་ལས་མི་སེར་ཞབས་ཏོག་ཡིག་ཚང།\n'
                  'ལྷན་རྒྱས་གཞུང་ཚོགས།\n'
                  'འབྲུག  ཐིམ་ཕུག  ཆུ་བར་ཆུ།\n'
                  '༩༧༥-༠༢༣༣༩༦༥༥\n'
                  'www.citizenservices.gov.bt\n'
                  'g2c@cabinet.gov.bt',
            ),
            const _CreditSection(
              imageAsset: 'assets/cst.png',
              title: 'ཐོན་རིམ་གཉིས་པ་བཟོ་མི།',
              body: 'ཚན་རིག་དང་འཕྲུལ་རིག་མཐོ་རིམ་སློབ་གྲྭ།\n'
                  'མི་ངོམ།  ༡༽ དོན་གྲུབ་ཆོས་འཕེལ།\n'
                  '        ༢༽ ཀུན་བཟང་ཆོས་སྒྲོན།\n'
                  '        ༣༽ འཕྲིན་ལས་རྡོ་རྗེ།\n'
                  'www.cst.edu.bt\n'
                  'itd.cst@rub.edu.bt',
              showDivider: false,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'DDC Dictionary v2.0',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CreditSection extends StatelessWidget {
  const _CreditSection({
    required this.imageAsset,
    required this.title,
    required this.body,
    this.showDivider = true,
  });

  final String imageAsset;
  final String title;
  final String body;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'jomolhari',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(imageAsset,
                    width: 56, height: 56, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'jomolhari',
                    height: 1.7,
                    wordSpacing: 2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 20),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}
