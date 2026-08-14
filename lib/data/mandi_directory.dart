import '../utils/district_helper.dart';

class MandiDirectory {
  // Complete APMC Mandis directory for All India

  static const Map<String, List<String>> rajasthanMandis = {
    'Ajmer': ['Ajmer APMC', 'Beawar APMC', 'Kekri APMC', 'Bijainagar APMC', 'Kishangarh APMC'],
    'Alwar': ['Alwar APMC', 'Khairthal APMC', 'Kherli APMC', 'Ramgarh APMC', 'Tijara APMC'],
    'Banswara': ['Banswara APMC', 'Garhi APMC', 'Kushalgarh APMC'],
    'Baran': ['Baran APMC', 'Antah APMC', 'Chhabra APMC', 'Atru APMC', 'Chhipabarod APMC'],
    'Barmer': ['Barmer APMC', 'Balotra APMC', 'Chohtan APMC', 'Baytu APMC'],
    'Bharatpur': ['Bharatpur APMC', 'Bayana APMC', 'Bhusawar Bair APMC', 'Deeg APMC', 'Kaman APMC', 'Nadbai APMC', 'Nagar APMC', 'Weir APMC'],
    'Bhilwara': ['Bhilwara APMC', 'Gulabpura APMC', 'Mandalgarh APMC', 'Shahpura APMC'],
    'Bikaner': ['Bikaner (Grain) APMC', 'Bikaner (F&V) APMC', 'Nokha APMC', 'Lunkaransar APMC', 'Khajuwala APMC', 'Sridungargarh APMC'],
    'Bundi': ['Bundi APMC', 'Dei APMC', 'Keshoraipatan APMC', 'Kapren APMC', 'Hindoli APMC'],
    'Chittorgarh': ['Chittorgarh APMC', 'Nimbahera APMC', 'Begun APMC', 'Kapasan APMC', 'Bari Sadri APMC'],
    'Churu': ['Churu APMC', 'Sadulpur APMC', 'Sujangarh APMC', 'Ratangarh APMC', 'Sardarshahar APMC', 'Taranagar APMC'],
    'Dausa': ['Dausa APMC', 'Bandikui APMC', 'Lalsot APMC', 'Mahwa APMC', 'Mandawar APMC'],
    'Dholpur': ['Dholpur APMC', 'Bari APMC', 'Rajakhera APMC', 'Baseri APMC'],
    'Dungarpur': ['Dungarpur APMC', 'Sagwara APMC', 'Aspur APMC'],
    'Ganganagar': ['Sriganganagar (Grain) APMC', 'Sriganganagar (F&V) APMC', 'Gajsinghpur APMC', 'Gharsana APMC', 'Suratgarh APMC', 'Anupgarh APMC', 'Padampur APMC', 'Raisinghnagar APMC', 'Sadulshahar APMC', 'Rawla APMC'],
    'Hanumangarh': ['Hanumangarh Town APMC', 'Hanumangarh Junction APMC', 'Nohar APMC', 'Pilibanga APMC', 'Bhadra APMC', 'Rawatsar APMC', 'Sangaria APMC'],
    'Jaipur': ['Jaipur (Grain) APMC', 'Jaipur (F&V) APMC', 'Bassi APMC', 'Chaksu APMC', 'Chomu APMC', 'Kotputli APMC', 'Sambhar Lake APMC', 'Shahpura APMC'],
    'Jaisalmer': ['Jaisalmer APMC', 'Pokaran APMC', 'Mohangarh APMC'],
    'Jalore': ['Jalore APMC', 'Bhinmal APMC', 'Raniwara APMC', 'Sanchore APMC', 'Ahore APMC'],
    'Jhalawar': ['Jhalawar APMC', 'Bhawani Mandi APMC', 'Jhalrapatan APMC', 'Aklera APMC', 'Khanpur APMC', 'Pirawa APMC'],
    'Jhunjhunu': ['Jhunjhunu APMC', 'Nawalgarh APMC', 'Chirawa APMC', 'Khetri APMC', 'Surajgarh APMC', 'Udaipurwati APMC'],
    'Jodhpur': ['Jodhpur (Grain) APMC', 'Jodhpur (F&V) APMC', 'Mathania APMC', 'Bilara APMC', 'Phalodi APMC', 'Pipar City APMC', 'Bhopalgarh APMC', 'Osian APMC', 'Balesar APMC', 'Luni APMC'],
    'Karauli': ['Karauli APMC', 'Hindaun City APMC', 'Todabhim APMC'],
    'Kota': ['Kota APMC', 'Ramganjmandi APMC', 'Sangod APMC', 'Itawa APMC', 'Sultanpur APMC'],
    'Nagaur': ['Nagaur APMC', 'Merta City APMC', 'Didwana APMC', 'Kuchaman City APMC', 'Ladnun APMC', 'Makrana APMC', 'Degana APMC', 'Parbatsar APMC', 'Jayal APMC'],
    'Pali': ['Pali APMC', 'Jaitaran APMC', 'Sojat Road APMC', 'Sumerpur APMC', 'Falna APMC', 'Bali APMC', 'Rani APMC'],
    'Pratapgarh': ['Pratapgarh APMC', 'Chhoti Sadri APMC', 'Dhariawad APMC'],
    'Rajsamand': ['Rajsamand APMC', 'Nathdwara APMC', 'Amet APMC', 'Devgarh APMC', 'Kumbhalgarh APMC'],
    'Sawai Madhopur': ['Sawai Madhopur APMC', 'Gangapur City APMC', 'Bamanwas APMC'],
    'Sikar': ['Sikar APMC', 'Fatehpur APMC', 'Neem Ka Thana APMC', 'Laxmangarh APMC', 'Sri Madhopur APMC', 'Danta Ramgarh APMC', 'Reengus APMC'],
    'Sirohi': ['Sirohi APMC', 'Abu Road APMC', 'Pindwara APMC', 'Sheoganj APMC'],
    'Tonk': ['Tonk APMC', 'Malpura APMC', 'Niwai APMC', 'Deoli APMC', 'Uniara APMC', 'Todaraisingh APMC'],
    'Udaipur': ['Udaipur (Grain) APMC', 'Udaipur (F&V) APMC', 'Salumber APMC', 'Fatehnagar APMC', 'Kherwara APMC', 'Mavli APMC', 'Bhinder APMC'],
  };

  static const Map<String, List<String>> mpMandis = {
    'Indore': ['Indore (Grain) APMC', 'Indore (F&V) APMC', 'Sanwer APMC', 'Depalpur APMC', 'Mhow APMC'],
    'Ujjain': ['Ujjain APMC', 'Nagda APMC', 'Mahidpur APMC', 'Khachrod APMC', 'Tarana APMC'],
    'Neemuch': ['Neemuch APMC', 'Manasa APMC', 'Jawad APMC'],
    'Mandsaur': ['Mandsaur APMC', 'Pipliya Mandi APMC', 'Garoth APMC', 'Shamgarh APMC', 'Suwasra APMC'],
    'Ratlam': ['Ratlam APMC', 'Jaora APMC', 'Sailana APMC'],
    'Dewas': ['Dewas APMC', 'Sonkatch APMC', 'Khategaon APMC'],
    'Dhar': ['Dhar APMC', 'Badnawar APMC', 'Dhamnod APMC', 'Manawar APMC'],
    'Khargone': ['Khargone APMC', 'Sanawad APMC', 'Barwaha APMC'],
    'Khandwa': ['Khandwa APMC', 'Pandhana APMC'],
    'Sehore': ['Sehore APMC', 'Ashta APMC', 'Ichhawar APMC'],
    'Bhopal': ['Bhopal (Karond) APMC', 'Berasia APMC'],
    'Raisen': ['Raisen APMC', 'Begamganj APMC', 'Silwani APMC'],
    'Vidisha': ['Vidisha APMC', 'Basoda APMC', 'Sironj APMC'],
    'Rajgarh': ['Rajgarh APMC', 'Biaora APMC', 'Narsinghgarh APMC', 'Sarangpur APMC'],
    'Shajapur': ['Shajapur APMC', 'Shujalpur APMC'],
    'Gwalior': ['Gwalior (Lashkar) APMC', 'Dabra APMC'],
    'Morena': ['Morena APMC', 'Ambah APMC', 'Porsa APMC'],
    'Bhind': ['Bhind APMC', 'Lahar APMC', 'Mehgaon APMC'],
    'Shivpuri': ['Shivpuri APMC', 'Karera APMC', 'Kolaras APMC'],
    'Guna': ['Guna APMC', 'Raghogarh APMC', 'Aron APMC'],
    'Sagar': ['Sagar APMC', 'Bina APMC', 'Khurai APMC'],
    'Damoh': ['Damoh APMC', 'Hatta APMC'],
    'Jabalpur': ['Jabalpur APMC', 'Sihora APMC', 'Patan APMC'],
    'Chhindwara': ['Chhindwara APMC', 'Sausar APMC', 'Pandhurna APMC'],
    'Hoshangabad': ['Hoshangabad APMC', 'Itarsi APMC', 'Pipariya APMC'],
    'Harda': ['Harda APMC', 'Timarni APMC'],
    'Betul': ['Betul APMC', 'Multai APMC'],
    'Narsinghpur': ['Narsinghpur APMC', 'Gadarwara APMC', 'Kareli APMC'],
    'Rewa': ['Rewa APMC', 'Hanumana APMC'],
    'Satna': ['Satna APMC', 'Maihar APMC', 'Nagod APMC'],
  };

  static const Map<String, List<String>> gujaratMandis = {
    'Rajkot': ['Rajkot APMC', 'Gondal APMC', 'Jetpur APMC', 'Dhoraji APMC', 'Upleta APMC', 'Jasdan APMC'],
    'Ahmedabad': ['Ahmedabad (Jamalpur) APMC', 'Sanand APMC', 'Dholka APMC', 'Viramgam APMC'],
    'Surat': ['Surat APMC', 'Bardoli APMC', 'Mahuva APMC'],
    'Amreli': ['Amreli APMC', 'Savarkundla APMC', 'Bagasara APMC', 'Rajula APMC'],
    'Bhavnagar': ['Bhavnagar APMC', 'Mahuva APMC', 'Talaja APMC', 'Palitana APMC', 'Botad APMC'],
    'Junagadh': ['Junagadh APMC', 'Keshod APMC', 'Visavadar APMC', 'Mangrol APMC'],
    'Jamnagar': ['Jamnagar APMC', 'Dhrol APMC', 'Kalavad APMC'],
    'Mehsana': ['Mehsana APMC', 'Unjha APMC', 'Kadi APMC', 'Visnagar APMC', 'Vijapur APMC'],
    'Banaskantha': ['Palanpur APMC', 'Deesa APMC', 'Tharad APMC', 'Dhanera APMC'],
    'Patan': ['Patan APMC', 'Siddhpur APMC', 'Radhanpur APMC'],
    'Sabarkantha': ['Himatnagar APMC', 'Idar APMC', 'Khedbrahma APMC'],
    'Morbi': ['Morbi APMC', 'Halvad APMC'],
    'Surendranagar': ['Surendranagar APMC', 'Wadhwan APMC', 'Dhrangadhra APMC', 'Limbdi APMC'],
    'Kutch': ['Bhuj APMC', 'Anjar APMC', 'Gandhidham APMC'],
    'Vadodara': ['Vadodara (Sayajigunj) APMC', 'Padra APMC', 'Dabhoi APMC'],
    'Bharuch': ['Bharuch APMC', 'Ankleshwar APMC', 'Jambusar APMC'],
    'Anand': ['Anand APMC', 'Petlad APMC', 'Khambhat APMC', 'Borsad APMC'],
    'Kheda': ['Nadiad APMC', 'Kapadvanj APMC', 'Mehmedabad APMC'],
  };

  // --- Punjab ---
  static const Map<String, List<String>> punjabMandis = {
    'Amritsar': ['Amritsar APMC', 'Tarn Taran APMC', 'Ajnala APMC'],
    'Ludhiana': ['Ludhiana (Grain) APMC', 'Khanna APMC', 'Jagraon APMC', 'Samrala APMC'],
    'Jalandhar': ['Jalandhar APMC', 'Nakodar APMC', 'Phillaur APMC', 'Shahkot APMC'],
    'Patiala': ['Patiala APMC', 'Nabha APMC', 'Rajpura APMC', 'Samana APMC'],
    'Bathinda': ['Bathinda APMC', 'Rampura Phul APMC', 'Talwandi Sabo APMC'],
    'Sangrur': ['Sangrur APMC', 'Malerkotla APMC', 'Sunam APMC', 'Dhuri APMC'],
    'Moga': ['Moga APMC', 'Nihal Singh Wala APMC', 'Baghapurana APMC'],
    'Ferozepur': ['Ferozepur APMC', 'Fazilka APMC', 'Zira APMC', 'Abohar APMC'],
    'Muktsar': ['Muktsar APMC', 'Malout APMC', 'Gidderbaha APMC'],
    'Mansa': ['Mansa APMC', 'Budhlada APMC', 'Sardulgarh APMC'],
    'Barnala': ['Barnala APMC', 'Tapa APMC'],
    'Kapurthala': ['Kapurthala APMC', 'Sultanpur Lodhi APMC', 'Phagwara APMC'],
    'Hoshiarpur': ['Hoshiarpur APMC', 'Garhshankar APMC', 'Dasuya APMC'],
    'Gurdaspur': ['Gurdaspur APMC', 'Batala APMC', 'Pathankot APMC'],
  };

  // --- Haryana ---
  static const Map<String, List<String>> haryanaMandis = {
    'Hisar': ['Hisar APMC', 'Hansi APMC', 'Barwala APMC', 'Uklana APMC'],
    'Sirsa': ['Sirsa APMC', 'Dabwali APMC', 'Ellenabad APMC', 'Rania APMC'],
    'Karnal': ['Karnal APMC', 'Indri APMC', 'Gharaunda APMC', 'Assandh APMC'],
    'Rohtak': ['Rohtak APMC', 'Meham APMC', 'Kalanaur APMC'],
    'Sonipat': ['Sonipat APMC', 'Ganaur APMC', 'Gohana APMC', 'Kharkhoda APMC'],
    'Panipat': ['Panipat APMC', 'Samalkha APMC', 'Israna APMC'],
    'Jind': ['Jind APMC', 'Narwana APMC', 'Safidon APMC', 'Julana APMC'],
    'Fatehabad': ['Fatehabad APMC', 'Tohana APMC', 'Ratia APMC'],
    'Bhiwani': ['Bhiwani APMC', 'Charkhi Dadri APMC', 'Siwani APMC', 'Loharu APMC'],
    'Ambala': ['Ambala APMC', 'Barara APMC', 'Shahabad APMC'],
    'Kurukshetra': ['Kurukshetra APMC', 'Shahabad APMC', 'Ladwa APMC', 'Pehowa APMC'],
    'Kaithal': ['Kaithal APMC', 'Cheeka APMC', 'Pundri APMC', 'Kalayat APMC'],
    'Mahendragarh': ['Narnaul APMC', 'Mahendragarh APMC', 'Ateli APMC'],
    'Rewari': ['Rewari APMC', 'Bawal APMC', 'Kosli APMC'],
    'Yamunanagar': ['Yamunanagar APMC', 'Jagadhri APMC', 'Radaur APMC'],
  };

  // --- Uttar Pradesh ---
  static const Map<String, List<String>> upMandis = {
    'Lucknow': ['Lucknow APMC', 'Malihabad APMC'],
    'Agra': ['Agra APMC', 'Firozabad APMC', 'Fatehpur Sikri APMC'],
    'Kanpur': ['Kanpur (Grain) APMC', 'Kanpur Dehat APMC'],
    'Varanasi': ['Varanasi APMC', 'Chandauli APMC'],
    'Allahabad': ['Prayagraj APMC', 'Naini APMC'],
    'Meerut': ['Meerut APMC', 'Hapur APMC', 'Ghaziabad APMC'],
    'Mathura': ['Mathura APMC', 'Vrindavan APMC', 'Chhata APMC'],
    'Bareilly': ['Bareilly APMC', 'Pilibhit APMC', 'Shahjahanpur APMC'],
    'Gorakhpur': ['Gorakhpur APMC', 'Deoria APMC', 'Basti APMC'],
    'Jhansi': ['Jhansi APMC', 'Lalitpur APMC', 'Banda APMC'],
    'Aligarh': ['Aligarh APMC', 'Hathras APMC', 'Kasganj APMC'],
    'Moradabad': ['Moradabad APMC', 'Rampur APMC', 'Sambhal APMC'],
    'Azamgarh': ['Azamgarh APMC', 'Mau APMC', 'Ballia APMC'],
    'Sultanpur': ['Sultanpur APMC', 'Faizabad APMC', 'Amethi APMC'],
    'Saharanpur': ['Saharanpur APMC', 'Muzaffarnagar APMC', 'Shamli APMC'],
    'Bulandshahr': ['Bulandshahr APMC', 'Khurja APMC', 'Sikandrabad APMC'],
    'Etawah': ['Etawah APMC', 'Mainpuri APMC', 'Auraiya APMC'],
    'Hardoi': ['Hardoi APMC', 'Sitapur APMC', 'Lakhimpur Kheri APMC'],
  };

  // --- Maharashtra ---
  static const Map<String, List<String>> maharashtraMandis = {
    'Mumbai': ['Vashi APMC', 'Mumbai (Crawford) APMC'],
    'Pune': ['Pune (Market Yard) APMC', 'Pimpri APMC', 'Baramati APMC'],
    'Nashik': ['Nashik APMC', 'Lasalgaon APMC', 'Manmad APMC', 'Malegaon APMC'],
    'Nagpur': ['Nagpur APMC', 'Kamptee APMC', 'Katol APMC'],
    'Solapur': ['Solapur APMC', 'Pandharpur APMC', 'Barshi APMC'],
    'Kolhapur': ['Kolhapur APMC', 'Sangli APMC', 'Miraj APMC', 'Satara APMC'],
    'Aurangabad': ['Aurangabad APMC', 'Jalna APMC', 'Parbhani APMC'],
    'Ahmednagar': ['Ahmednagar APMC', 'Shrirampur APMC', 'Rahuri APMC'],
    'Latur': ['Latur APMC', 'Osmanabad APMC', 'Nanded APMC'],
    'Akola': ['Akola APMC', 'Washim APMC', 'Buldhana APMC'],
    'Amravati': ['Amravati APMC', 'Yavatmal APMC', 'Wardha APMC'],
    'Jalgaon': ['Jalgaon APMC', 'Bhusawal APMC', 'Dhule APMC'],
    'Beed': ['Beed APMC', 'Gevrai APMC', 'Ambajogai APMC'],
    'Nandurbar': ['Nandurbar APMC', 'Shahada APMC'],
  };

  // --- Karnataka ---
  static const Map<String, List<String>> karnatakaMandis = {
    'Bengaluru': ['Bengaluru (Yeshwanthpur) APMC', 'Bengaluru (KR Market) APMC'],
    'Mysuru': ['Mysuru APMC', 'Nanjangud APMC'],
    'Hubli-Dharwad': ['Hubli APMC', 'Dharwad APMC'],
    'Belgaum': ['Belgaum APMC', 'Gokak APMC', 'Chikodi APMC'],
    'Davangere': ['Davangere APMC', 'Harihar APMC'],
    'Shimoga': ['Shimoga APMC', 'Bhadravati APMC'],
    'Bellary': ['Bellary APMC', 'Hospet APMC'],
    'Gulbarga': ['Gulbarga APMC', 'Sedam APMC', 'Yadgir APMC'],
    'Raichur': ['Raichur APMC', 'Manvi APMC', 'Sindhanur APMC'],
    'Bijapur': ['Bijapur APMC', 'Muddebihal APMC'],
    'Tumkur': ['Tumkur APMC', 'Tiptur APMC', 'Sira APMC'],
    'Hassan': ['Hassan APMC', 'Arsikere APMC'],
    'Mandya': ['Mandya APMC', 'Pandavapura APMC'],
    'Chitradurga': ['Chitradurga APMC', 'Challakere APMC'],
  };

  // --- Tamil Nadu ---
  static const Map<String, List<String>> tnMandis = {
    'Chennai': ['Chennai (Koyambedu) APMC'],
    'Coimbatore': ['Coimbatore APMC', 'Pollachi APMC', 'Tirupur APMC'],
    'Madurai': ['Madurai APMC', 'Virudhunagar APMC'],
    'Salem': ['Salem APMC', 'Namakkal APMC', 'Attur APMC'],
    'Erode': ['Erode APMC', 'Gobichettipalayam APMC'],
    'Thanjavur': ['Thanjavur APMC', 'Kumbakonam APMC'],
    'Trichy': ['Trichy APMC', 'Musiri APMC'],
    'Dindigul': ['Dindigul APMC', 'Oddanchatram APMC'],
    'Tirunelveli': ['Tirunelveli APMC', 'Tenkasi APMC'],
    'Vellore': ['Vellore APMC', 'Vaniyambadi APMC'],
  };

  // --- Andhra Pradesh ---
  static const Map<String, List<String>> apMandis = {
    'Guntur': ['Guntur APMC', 'Chilakaluripet APMC', 'Tenali APMC', 'Narasaraopet APMC'],
    'Kurnool': ['Kurnool APMC', 'Adoni APMC', 'Nandyal APMC'],
    'Anantapur': ['Anantapur APMC', 'Hindupur APMC', 'Dharmavaram APMC'],
    'Visakhapatnam': ['Visakhapatnam APMC', 'Anakapalle APMC'],
    'Krishna': ['Vijayawada APMC', 'Machilipatnam APMC', 'Gudivada APMC'],
    'East Godavari': ['Kakinada APMC', 'Rajahmundry APMC', 'Amalapuram APMC'],
    'West Godavari': ['Eluru APMC', 'Bhimavaram APMC', 'Tadepalligudem APMC'],
    'Prakasam': ['Ongole APMC', 'Markapur APMC'],
    'Chittoor': ['Chittoor APMC', 'Tirupati APMC', 'Madanapalle APMC'],
    'Kadapa': ['Kadapa APMC', 'Proddatur APMC', 'Rajampet APMC'],
  };

  // --- Telangana ---
  static const Map<String, List<String>> telanganaMandis = {
    'Hyderabad': ['Hyderabad (Bowenpally) APMC', 'Hyderabad (Gudimalkapur) APMC'],
    'Warangal': ['Warangal APMC', 'Jangaon APMC'],
    'Karimnagar': ['Karimnagar APMC', 'Jagtial APMC', 'Peddapalli APMC'],
    'Nizamabad': ['Nizamabad APMC', 'Bodhan APMC', 'Kamareddy APMC'],
    'Nalgonda': ['Nalgonda APMC', 'Suryapet APMC', 'Miryalaguda APMC'],
    'Khammam': ['Khammam APMC', 'Kothagudem APMC'],
    'Mahbubnagar': ['Mahbubnagar APMC', 'Nagarkurnool APMC', 'Wanaparthy APMC'],
    'Adilabad': ['Adilabad APMC', 'Nirmal APMC', 'Mancherial APMC'],
    'Medak': ['Sangareddy APMC', 'Siddipet APMC'],
  };

  // --- Bihar ---
  static const Map<String, List<String>> biharMandis = {
    'Patna': ['Patna APMC', 'Danapur APMC'],
    'Muzaffarpur': ['Muzaffarpur APMC', 'Hajipur APMC', 'Sitamarhi APMC'],
    'Gaya': ['Gaya APMC', 'Nawada APMC', 'Aurangabad APMC'],
    'Bhagalpur': ['Bhagalpur APMC', 'Banka APMC'],
    'Darbhanga': ['Darbhanga APMC', 'Madhubani APMC', 'Samastipur APMC'],
    'Purnia': ['Purnia APMC', 'Katihar APMC', 'Araria APMC'],
    'Chapra': ['Chapra APMC', 'Siwan APMC', 'Gopalganj APMC'],
    'Begusarai': ['Begusarai APMC', 'Khagaria APMC'],
    'Nalanda': ['Bihar Sharif APMC', 'Rajgir APMC'],
    'Rohtas': ['Sasaram APMC', 'Buxar APMC', 'Bhabua APMC'],
  };

  // --- West Bengal ---
  static const Map<String, List<String>> wbMandis = {
    'Kolkata': ['Kolkata (Koley Market) APMC', 'Kolkata (Posta) APMC'],
    'Bardhaman': ['Bardhaman APMC', 'Durgapur APMC', 'Asansol APMC'],
    'Murshidabad': ['Berhampore APMC', 'Jangipur APMC'],
    'Nadia': ['Krishnanagar APMC', 'Ranaghat APMC'],
    'Hooghly': ['Chandannagar APMC', 'Chinsurah APMC'],
    'Midnapore': ['Midnapore APMC', 'Kharagpur APMC', 'Tamluk APMC'],
    'Malda': ['Malda APMC', 'English Bazaar APMC'],
    'Siliguri': ['Siliguri APMC'],
    'Bankura': ['Bankura APMC', 'Bishnupur APMC'],
  };

  // --- Odisha ---
  static const Map<String, List<String>> odishaMandis = {
    'Bhubaneswar': ['Bhubaneswar APMC', 'Cuttack APMC'],
    'Sambalpur': ['Sambalpur APMC', 'Bargarh APMC'],
    'Balasore': ['Balasore APMC', 'Bhadrak APMC'],
    'Berhampur': ['Berhampur APMC', 'Aska APMC'],
    'Bolangir': ['Bolangir APMC', 'Titilagarh APMC'],
    'Koraput': ['Koraput APMC', 'Jeypore APMC'],
    'Rourkela': ['Rourkela APMC', 'Sundargarh APMC'],
  };

  // --- Chhattisgarh ---
  static const Map<String, List<String>> cgMandis = {
    'Raipur': ['Raipur APMC', 'Dhamtari APMC', 'Mahasamund APMC'],
    'Bilaspur': ['Bilaspur APMC', 'Janjgir APMC', 'Mungeli APMC'],
    'Durg': ['Durg APMC', 'Bhilai APMC', 'Rajnandgaon APMC'],
    'Jagdalpur': ['Jagdalpur APMC', 'Kanker APMC'],
    'Korba': ['Korba APMC', 'Champa APMC'],
    'Ambikapur': ['Ambikapur APMC'],
  };

  // --- Jharkhand ---
  static const Map<String, List<String>> jharkhandMandis = {
    'Ranchi': ['Ranchi APMC', 'Khunti APMC'],
    'Dhanbad': ['Dhanbad APMC', 'Bokaro APMC'],
    'Jamshedpur': ['Jamshedpur APMC', 'Seraikela APMC'],
    'Hazaribagh': ['Hazaribagh APMC', 'Ramgarh APMC'],
    'Dumka': ['Dumka APMC', 'Deoghar APMC'],
  };

  // --- Uttarakhand ---
  static const Map<String, List<String>> uttarakhandMandis = {
    'Dehradun': ['Dehradun APMC', 'Rishikesh APMC'],
    'Haridwar': ['Haridwar APMC', 'Roorkee APMC', 'Laksar APMC'],
    'Udham Singh Nagar': ['Rudrapur APMC', 'Kashipur APMC', 'Haldwani APMC'],
    'Nainital': ['Nainital APMC', 'Ramnagar APMC'],
  };

  // --- Himachal Pradesh ---
  static const Map<String, List<String>> hpMandis = {
    'Shimla': ['Shimla APMC', 'Theog APMC'],
    'Kangra': ['Kangra APMC', 'Palampur APMC', 'Dharamsala APMC'],
    'Mandi': ['Mandi APMC', 'Sundernagar APMC'],
    'Solan': ['Solan APMC', 'Parwanoo APMC', 'Nalagarh APMC'],
    'Kullu': ['Kullu APMC', 'Manali APMC'],
    'Una': ['Una APMC', 'Amb APMC'],
  };

  // --- Assam ---
  static const Map<String, List<String>> assamMandis = {
    'Guwahati': ['Guwahati (Fancy Bazaar) APMC', 'Guwahati (Beltola) APMC'],
    'Nagaon': ['Nagaon APMC', 'Hojai APMC'],
    'Dibrugarh': ['Dibrugarh APMC', 'Tinsukia APMC'],
    'Silchar': ['Silchar APMC'],
    'Jorhat': ['Jorhat APMC', 'Golaghat APMC'],
    'Tezpur': ['Tezpur APMC'],
  };

  // --- Kerala ---
  static const Map<String, List<String>> keralaMandis = {
    'Ernakulam': ['Kochi APMC', 'Perumbavoor APMC'],
    'Thrissur': ['Thrissur APMC', 'Kunnamkulam APMC'],
    'Palakkad': ['Palakkad APMC', 'Ottapalam APMC'],
    'Kozhikode': ['Kozhikode APMC'],
    'Thiruvananthapuram': ['Thiruvananthapuram APMC'],
    'Wayanad': ['Kalpetta APMC'],
  };

  /// Master list of all states
  static const List<String> allStates = [
    'Rajasthan', 'Madhya Pradesh', 'Gujarat',
    'Punjab', 'Haryana', 'Uttar Pradesh',
    'Maharashtra', 'Karnataka', 'Tamil Nadu',
    'Andhra Pradesh', 'Telangana',
    'Bihar', 'West Bengal', 'Odisha',
    'Chhattisgarh', 'Jharkhand',
    'Uttarakhand', 'Himachal Pradesh',
    'Assam', 'Kerala',
  ];

  /// Returns the mandi map for a given state
  static Map<String, List<String>> _getMandiMap(String state) {
    final s = state.toLowerCase();
    if (s.contains('rajasthan')) return rajasthanMandis;
    if (s.contains('madhya')) return mpMandis;
    if (s.contains('gujarat')) return gujaratMandis;
    if (s.contains('punjab')) return punjabMandis;
    if (s.contains('haryana')) return haryanaMandis;
    if (s.contains('uttar pradesh') || s.contains('up')) return upMandis;
    if (s.contains('maharashtra')) return maharashtraMandis;
    if (s.contains('karnataka')) return karnatakaMandis;
    if (s.contains('tamil')) return tnMandis;
    if (s.contains('andhra')) return apMandis;
    if (s.contains('telangana')) return telanganaMandis;
    if (s.contains('bihar')) return biharMandis;
    if (s.contains('west bengal') || s.contains('bengal')) return wbMandis;
    if (s.contains('odisha') || s.contains('orissa')) return odishaMandis;
    if (s.contains('chhattisgarh') || s.contains('chattisgarh')) return cgMandis;
    if (s.contains('jharkhand')) return jharkhandMandis;
    if (s.contains('uttarakhand')) return uttarakhandMandis;
    if (s.contains('himachal')) return hpMandis;
    if (s.contains('assam')) return assamMandis;
    if (s.contains('kerala')) return keralaMandis;
    return rajasthanMandis; // Default fallback to Rajasthan mandis
  }

  /// Comprehensive sub-district / tehsil / town / mandi to standard district mapping
  static const Map<String, String> _subDistrictToDistrict = {
    // --- Rajasthan (Jodhpur) ---
    'mathania': 'Jodhpur',
    'mataniya': 'Jodhpur',
    'मथानिया': 'Jodhpur',
    'mathania mandi': 'Jodhpur',
    'osian': 'Jodhpur',
    'ओसियां': 'Jodhpur',
    'mandore': 'Jodhpur',
    'मंडोर': 'Jodhpur',
    'bhopalgarh': 'Jodhpur',
    'भोपालगढ़': 'Jodhpur',
    'pipar': 'Jodhpur',
    'piparcity': 'Jodhpur',
    'pipar city': 'Jodhpur',
    'पीपाड़': 'Jodhpur',
    'पीपाड़ शहर': 'Jodhpur',
    'luni': 'Jodhpur',
    'लूणी': 'Jodhpur',
    'bilara': 'Jodhpur',
    'बिलाड़ा': 'Jodhpur',
    'balesar': 'Jodhpur',
    'बालेसर': 'Jodhpur',
    'shergarh': 'Jodhpur',
    'शेरगढ़': 'Jodhpur',
    'phalodi': 'Jodhpur',
    'फलोदी': 'Jodhpur',
    'baori': 'Jodhpur',
    'तिंवरी': 'Jodhpur',
    'tinwari': 'Jodhpur',
    'tiwari': 'Jodhpur',
    'chamu': 'Jodhpur',
    'jodhpur rural': 'Jodhpur',
    'jodhpur urban': 'Jodhpur',
    'जोधपुर ग्रामीण': 'Jodhpur',
    'जोधपुर शहर': 'Jodhpur',

    // --- Rajasthan (Ajmer) ---
    'beawar': 'Ajmer',
    'ब्यावर': 'Ajmer',
    'kekri': 'Ajmer',
    'केकड़ी': 'Ajmer',
    'kishangarh': 'Ajmer',
    'किशनगढ़': 'Ajmer',
    'bijainagar': 'Ajmer',
    'विजयनगर': 'Ajmer',
    'pushkar': 'Ajmer',
    'sarwar': 'Ajmer',
    'nasirabad': 'Ajmer',

    // --- Rajasthan (Alwar) ---
    'khairthal': 'Alwar',
    'खैरथल': 'Alwar',
    'kherli': 'Alwar',
    'tijara': 'Alwar',
    'तिजारा': 'Alwar',
    'ramgarh': 'Alwar',
    'bhiwadi': 'Alwar',
    'behror': 'Alwar',
    'बहरोड़': 'Alwar',
    'neemrana': 'Alwar',
    'kotkasim': 'Alwar',

    // --- Rajasthan (Barmer) ---
    'balotra': 'Barmer',
    'बालोतरा': 'Barmer',
    'chohtan': 'Barmer',
    'चौहटन': 'Barmer',
    'baytu': 'Barmer',
    'बायतु': 'Barmer',
    'siwana': 'Barmer',
    'सिवाना': 'Barmer',
    'gudamalani': 'Barmer',
    'pachpadra': 'Barmer',
    'पचपदरा': 'Barmer',
    'samdari': 'Barmer',

    // --- Rajasthan (Bharatpur) ---
    'deeg': 'Bharatpur',
    'डीग': 'Bharatpur',
    'kaman': 'Bharatpur',
    'कामां': 'Bharatpur',
    'nadbai': 'Bharatpur',
    'नदबई': 'Bharatpur',
    'nagar': 'Bharatpur',
    'नगर': 'Bharatpur',
    'weir': 'Bharatpur',
    'वैर': 'Bharatpur',
    'bayana': 'Bharatpur',
    'बयाना': 'Bharatpur',
    'bhusawar': 'Bharatpur',
    'भुसावर': 'Bharatpur',

    // --- Rajasthan (Bhilwara) ---
    'shahpura': 'Bhilwara',
    'शाहपुरा': 'Bhilwara',
    'gulabpura': 'Bhilwara',
    'गुलाबपुरा': 'Bhilwara',
    'mandalgarh': 'Bhilwara',
    'मांडलगढ़': 'Bhilwara',
    'asind': 'Bhilwara',
    'आसींद': 'Bhilwara',
    'jahazpur': 'Bhilwara',

    // --- Rajasthan (Bikaner) ---
    'nokha': 'Bikaner',
    'नोखा': 'Bikaner',
    'lunkaransar': 'Bikaner',
    'लूणकरणसर': 'Bikaner',
    'khajuwala': 'Bikaner',
    'खाजूवाला': 'Bikaner',
    'sridungargarh': 'Bikaner',
    'sri dungargarh': 'Bikaner',
    'dungargarh': 'Bikaner',
    'श्रीडूंगरगढ़': 'Bikaner',
    'kolayat': 'Bikaner',
    'कोलायत': 'Bikaner',
    'deshnoke': 'Bikaner',
    'देशनोक': 'Bikaner',

    // --- Rajasthan (Ganganagar) ---
    'anupgarh': 'Ganganagar',
    'अनूपगढ़': 'Ganganagar',
    'suratgarh': 'Ganganagar',
    'सूरतगढ़': 'Ganganagar',
    'gharsana': 'Ganganagar',
    'घड़साना': 'Ganganagar',
    'gajsinghpur': 'Ganganagar',
    'गजासिंहपुर': 'Ganganagar',
    'padampur': 'Ganganagar',
    'पदमपुर': 'Ganganagar',
    'raisinghnagar': 'Ganganagar',
    'रायसिंहनगर': 'Ganganagar',
    'sadulshahar': 'Ganganagar',
    'सादुलशहर': 'Ganganagar',
    'rawla': 'Ganganagar',
    'rawla mandi': 'Ganganagar',
    'sriganganagar': 'Ganganagar',
    'sri ganganagar': 'Ganganagar',
    'श्रीगंगानगर': 'Ganganagar',

    // --- Rajasthan (Hanumangarh) ---
    'nohar': 'Hanumangarh',
    'नोहर': 'Hanumangarh',
    'bhadra': 'Hanumangarh',
    'भादरा': 'Hanumangarh',
    'pilibanga': 'Hanumangarh',
    'पीलीबंगा': 'Hanumangarh',
    'rawatsar': 'Hanumangarh',
    'रावतसर': 'Hanumangarh',
    'sangaria': 'Hanumangarh',
    'संगरिया': 'Hanumangarh',

    // --- Rajasthan (Jaipur) ---
    'chomu': 'Jaipur',
    'चौमू': 'Jaipur',
    'bassi': 'Jaipur',
    'बस्सी': 'Jaipur',
    'chaksu': 'Jaipur',
    'चाकसू': 'Jaipur',
    'kotputli': 'Jaipur',
    'कोटपूतली': 'Jaipur',
    'sambhar': 'Jaipur',
    'सांभर': 'Jaipur',
    'dudu': 'Jaipur',
    'दूदू': 'Jaipur',
    'bagru': 'Jaipur',
    'phulera': 'Jaipur',
    'amer': 'Jaipur',
    'sanganer': 'Jaipur',
    'jaipur rural': 'Jaipur',
    'jaipur urban': 'Jaipur',

    // --- Rajasthan (Jaisalmer) ---
    'pokaran': 'Jaisalmer',
    'pokhran': 'Jaisalmer',
    'पोकरण': 'Jaisalmer',
    'mohangarh': 'Jaisalmer',
    'मोहनगढ़': 'Jaisalmer',
    'ramdevra': 'Jaisalmer',

    // --- Rajasthan (Jalore) ---
    'sanchore': 'Jalore',
    'सांचौर': 'Jalore',
    'bhinmal': 'Jalore',
    'भीनमाल': 'Jalore',
    'raniwara': 'Jalore',
    'रानीवाड़ा': 'Jalore',
    'ahore': 'Jalore',
    'आहोर': 'Jalore',

    // --- Rajasthan (Jhalawar) ---
    'bhawanimandi': 'Jhalawar',
    'bhawani mandi': 'Jhalawar',
    'भवानी मंडी': 'Jhalawar',
    'jhalrapatan': 'Jhalawar',
    'झालरापाटन': 'Jhalawar',
    'aklera': 'Jhalawar',
    'अकलेरा': 'Jhalawar',
    'pirawa': 'Jhalawar',
    'खानपुर': 'Jhalawar',
    'khanpur': 'Jhalawar',

    // --- Rajasthan (Jhunjhunu) ---
    'nawalgarh': 'Jhunjhunu',
    'नवलगढ़': 'Jhunjhunu',
    'chirawa': 'Jhunjhunu',
    'चिड़ावा': 'Jhunjhunu',
    'khetri': 'Jhunjhunu',
    'खेतड़ी': 'Jhunjhunu',
    'surajgarh': 'Jhunjhunu',
    'udaipurwati': 'Jhunjhunu',
    'pilani': 'Jhunjhunu',

    // --- Rajasthan (Karauli) ---
    'hindaun': 'Karauli',
    'hindaun city': 'Karauli',
    'हिंडौन': 'Karauli',
    'todabhim': 'Karauli',

    // --- Rajasthan (Kota) ---
    'ramganjmandi': 'Kota',
    'ramganj mandi': 'Kota',
    'रामगंज मंडी': 'Kota',
    'sangod': 'Kota',
    'सांगोद': 'Kota',
    'itawa': 'Kota',
    'इटावा': 'Kota',
    'sultanpur': 'Kota',

    // --- Rajasthan (Nagaur) ---
    'merta': 'Nagaur',
    'merta city': 'Nagaur',
    'मेड़ता': 'Nagaur',
    'मेड़ता सिटी': 'Nagaur',
    'didwana': 'Nagaur',
    'डीडवाना': 'Nagaur',
    'kuchaman': 'Nagaur',
    'kuchaman city': 'Nagaur',
    'कुचामन': 'Nagaur',
    'makrana': 'Nagaur',
    'मकराना': 'Nagaur',
    'ladnun': 'Nagaur',
    'लाडनूं': 'Nagaur',
    'degana': 'Nagaur',
    'parbatsar': 'Nagaur',
    'jayal': 'Nagaur',
    'khinvsar': 'Nagaur',
    'khimsar': 'Nagaur',

    // --- Rajasthan (Pali) ---
    'sumerpur': 'Pali',
    'सुमेरपुर': 'Pali',
    'sojat': 'Pali',
    'sojat road': 'Pali',
    'सोजत': 'Pali',
    'jaitaran': 'Pali',
    'जैतारण': 'Pali',
    'falna': 'Pali',
    'फालना': 'Pali',
    'bali': 'Pali',
    'बाली': 'Pali',
    'rani': 'Pali',

    // --- Rajasthan (Pratapgarh) ---
    'chhoti sadri': 'Pratapgarh',
    'chhotisadri': 'Pratapgarh',
    'छोटी सादड़ी': 'Pratapgarh',
    'dhariawad': 'Pratapgarh',

    // --- Rajasthan (Rajsamand) ---
    'nathdwara': 'Rajsamand',
    'नाथद्वारा': 'Rajsamand',
    'amet': 'Rajsamand',
    'आमेट': 'Rajsamand',
    'devgarh': 'Rajsamand',
    'kumbhalgarh': 'Rajsamand',

    // --- Rajasthan (Sawai Madhopur) ---
    'gangapur': 'Sawai Madhopur',
    'gangapur city': 'Sawai Madhopur',
    'gangapurcity': 'Sawai Madhopur',
    'गंगापुर सिटी': 'Sawai Madhopur',
    'bamanwas': 'Sawai Madhopur',

    // --- Rajasthan (Sikar) ---
    'neem ka thana': 'Sikar',
    'neemkathana': 'Sikar',
    'नीमकाथाना': 'Sikar',
    'fatehpur': 'Sikar',
    'फतेहपुर': 'Sikar',
    'laxmangarh': 'Sikar',
    'लक्ष्मणगढ़': 'Sikar',
    'sri madhopur': 'Sikar',
    'srimadhopur': 'Sikar',
    'श्रीमाधोपुर': 'Sikar',
    'danta ramgarh': 'Sikar',
    'reengus': 'Sikar',
    'ringas': 'Sikar',
    'रींगस': 'Sikar',

    // --- Rajasthan (Sirohi) ---
    'abu road': 'Sirohi',
    'aburoad': 'Sirohi',
    'आबू रोड': 'Sirohi',
    'pindwara': 'Sirohi',
    'sheoganj': 'Sirohi',

    // --- Rajasthan (Tonk) ---
    'niwai': 'Tonk',
    'newai': 'Tonk',
    'निवाई': 'Tonk',
    'malpura': 'Tonk',
    'मालपुरा': 'Tonk',
    'deoli': 'Tonk',
    'देवली': 'Tonk',
    'uniara': 'Tonk',
    'todaraisingh': 'Tonk',

    // --- Rajasthan (Udaipur) ---
    'salumber': 'Udaipur',
    'सलूंबर': 'Udaipur',
    'fatehnagar': 'Udaipur',
    'kherwara': 'Udaipur',
    'mavli': 'Udaipur',
    'bhinder': 'Udaipur',

    // --- Other States common mandis & tehsils ---
    'mhow': 'Indore', 'sanwer': 'Indore', 'depalpur': 'Indore',
    'nagda': 'Ujjain', 'khachrod': 'Ujjain', 'mahidpur': 'Ujjain',
    'jaora': 'Ratlam', 'sailana': 'Ratlam',
    'pipliya': 'Mandsaur', 'garoth': 'Mandsaur', 'shamgarh': 'Mandsaur',
    'manasa': 'Neemuch', 'jawad': 'Neemuch',
    'itarsi': 'Hoshangabad', 'pipariya': 'Hoshangabad',
    'gondal': 'Rajkot', 'jetpur': 'Rajkot', 'dhoraji': 'Rajkot', 'upleta': 'Rajkot',
    'unjha': 'Mehsana', 'visnagar': 'Mehsana', 'kadi': 'Mehsana',
    'deesa': 'Banaskantha', 'palanpur': 'Banaskantha', 'tharad': 'Banaskantha',
    'siddhpur': 'Patan', 'radhanpur': 'Patan',
    'khanna': 'Ludhiana', 'jagraon': 'Ludhiana',
    'abohar': 'Ferozepur', 'fazilka': 'Ferozepur',
    'malout': 'Muktsar',
    'hansi': 'Hisar', 'barwala': 'Hisar',
    'dabwali': 'Sirsa', 'ellenabad': 'Sirsa',
    'indri': 'Karnal', 'gharaunda': 'Karnal',
    'narnaul': 'Mahendragarh',
    'charkhi dadri': 'Bhiwani',
    'malihabad': 'Lucknow', 'firozabad': 'Agra', 'fatehpur sikri': 'Agra',
    'vrindavan': 'Mathura', 'chhata': 'Mathura',
    'hapur': 'Meerut', 'ghaziabad': 'Meerut',
    'kasganj': 'Aligarh', 'hathras': 'Aligarh',
    'sambhal': 'Moradabad',
    'muzaffarnagar': 'Saharanpur', 'shamli': 'Saharanpur',
    'lasalgaon': 'Nashik', 'manmad': 'Nashik', 'malegaon': 'Nashik',
    'baramati': 'Pune', 'pimpri': 'Pune',
    'sangli': 'Kolhapur', 'miraj': 'Kolhapur', 'satara': 'Kolhapur',
    'jalna': 'Aurangabad',
    'shrirampur': 'Ahmednagar', 'rahuri': 'Ahmednagar',
    'osmanabad': 'Latur', 'nanded': 'Latur',
  };

  /// Check if a district exists in the given state
  static bool hasDistrict(String state, String district) {
    final map = _getMandiMap(state);
    return map.containsKey(district);
  }

  /// Get all mandis for a given state name
  static List<String> getMandisForState(String state) {
    final source = _getMandiMap(state);
    final List<String> all = [];
    for (final list in source.values) {
      all.addAll(list);
    }
    all.sort();
    return all;
  }

  /// Get mandis grouped by district for a state
  static Map<String, List<String>> getDistrictMandis(String state) {
    return _getMandiMap(state);
  }

  /// Returns all district names for a given state (sorted in Hindi alphabetical order)
  static List<String> getDistrictsForState(String state) {
    final map = _getMandiMap(state);
    final list = map.keys.toList();
    list.sort((a, b) => DistrictHelper.getHindiName(a).compareTo(DistrictHelper.getHindiName(b)));
    return list;
  }

  /// Get standard English district name from either Hindi, English, or sub-district/tehsil/mandi input
  static String getStandardDistrictName(String state, String district) {
    if (district.trim().isEmpty) return '';
    final map = _getMandiMap(state);
    final dLower = district.toLowerCase().trim();
    final dNoSpace = dLower.replaceAll(' ', '').replaceAll('-', '');

    // 1. Direct English key match
    for (final entry in map.entries) {
      final keyLower = entry.key.toLowerCase().trim();
      if (keyLower == dLower || keyLower.replaceAll(' ', '') == dNoSpace) {
        return entry.key;
      }
    }

    // 2. Hindi translated match
    for (final entry in map.entries) {
      final hindiName = DistrictHelper.getHindiName(entry.key).toLowerCase().trim();
      if (hindiName == dLower || hindiName.replaceAll(' ', '') == dNoSpace) {
        return entry.key;
      }
    }

    // 3. Sub-district / Tehsil / Town / Mandi alias mapping
    if (_subDistrictToDistrict.containsKey(dLower)) {
      final parent = _subDistrictToDistrict[dLower]!;
      if (map.containsKey(parent)) {
        return parent;
      }
      return parent;
    }
    if (_subDistrictToDistrict.containsKey(dNoSpace)) {
      final parent = _subDistrictToDistrict[dNoSpace]!;
      return parent;
    }

    // 4. Partial check in sub-district mapping
    for (final entry in _subDistrictToDistrict.entries) {
      if (dLower.contains(entry.key) || entry.key.contains(dLower)) {
        return entry.value;
      }
    }

    // 5. Check if any mandi in any district in this state matches or contains the district input
    for (final entry in map.entries) {
      for (final mandi in entry.value) {
        final mLower = mandi.toLowerCase();
        if (mLower.contains(dLower) || dLower.contains(mLower.replaceAll('apmc', '').trim())) {
          return entry.key;
        }
      }
    }

    // 6. Substring contains in keys
    for (final entry in map.entries) {
      final keyLower = entry.key.toLowerCase().trim();
      if (keyLower.contains(dLower) || dLower.contains(keyLower)) {
        return entry.key;
      }
    }

    return district;
  }

  /// Get mandis for a specific district (Supports both Hindi, English & sub-district/tehsil/mandi names)
  static List<String> getMandisForDistrict(String state, String district) {
    final map = _getMandiMap(state);
    final dLower = district.toLowerCase().trim();
    if (dLower.isEmpty) return [];

    // First resolve to standard district name
    final stdDistrict = getStandardDistrictName(state, district);
    if (map.containsKey(stdDistrict)) {
      return map[stdDistrict]!;
    }

    // Direct English key match
    for (final entry in map.entries) {
      final keyLower = entry.key.toLowerCase().trim();
      if (keyLower == dLower || keyLower.contains(dLower) || dLower.contains(keyLower)) {
        return entry.value;
      }
    }

    // Hindi translated match
    for (final entry in map.entries) {
      final hindiName = DistrictHelper.getHindiName(entry.key).toLowerCase().trim();
      if (hindiName == dLower || hindiName.contains(dLower) || dLower.contains(hindiName)) {
        return entry.value;
      }
    }

    return [];
  }

  /// Get default mandi name for a state
  static String getDefaultMandi(String state) {
    final s = state.toLowerCase();
    if (s.contains('rajasthan')) return 'Jaipur (Grain) APMC';
    if (s.contains('madhya')) return 'Indore (Grain) APMC';
    if (s.contains('gujarat')) return 'Rajkot APMC';
    if (s.contains('punjab')) return 'Ludhiana (Grain) APMC';
    if (s.contains('haryana')) return 'Hisar APMC';
    if (s.contains('uttar')) return 'Lucknow APMC';
    if (s.contains('maharashtra')) return 'Vashi APMC';
    if (s.contains('karnataka')) return 'Bengaluru (Yeshwanthpur) APMC';
    if (s.contains('tamil')) return 'Chennai (Koyambedu) APMC';
    if (s.contains('andhra')) return 'Guntur APMC';
    if (s.contains('telangana')) return 'Hyderabad (Bowenpally) APMC';
    if (s.contains('bihar')) return 'Patna APMC';
    if (s.contains('bengal')) return 'Kolkata (Koley Market) APMC';
    if (s.contains('odisha')) return 'Bhubaneswar APMC';
    if (s.contains('chhattisgarh')) return 'Raipur APMC';
    if (s.contains('jharkhand')) return 'Ranchi APMC';
    if (s.contains('uttarakhand')) return 'Dehradun APMC';
    if (s.contains('himachal')) return 'Shimla APMC';
    if (s.contains('assam')) return 'Guwahati (Fancy Bazaar) APMC';
    if (s.contains('kerala')) return 'Kochi APMC';
    return 'Jaipur (Grain) APMC';
  }

  /// Get default district for a state
  static String getDefaultDistrict(String state) {
    final s = state.toLowerCase();
    if (s.contains('rajasthan')) return 'Jaipur';
    if (s.contains('madhya')) return 'Indore';
    if (s.contains('gujarat')) return 'Rajkot';
    if (s.contains('punjab')) return 'Ludhiana';
    if (s.contains('haryana')) return 'Hisar';
    if (s.contains('uttar')) return 'Lucknow';
    if (s.contains('maharashtra')) return 'Pune';
    if (s.contains('karnataka')) return 'Bengaluru';
    if (s.contains('tamil')) return 'Chennai';
    if (s.contains('andhra')) return 'Guntur';
    if (s.contains('telangana')) return 'Hyderabad';
    if (s.contains('bihar')) return 'Patna';
    if (s.contains('bengal')) return 'Kolkata';
    if (s.contains('odisha')) return 'Bhubaneswar';
    if (s.contains('chhattisgarh')) return 'Raipur';
    if (s.contains('jharkhand')) return 'Ranchi';
    if (s.contains('uttarakhand')) return 'Dehradun';
    if (s.contains('himachal')) return 'Shimla';
    if (s.contains('assam')) return 'Guwahati';
    if (s.contains('kerala')) return 'Ernakulam';
    return 'Jaipur';
  }
}
