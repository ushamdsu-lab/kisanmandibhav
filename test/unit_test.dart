import 'package:flutter_test/flutter_test.dart';
import 'package:kisan_mitra/models/crop.dart';
import 'package:kisan_mitra/models/fertilizer.dart';
import 'package:kisan_mitra/models/scheme.dart';
import 'package:kisan_mitra/models/helpline.dart';
import 'package:kisan_mitra/models/mandi_rate.dart';
import 'package:kisan_mitra/models/notification_item.dart';
import 'package:kisan_mitra/models/price_alert.dart';
import 'package:kisan_mitra/utils/whatsapp_share_helper.dart';
import 'package:kisan_mitra/data/mandi_directory.dart';
import 'package:kisan_mitra/data/msp_data.dart';
import 'package:kisan_mitra/config/constants.dart';
import 'package:kisan_mitra/services/ad_service.dart';

void main() {
  group('Model & Architecture Tests', () {
    test('Crop model parses correctly', () {
      final json = {
        'id': 'wheat',
        'name': 'गेहूं',
        'nameEn': 'Wheat',
        'icon': 'grain',
        'season': 'rabi',
        'sowingMonth': 'अक्टूबर-नवंबर',
        'harvestMonth': 'मार्च-अप्रैल',
        'duration': '120-150 दिन',
        'soilType': 'दोमट मिट्टी',
        'waterNeed': '4-6 सिंचाई',
        'temperature': '15-25°C',
        'description': 'गेहूं भारत की प्रमुख रबी फसल है।',
        'steps': [
          {'step': 1, 'title': 'खेत की तैयारी', 'detail': '2-3 बार जुताई करें।'}
        ],
        'pests': [
          {'name': 'दीमक', 'symptom': 'पौधे सूखना', 'remedy': 'दवा छिड़कें'}
        ]
      };

      final crop = Crop.fromJson(json);
      expect(crop.id, 'wheat');
      expect(crop.name, 'गेहूं');
      expect(crop.steps.length, 1);
      expect(crop.pests.length, 1);
    });

    test('Fertilizer model parses correctly and validates dosage per hectare/bigha', () {
      final json = {
        'id': 'urea',
        'name': 'यूरिया',
        'nameEn': 'Urea',
        'nutrient': 'N - 46%',
        'usage': 'बढ़वार के लिए',
        'dosagePerHectare': '100-130 किलो',
        'dosagePerBigha': '12-15 किलो',
        'method': 'छिड़काव',
        'precaution': 'सावधानी रखें',
        'price': '₹266.50',
        'crops': ['wheat', 'rice']
      };

      final fertilizer = Fertilizer.fromJson(json);
      expect(fertilizer.id, 'urea');
      expect(fertilizer.crops.contains('wheat'), isTrue);

      // Verify acre conversion factor
      final matches = RegExp(r'(\d+\.?\d*)').allMatches(fertilizer.dosagePerHectare).map((m) => double.parse(m.group(1)!)).toList();
      expect(matches.length, 2);
      final minAcre = matches[0] / AppConstants.hectareToAcre;
      final maxAcre = matches[1] / AppConstants.hectareToAcre;
      expect(minAcre, closeTo(40.47, 0.5));
      expect(maxAcre, closeTo(52.61, 0.5));
    });

    test('Scheme model parses correctly', () {
      final json = {
        'id': 'pmkisan',
        'name': 'पीएम किसान',
        'nameEn': 'PM Kisan',
        'category': 'वित्तीय सहायता',
        'categoryEn': 'Financial Aid',
        'icon': 'account_balance_wallet',
        'description': '₹6000 सहायता',
        'eligibility': ['किसान'],
        'benefits': ['₹6000 प्रति वर्ष'],
        'howToApply': 'ऑनलाइन आवेदन',
        'website': 'https://pmkisan.gov.in',
        'documents': ['आधार कार्ड']
      };

      final scheme = Scheme.fromJson(json);
      expect(scheme.id, 'pmkisan');
      expect(scheme.benefits.length, 1);
    });

    test('Helpline model parses correctly', () {
      final json = {
        'id': 'kcc',
        'name': 'किसान कॉल सेंटर',
        'nameEn': 'KCC',
        'number': '1800-180-1551',
        'icon': 'support_agent',
        'description': 'कृषि हेल्पलाइन',
        'timing': '24 घंटे',
        'tollFree': true,
        'category': 'कृषि'
      };

      final helpline = Helpline.fromJson(json);
      expect(helpline.number, '1800-180-1551');
      expect(helpline.tollFree, isTrue);
    });

    test('MandiRate model parses and serializes correctly with isLive support', () {
      final json = {
        'state': 'Uttar Pradesh',
        'district': 'Agra',
        'market': 'Agra',
        'commodity': 'Wheat',
        'variety': 'Dara',
        'grade': 'FAQ',
        'min_price': '2200',
        'max_price': 2500,
        'modal_price': '2350',
        'arrival_date': '12/08/2026',
        'isLive': true,
      };

      final rate = MandiRate.fromJson(json);
      expect(rate.commodity, 'Wheat');
      expect(rate.minPrice, 2200.0);
      expect(rate.maxPrice, 2500.0);
      expect(rate.modalPrice, 2350.0);
      expect(rate.isLive, isTrue);

      final encoded = rate.toJson();
      expect(encoded['isLive'], isTrue);
      expect(encoded['commodity'], 'Wheat');
    });

    test('MSP Database accurately categorizes CACP official MSP vs market baseline', () {
      final wheatMsp = MspDatabase.getMspForCrop('wheat');
      expect(wheatMsp, isNotNull);
      expect(wheatMsp!.isOfficialMsp, isTrue);
      expect(wheatMsp.mspPrice, 2275.0);

      final mustardMsp = MspDatabase.getMspForCrop('mustard');
      expect(mustardMsp, isNotNull);
      expect(mustardMsp!.isOfficialMsp, isTrue);
      expect(mustardMsp.mspPrice, 5650.0);

      final jeeraBaseline = MspDatabase.getMspForCrop('jeera');
      expect(jeeraBaseline, isNotNull);
      expect(jeeraBaseline!.isOfficialMsp, isFalse);
      expect(jeeraBaseline.category, 'baseline');
    });

    test('NotificationItem model parses correctly', () {
      final json = {
        'id': 'notif_123',
        'title': '🌾 बीकानेर मंडी भाव अपडेट',
        'body': 'चना ₹6200 प्रति क्विंटल',
        'timestamp': '2026-08-14T00:00:00.000Z',
        'mandi': 'Bikaner (Grain) APMC',
        'district': 'Bikaner',
        'state': 'Rajasthan',
        'type': 'rate_update',
        'isRead': false,
      };

      final notif = NotificationItem.fromJson(json);
      expect(notif.id, 'notif_123');
      expect(notif.mandi, 'Bikaner (Grain) APMC');
      expect(notif.isRead, isFalse);
    });

    test('MandiDirectory resolves Jodhpur district mandis in both Hindi and English', () {
      final englishMandis = MandiDirectory.getMandisForDistrict('Rajasthan', 'Jodhpur');
      expect(englishMandis.contains('Jodhpur (Grain) APMC'), isTrue);
      expect(englishMandis.contains('Bilara APMC'), isTrue);

      final hindiMandis = MandiDirectory.getMandisForDistrict('Rajasthan', 'जोधपुर');
      expect(hindiMandis.contains('Jodhpur (Grain) APMC'), isTrue);
      expect(hindiMandis.contains('Bilara APMC'), isTrue);

      expect(MandiDirectory.getStandardDistrictName('Rajasthan', 'जोधपुर'), 'Jodhpur');
      expect(MandiDirectory.getStandardDistrictName('Rajasthan', 'Jodhpur'), 'Jodhpur');
    });

    test('PriceAlert model parses and encodes correctly', () {
      final alert = PriceAlert(
        id: 'alert_1',
        commodity: 'Jeera',
        market: 'Jodhpur (Grain) APMC',
        district: 'Jodhpur',
        targetPrice: 28000,
      );

      expect(alert.commodity, 'Jeera');
      expect(alert.targetPrice, 28000.0);
      expect(alert.isTriggered, isFalse);

      final encoded = PriceAlert.encodeList([alert]);
      final decoded = PriceAlert.decodeList(encoded);
      expect(decoded.length, 1);
      expect(decoded.first.commodity, 'Jeera');
      expect(decoded.first.targetPrice, 28000.0);
    });

    test('WhatsAppShareHelper generates valid formatted text slip', () {
      final rate = MandiRate(
        state: 'Rajasthan',
        district: 'Jodhpur',
        market: 'Jodhpur (Grain) APMC',
        commodity: 'Jeera',
        variety: 'FAQ',
        grade: 'FAQ',
        minPrice: 25000,
        maxPrice: 29000,
        modalPrice: 27500,
        arrivalDate: '14/08/2026',
      );

      final singleSlip = WhatsAppShareHelper.generateSingleCropParchiText(rate: rate);
      expect(singleSlip.contains('जीरा'), isTrue);
      expect(singleSlip.contains('27500'), isTrue);
      expect(singleSlip.contains('जोधपुर'), isTrue);

      final mandiSlip = WhatsAppShareHelper.generateMandiParchiText(
        state: 'Rajasthan',
        district: 'Jodhpur',
        market: 'Jodhpur (Grain) APMC',
        rates: [rate],
      );
      expect(mandiSlip.contains('किसान मंडी भाव'), isTrue);
      expect(mandiSlip.contains('27500'), isTrue);
    });

    test('AdService configures test IDs and safe fallback parameters correctly', () {
      expect(AdService.isTestMode, isTrue);
      expect(AdService.bannerAdUnitId.isNotEmpty, isTrue);
      expect(AdService.interstitialAdUnitId.isNotEmpty, isTrue);
      expect(AdService.rewardedAdUnitId.isNotEmpty, isTrue);
      expect(AdService.nativeAdUnitId.isNotEmpty, isTrue);
      expect(AdService.defaultCooldownSeconds, 60);
    });
  });
}
