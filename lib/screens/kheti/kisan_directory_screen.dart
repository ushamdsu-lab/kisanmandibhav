import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KisanDirectoryScreen extends StatelessWidget {
  const KisanDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📞 किसान हेल्पलाइन व डायरेक्टरी',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '1-टैप निःशुल्क सरकारी कृषि हेल्पलाइन',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'भारत सरकार और कृषि वैज्ञानिकों से सीधे अपनी मातृभाषा में मुफ्त सलाह पाएं',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('📞 राष्ट्रीय टोल-फ्री हेल्पलाइन (1-Click Call):', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 8),

          _buildHelplineCard(
            context,
            icon: Icons.call,
            color: Colors.green,
            title: 'किसान कॉल सेंटर (KCC)',
            number: '18001801551',
            displayNum: '1800-180-1551',
            desc: 'कृषि वैज्ञानिकों से फसल, बीज, कीट व दवाई पर 22 भाषाओं में मुफ्त सलाह (सुबह 6 से रात 10 बजे)',
          ),
          _buildHelplineCard(
            context,
            icon: Icons.pets,
            color: Colors.blue,
            title: 'पशु संजीवनी राष्ट्रीय हेल्पलाइन',
            number: '1962',
            displayNum: '1962',
            desc: 'पशुओं की बीमारी, आकस्मिक चिकित्सा, टीकाकरण व मोबाइल वेटरनरी क्लिनिक सेवा',
          ),
          _buildHelplineCard(
            context,
            icon: Icons.security,
            color: Colors.orange,
            title: 'प्रधानमंत्री फसल बीमा योजना हेल्पलाइन',
            number: '14447',
            displayNum: '14447',
            desc: 'फसल नुकसान, ओलावृष्टि व जलभराव की 72 घंटे में क्लेम सूचना व शिकायत निवारण',
          ),
          _buildHelplineCard(
            context,
            icon: Icons.credit_card,
            color: Colors.purple,
            title: 'किसान क्रेडिट कार्ड (KCC) बैंक लोन',
            number: '1800112211',
            displayNum: '1800-11-2211',
            desc: '4% रियायती ब्याज दर पर कृषि लोन, नवीनीकरण व बैंक शाखा संबंधित पूछताछ',
          ),

          const SizedBox(height: 20),
          const Text('🚜 ट्रैक्टर व कृषि यंत्र किराया गाइड (Benchmark Rental Rates):', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 8),

          _buildMachineryCard('🚜 रोटावेटर (Rotavator)', '₹600 - ₹800 / बीघा', 'खेत की मिट्टी भुरभुरी करने व जुताई हेतु'),
          _buildMachineryCard('🌾 कंबाइन हार्वेस्टर (Combine Harvester)', '₹1,200 - ₹1,600 / घंटा', 'गेहूं, धान व सोयाबीन कटाई-थ्रेशिंग एक साथ'),
          _buildMachineryCard('📐 लेजर लैंड लेवलर (Laser Land Leveler)', '₹700 - ₹950 / घंटा', '30% पानी की बचत व समतल खेत सिंचाई'),
          _buildMachineryCard('🚁 ड्रोन कीटनाशक स्प्रे (Agri Drone)', '₹250 - ₹350 / एकड़', '10 मिनट में पूरा खेत स्प्रे, दवाई की बचत'),
          _buildMachineryCard('⚙️ मल्टीक्रॉप थ्रेशर (Thresher)', '₹80 - ₹120 / क्विंटल', 'सरसों, चना, मूंग व गेहूं गहाई'),

          const SizedBox(height: 20),
          const Text('🏫 कृषि विज्ञान केंद्र (KVK) संपर्क:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 8),

          _buildKvkInfo('राजस्थान (कोटा / जयपुर / जोधपुर)', 'कृषि विश्वविद्यालय परिसर • मिट्टी परीक्षण व उन्नत बीज उपलब्धता'),
          _buildKvkInfo('मध्य प्रदेश (इंदौर / सीहोर / उज्जैन)', 'RVSKVV परिसर • सोयाबीन, लहसुन व गेहूं तकनीकी प्रदर्शन'),
          _buildKvkInfo('उत्तर प्रदेश (मेरठ / कानपुर / वाराणसी)', 'CSAUAT परिसर • गन्ना, आलू व धान अनुसंधान केंद्र'),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHelplineCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String number,
    required String displayNum,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 2),
                Text(displayNum, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _callNumber(number),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('कॉल करें', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineryCard(String name, String rate, String use) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(use, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(rate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade900)),
          ),
        ],
      ),
    );
  }

  Widget _buildKvkInfo(String state, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Text('🏛️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                Text(details, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _callNumber(String num) async {
    final uri = Uri.parse('tel:$num');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }
}
