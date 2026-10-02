import 'package:flutter_test/flutter_test.dart';
import 'package:kisan_mitra/services/kisan_chat_service.dart';
import 'package:kisan_mitra/models/mandi_rate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockRates = [
    MandiRate(
      market: 'Neemuch APMC',
      commodity: 'Garlic',
      variety: 'Desi',
      grade: 'FAQ',
      minPrice: 9000,
      maxPrice: 15500,
      modalPrice: 13000,
      arrivalDate: '02/10/2026',
      state: 'Madhya Pradesh',
      district: 'Neemuch',
    ),
    MandiRate(
      market: 'Indore APMC',
      commodity: 'Soyabean',
      variety: 'Yellow',
      grade: 'FAQ',
      minPrice: 4200,
      maxPrice: 4850,
      modalPrice: 4600,
      arrivalDate: '02/10/2026',
      state: 'Madhya Pradesh',
      district: 'Indore',
    ),
    MandiRate(
      market: 'Kota APMC',
      commodity: 'Mustard',
      variety: 'Black',
      grade: 'FAQ',
      minPrice: 5100,
      maxPrice: 5600,
      modalPrice: 5450,
      arrivalDate: '02/10/2026',
      state: 'Rajasthan',
      district: 'Kota',
    ),
  ];

  test('Disease query returns disease prescription, NOT mandi bhav', () async {
    final response = await KisanChatService.processMessage(
      'चने में इल्ली लग गई है कौन सी दवा डालें',
      liveRates: mockRates,
    );
    expect(response.type, ChatMessageType.cropDisease);
    expect(response.disease, isNotNull);
    expect(response.disease!.diseaseNameHindi, contains('इल्ली'));
  });

  test('Mandi + crop query returns mandi bhav card', () async {
    final response = await KisanChatService.processMessage(
      'नीमच में लहसुन का भाव क्या है',
      liveRates: mockRates,
    );
    expect(response.type, ChatMessageType.mandiRate);
    expect(response.mandiRate, isNotNull);
    expect(response.mandiRate!.market, contains('Neemuch'));
  });

  test('Crop alone returns top bhav list for that crop', () async {
    final response = await KisanChatService.processMessage(
      'सोयाबीन',
      liveRates: mockRates,
    );
    expect(response.type, ChatMessageType.mandiRate);
    expect(response.mandiRate != null || (response.alternativeRates != null && response.alternativeRates!.isNotEmpty), isTrue);
  });

  test('Disease query for mustard aphid returns disease prescription', () async {
    final response = await KisanChatService.processMessage(
      'सरसों में माहू और चेपा का क्या इलाज है',
      liveRates: mockRates,
    );
    expect(response.type, ChatMessageType.cropDisease);
    expect(response.disease, isNotNull);
  });

  test('Disease query with yellowing/symptoms returns disease prescription', () async {
    final response = await KisanChatService.processMessage(
      'लहसुन में पीलापन आ रहा है क्या स्प्रे करें',
      liveRates: mockRates,
    );
    expect(response.type, ChatMessageType.cropDisease);
    expect(response.disease, isNotNull);
  });

  test('Unrelated query does not return mandi bhav or wrong disease', () async {
    final response = await KisanChatService.processMessage(
      'मौसम कैसा रहेगा आज',
      liveRates: mockRates,
    );
    expect(response.type, ChatMessageType.suggestions);
  });
}
