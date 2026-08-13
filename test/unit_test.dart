import 'package:flutter_test/flutter_test.dart';
import 'package:kisan_mitra/models/crop.dart';
import 'package:kisan_mitra/models/fertilizer.dart';
import 'package:kisan_mitra/models/scheme.dart';
import 'package:kisan_mitra/models/helpline.dart';
import 'package:kisan_mitra/models/mandi_rate.dart';
import 'package:kisan_mitra/models/notification_item.dart';

void main() {
  group('Model Tests', () {
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

    test('Fertilizer model parses correctly', () {
      final json = {
        'id': 'urea',
        'name': 'यूरिया',
        'nameEn': 'Urea',
        'nutrient': 'N - 46%',
        'usage': 'बढ़वार के लिए',
        'dosagePerHectare': '100 किलो',
        'dosagePerBigha': '12 किलो',
        'method': 'छिड़काव',
        'precaution': 'सावधानी रखें',
        'price': '₹266.50',
        'crops': ['wheat', 'rice']
      };

      final fertilizer = Fertilizer.fromJson(json);
      expect(fertilizer.id, 'urea');
      expect(fertilizer.crops.contains('wheat'), isTrue);
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

    test('MandiRate model parses correctly', () {
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
        'arrival_date': '12/08/2026'
      };

      final rate = MandiRate.fromJson(json);
      expect(rate.commodity, 'Wheat');
      expect(rate.minPrice, 2200.0);
      expect(rate.maxPrice, 2500.0);
      expect(rate.modalPrice, 2350.0);
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
  });
}
