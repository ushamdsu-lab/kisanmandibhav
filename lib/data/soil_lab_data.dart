import '../utils/district_helper.dart';

class DistrictSoilLab {
  final String districtEng;
  final String districtHindi;
  final String labName;
  final String labAddress;
  final String inchargeOfficer;
  final String contactPhone;
  final String testingFee;

  const DistrictSoilLab({
    required this.districtEng,
    required this.districtHindi,
    required this.labName,
    required this.labAddress,
    required this.inchargeOfficer,
    required this.contactPhone,
    required this.testingFee,
  });
}

class SoilLabDatabase {
  static const Map<String, DistrictSoilLab> districtLabMap = {
    'Bikaner': DistrictSoilLab(
      districtEng: 'Bikaner',
      districtHindi: 'बीकानेर',
      labName: 'स्वामी केशवानंद राजस्थान कृषि विश्वविद्यालय (SKRAU) मृदा परीक्षण प्रयोगशाला',
      labAddress: 'कृषि कॉलेज परिसर, बीकानेर - 334006',
      inchargeOfficer: 'डॉ. पी. के. यादव (वरिष्ठ मृदा वैज्ञानिक)',
      contactPhone: '0151-2250558 / 1800-180-1100',
      testingFee: 'निःशुल्क (मृदा स्वास्थ्य कार्ड योजना)',
    ),
    'Nagaur': DistrictSoilLab(
      districtEng: 'Nagaur',
      districtHindi: 'नागौर',
      labName: 'कृषि विज्ञान केंद्र (KVK) एवं राजकीय मृदा जांच प्रयोगशाला',
      labAddress: 'मेड़ता रोड, नागौर - 341511',
      inchargeOfficer: 'डॉ. महेश चौधरी (इनचार्ज वैज्ञानिक)',
      contactPhone: '01588-220144 / 1800-180-1100',
      testingFee: 'निःशुल्क (Soil Health Card Scheme)',
    ),
    'Jaipur': DistrictSoilLab(
      districtEng: 'Jaipur',
      districtHindi: 'जयपुर',
      labName: 'राज्य कृषि अनुसंधान संस्थान (RARI) मृदा परीक्षण प्रयोगशाला',
      labAddress: 'दुर्गापुरा, जयपुर - 302018',
      inchargeOfficer: 'डॉ. आर. एस. शर्मा (प्रधान वैज्ञानिक)',
      contactPhone: '0141-2550229 / 1800-180-1100',
      testingFee: 'निःशुल्क (सरकार द्वारा प्रायोजित)',
    ),
    'Jodhpur': DistrictSoilLab(
      districtEng: 'Jodhpur',
      districtHindi: 'जोधपुर',
      labName: 'केन्द्रीय शुष्क क्षेत्र अनुसंधान संस्थान (CAZRI) मृदा लैब',
      labAddress: 'आईटीआई रोड, मण्डोर रोड, जोधपुर - 342003',
      inchargeOfficer: 'डॉ. एन. के. सिंह (वैज्ञानिक)',
      contactPhone: '0291-2786584 / 1800-180-1100',
      testingFee: 'निःशुल्क (Soil Health Card)',
    ),
    'Kota': DistrictSoilLab(
      districtEng: 'Kota',
      districtHindi: 'कोटा',
      labName: 'कृषि विश्वविद्यालय कोटा (AU Kota) मृदा एवं जल जांच प्रयोगशाला',
      labAddress: 'बोरखेड़ा, कोटा - 324001',
      inchargeOfficer: 'डॉ. वी. के. मेहरा (विभागाध्यक्ष)',
      contactPhone: '0744-2321204 / 1800-180-1100',
      testingFee: 'निःशुल्क (सरकारी कार्ड धारक)',
    ),
    'Hanumangarh': DistrictSoilLab(
      districtEng: 'Hanumangarh',
      districtHindi: 'हनुमानगढ़',
      labName: 'राजकीय मृदा परीक्षण प्रयोगशाला एवं KVK सेंटर',
      labAddress: 'टाउन रोड, जंक्शन मंडी, हनुमानगढ़ - 335512',
      inchargeOfficer: 'इंजी. बी. एल. बिश्नोई',
      contactPhone: '01552-260334 / 1800-180-1100',
      testingFee: 'निःशुल्क (मृदा स्वास्थ्य कार्ड)',
    ),
    'Ganganagar': DistrictSoilLab(
      districtEng: 'Ganganagar',
      districtHindi: 'श्रीगंगानगर',
      labName: 'कृषि अनुसंधान उपकेंद्र एवं शासकीय मृदा विश्लेषण केंद्र',
      labAddress: 'पदमपुर रोड, श्रीगंगानगर - 335001',
      inchargeOfficer: 'डॉ. ओ. पी. गिल (वरिष्ठ वैज्ञानिक)',
      contactPhone: '0154-2470211 / 1800-180-1100',
      testingFee: 'निःशुल्क (Govt Scheme)',
    ),
    'Indore': DistrictSoilLab(
      districtEng: 'Indore',
      districtHindi: 'इंदौर',
      labName: 'राजमाता विजयाराजे सिंधिया कृषि विश्वविद्यालय KVK मृदा लैब',
      labAddress: 'कृषि कॉलेज परिसर, इंदौर - 452001',
      inchargeOfficer: 'डॉ. एस. के. शर्मा (प्रधान वैज्ञानिक)',
      contactPhone: '0731-2702121 / 1800-180-1100',
      testingFee: 'निःशुल्क (स्वास्थ कार्ड योजना)',
    ),
    'Neemuch': DistrictSoilLab(
      districtEng: 'Neemuch',
      districtHindi: 'नीमच',
      labName: 'जिला कृषि कार्यालय शासकीय मृदा परीक्षण प्रयोगशाला',
      labAddress: 'मंडी प्रांगण के पास, नीमच - 458441',
      inchargeOfficer: 'श्री जी. एस. धाकड़ (कृषि अधिकारी)',
      contactPhone: '07423-220455 / 1800-180-1100',
      testingFee: 'निःशुल्क (Govt Scheme)',
    ),
  };

  static DistrictSoilLab getLabForDistrict(String districtName) {
    final hindiName = DistrictHelper.getHindiName(districtName);

    for (final entry in districtLabMap.entries) {
      if (entry.key.toLowerCase() == districtName.toLowerCase() ||
          entry.value.districtHindi == hindiName ||
          entry.value.districtHindi == districtName ||
          districtName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Dynamic fallback for any district in India
    return DistrictSoilLab(
      districtEng: districtName,
      districtHindi: hindiName,
      labName: 'कृषि विज्ञान केंद्र (KVK) एवं राजकीय मृदा परीक्षण प्रयोगशाला, $hindiName',
      labAddress: 'जिला कृषि अधिकारी कार्यालय परिसर, $hindiName',
      inchargeOfficer: 'वरिष्ठ मृदा वैज्ञानिक (KVK $hindiName)',
      contactPhone: '1800-180-1100 (टोल फ्री) / 0141-2550229',
      testingFee: 'निःशुल्क (मृदा स्वास्थ्य कार्ड योजना)',
    );
  }
}
