class CommodityHelper {
  // Mapping of all 266 official API commodities to pure Hindi + English + Category
  static const Map<String, _CropInfo> _cropMap = {
    'ajwan': const _CropInfo('अजवाइन', 'Ajwain / Carom Seeds', 'अजवाइन ajwain / carom seeds ajwan', false),
    'alasande gram': const _CropInfo('लोबिया / चौला दाल', 'Cowpea Split (Alasande)', 'लोबिया / चौला दाल cowpea split (alasande) alasande gram', false),
    'almond(badam)': const _CropInfo('बादाम', 'Almond (Badam)', 'बादाम almond (badam) almond(badam)', false),
    'alsandikai': const _CropInfo('लोबिया फली', 'Cowpea Pods (Alsandi)', 'लोबिया फली cowpea pods (alsandi) alsandikai', true),
    'amaranthus': const _CropInfo('चौलाई साग', 'Amaranth Greens (Chaulai)', 'चौलाई साग amaranth greens (chaulai) amaranthus', true),
    'amla(nelli kai)': const _CropInfo('आंवला', 'Indian Gooseberry (Amla)', 'आंवला indian gooseberry (amla) amla(nelli kai)', true),
    'amranthas red': const _CropInfo('लाल चौलाई', 'Red Amaranth', 'लाल चौलाई red amaranth amranthas red', true),
    'apple': const _CropInfo('सेब', 'Apple', 'सेब apple apple', true),
    'apricot(jardalu/khumani)': const _CropInfo('खुबानी / जरदालू', 'Apricot (Khumani)', 'खुबानी / जरदालू apricot (khumani) apricot(jardalu/khumani)', true),
    'arecanut(betelnut/supari)': const _CropInfo('सुपारी', 'Betel Nut (Supari)', 'सुपारी betel nut (supari) arecanut(betelnut/supari)', false),
    'arhar (tur/red gram)(whole)': const _CropInfo('अरहर / तुअर (साबुत)', 'Pigeon Pea / Toor (Whole)', 'अरहर / तुअर (साबुत) pigeon pea / toor (whole) arhar (tur/red gram)(whole)', false),
    'asalia': const _CropInfo('असालियो / हालीम', 'Garden Cress Seeds (Asalia)', 'असालियो / हालीम garden cress seeds (asalia) asalia', false),
    'asgand': const _CropInfo('अश्वगंधा जड़', 'Ashwagandha Root', 'अश्वगंधा जड़ ashwagandha root asgand', false),
    'ashgourd': const _CropInfo('पेठा / भतुआ', 'Ash Gourd (Petha)', 'पेठा / भतुआ ash gourd (petha) ashgourd', true),
    'ashwagandha': const _CropInfo('अश्वगंधा', 'Ashwagandha', 'अश्वगंधा ashwagandha ashwagandha', false),
    'avare dal': const _CropInfo('वाल दाल', 'Field Bean Split (Avare Dal)', 'वाल दाल field bean split (avare dal) avare dal', false),
    'avocado': const _CropInfo('एवोकाडो', 'Avocado (Butter Fruit)', 'एवोकाडो avocado (butter fruit) avocado', true),
    'baby corn': const _CropInfo('बेबी कॉर्न', 'Baby Corn', 'बेबी कॉर्न baby corn baby corn', true),
    'bajra(pearl millet/cumbu)': const _CropInfo('बाजरा', 'Pearl Millet (Bajra)', 'बाजरा pearl millet (bajra) bajra(pearl millet/cumbu)', false),
    'banana': const _CropInfo('केला', 'Banana', 'केला banana banana', true),
    'banana - green': const _CropInfo('कच्चा केला', 'Raw Banana', 'कच्चा केला raw banana banana - green', true),
    'barley(jau)': const _CropInfo('जौ', 'Barley (Jau)', 'जौ barley (jau) barley(jau)', false),
    'beans': const _CropInfo('बीन्स / हरी फलियां', 'Green Beans', 'बीन्स / हरी फलियां green beans beans', true),
    'beetroot': const _CropInfo('चुकंदर', 'Beetroot', 'चुकंदर beetroot beetroot', true),
    'bengal gram dal(chana dal)': const _CropInfo('चना दाल', 'Bengal Gram Split (Chana Dal)', 'चना दाल bengal gram split (chana dal) bengal gram dal(chana dal)', false),
    'bengal gram(gram)(whole)': const _CropInfo('चना (देसी चना)', 'Bengal Gram / Desi Chana', 'चना (देसी चना) bengal gram / desi chana bengal gram(gram)(whole)', false),
    'ber(zizyphus/borehannu)': const _CropInfo('बेर', 'Indian Jujube (Ber)', 'बेर indian jujube (ber) ber(zizyphus/borehannu)', true),
    'betal leaves': const _CropInfo('पान के पत्ते', 'Betel Leaves (Paan)', 'पान के पत्ते betel leaves (paan) betal leaves', true),
    'bhindi(ladies finger)': const _CropInfo('भिंडी', 'Okra / Ladies Finger', 'भिंडी okra / ladies finger bhindi(ladies finger)', true),
    'big gram': const _CropInfo('काबुली चना (छोला)', 'Kabuli Chana (Chickpeas)', 'काबुली चना (छोला) kabuli chana (chickpeas) big gram', false),
    'bitter gourd': const _CropInfo('करेला', 'Bitter Gourd (Karela)', 'करेला bitter gourd (karela) bitter gourd', true),
    'black gram dal(urd dal)': const _CropInfo('उड़द दाल', 'Black Gram Split (Urad Dal)', 'उड़द दाल black gram split (urad dal) black gram dal(urd dal)', false),
    'black gram(urd beans)(whole)': const _CropInfo('उड़द (साबुत)', 'Black Gram / Urad (Whole)', 'उड़द (साबुत) black gram / urad (whole) black gram(urd beans)(whole)', false),
    'black pepper': const _CropInfo('काली मिर्च', 'Black Pepper', 'काली मिर्च black pepper black pepper', false),
    'bottle gourd': const _CropInfo('लौकी / घिया', 'Bottle Gourd (Lauki)', 'लौकी / घिया bottle gourd (lauki) bottle gourd', true),
    'brinjal': const _CropInfo('बैंगन', 'Brinjal / Eggplant', 'बैंगन brinjal / eggplant brinjal', true),
    'broken rice': const _CropInfo('कनकी (टुकड़ा चावल)', 'Broken Rice (Kanki)', 'कनकी (टुकड़ा चावल) broken rice (kanki) broken rice', false),
    'bunch beans': const _CropInfo('ग्वार फली', 'Cluster Beans', 'ग्वार फली cluster beans bunch beans', true),
    'cabbage': const _CropInfo('पत्ता गोभी', 'Cabbage', 'पत्ता गोभी cabbage cabbage', true),
    'capsicum': const _CropInfo('शिमला मिर्च', 'Capsicum / Bell Pepper', 'शिमला मिर्च capsicum / bell pepper capsicum', true),
    'cardamom': const _CropInfo('इलायची', 'Cardamom', 'इलायची cardamom cardamom', false),
    'carrot': const _CropInfo('गाजर', 'Carrot', 'गाजर carrot carrot', true),
    'cashewnuts': const _CropInfo('काजू', 'Cashew Nuts (Kaju)', 'काजू cashew nuts (kaju) cashewnuts', false),
    'castor seed': const _CropInfo('अरंडी बीज (एरंड)', 'Castor Seed (Arandi)', 'अरंडी बीज (एरंड) castor seed (arandi) castor seed', false),
    'cauliflower': const _CropInfo('फूल गोभी', 'Cauliflower', 'फूल गोभी cauliflower cauliflower', true),
    'chapparad avare': const _CropInfo('सेम फली', 'Broad Beans', 'सेम फली broad beans chapparad avare', true),
    'chena': const _CropInfo('छेना / चेना दाल', 'Chena Dal', 'छेना / चेना दाल chena dal chena', false),
    'chennangi dal': const _CropInfo('चेन्नांगी दाल', 'Chennangi Dal', 'चेन्नांगी दाल chennangi dal chennangi dal', false),
    'chiaseeds': const _CropInfo('चिया बीज', 'Chia Seeds', 'चिया बीज chia seeds chiaseeds', false),
    'chicory(chikori/kasni)': const _CropInfo('कासनी', 'Chicory (Kasni)', 'कासनी chicory (kasni) chicory(chikori/kasni)', false),
    'chikoos(sapota)': const _CropInfo('चीकू', 'Sapodilla (Chikoo)', 'चीकू sapodilla (chikoo) chikoos(sapota)', true),
    'chili red': const _CropInfo('सूखी लाल मिर्च', 'Dry Red Chilli', 'सूखी लाल मिर्च dry red chilli chili red', false),
    'chilly capsicum': const _CropInfo('मोटी मिर्च / शिमला मिर्च', 'Chilli Capsicum', 'मोटी मिर्च / शिमला मिर्च chilli capsicum chilly capsicum', true),
    'chow chow': const _CropInfo('चौ-चौ (इस्कस)', 'Chow Chow (Chayote)', 'चौ-चौ (इस्कस) chow chow (chayote) chow chow', true),
    'cluster beans': const _CropInfo('ग्वार फली (सब्जी)', 'Cluster Beans', 'ग्वार फली (सब्जी) cluster beans cluster beans', true),
    'coconut': const _CropInfo('नारियल', 'Coconut', 'नारियल coconut coconut', true),
    'coconut oil': const _CropInfo('नारियल तेल', 'Coconut Oil', 'नारियल तेल coconut oil coconut oil', false),
    'coconut seed': const _CropInfo('नारियल (गोला)', 'Dry Coconut (Gola)', 'नारियल (गोला) dry coconut (gola) coconut seed', false),
    'coffee': const _CropInfo('कॉफी बीन्स', 'Coffee Beans', 'कॉफी बीन्स coffee beans coffee', false),
    'colacasia': const _CropInfo('अरबी / घुइयां', 'Colocasia (Arbi)', 'अरबी / घुइयां colocasia (arbi) colacasia', true),
    'copra': const _CropInfo('सूखा नारियल (खोपरा)', 'Copra (Dry Coconut)', 'सूखा नारियल (खोपरा) copra (dry coconut) copra', false),
    'coriander(leaves)': const _CropInfo('हरा धनिया', 'Fresh Coriander Leaves', 'हरा धनिया fresh coriander leaves coriander(leaves)', true),
    'corriander seed': const _CropInfo('धनिया बीज', 'Coriander Seeds (Dhaniya)', 'धनिया बीज coriander seeds (dhaniya) corriander seed', false),
    'cotton': const _CropInfo('कपास / नरमा', 'Raw Cotton (Kapas)', 'कपास / नरमा raw cotton (kapas) cotton', false),
    'cotton seed': const _CropInfo('बिनौला (कपास बीज)', 'Cottonseed (Binaula)', 'बिनौला (कपास बीज) cottonseed (binaula) cotton seed', false),
    'cow': const _CropInfo('गाय', 'Cow', 'गाय cow cow', false),
    'cowpea(lobia/karamani)': const _CropInfo('चंवला / लोबिया', 'Cowpea (Chawla / Lobia)', 'चंवला / लोबिया cowpea (chawla / lobia) cowpea(lobia/karamani)', false),
    'cowpea(veg)': const _CropInfo('लोबिया फली', 'Green Cowpea Pods', 'लोबिया फली green cowpea pods cowpea(veg)', true),
    'cucumbar(kheera)': const _CropInfo('खीरा / ककड़ी', 'Cucumber (Kheera)', 'खीरा / ककड़ी cucumber (kheera) cucumbar(kheera)', true),
    'cumin seed': const _CropInfo('जीरा', 'Cumin Seeds (Jeera)', 'जीरा cumin seeds (jeera) cumin seed', false),
    'cummin seed(jeera)': const _CropInfo('जीरा', 'Cumin Seeds (Jeera)', 'जीरा cumin seeds (jeera) cummin seed(jeera)', false),
    'custard apple(sharifa)': const _CropInfo('शरीफा / सीताफल', 'Custard Apple (Sharifa)', 'शरीफा / सीताफल custard apple (sharifa) custard apple(sharifa)', true),
    'dal mix': const _CropInfo('मिक्स दाल', 'Mixed Pulses (Mix Dal)', 'मिक्स दाल mixed pulses (mix dal) dal mix', false),
    'dhaniya dal': const _CropInfo('धनिया दाल / ईगल', 'Eagle Dhaniya Dal', 'धनिया दाल / ईगल eagle dhaniya dal dhaniya dal', false),
    'drumstick': const _CropInfo('सहजन (ड्रमस्टिक)', 'Drumstick (Moringa)', 'सहजन (ड्रमस्टिक) drumstick (moringa) drumstick', true),
    'dry chillies': const _CropInfo('सूखी मिर्च', 'Dry Red Chillies', 'सूखी मिर्च dry red chillies dry chillies', false),
    'dry fodder': const _CropInfo('सूखा चारा (भूसा)', 'Dry Fodder (Bhusa)', 'सूखा चारा (भूसा) dry fodder (bhusa) dry fodder', false),
    'dry grapes': const _CropInfo('किशमिश / दाख', 'Raisins / Dry Grapes', 'किशमिश / दाख raisins / dry grapes dry grapes', true),
    'duster beans': const _CropInfo('ग्वार फली', 'Cluster Beans', 'ग्वार फली cluster beans duster beans', true),
    'elephant yam(suran)/amorphophallus': const _CropInfo('जिमीकंद / सूरन', 'Elephant Foot Yam (Suran)', 'जिमीकंद / सूरन elephant foot yam (suran) elephant yam(suran)/amorphophallus', true),
    'field bean(anumulu)': const _CropInfo('सेम फली बीज', 'Field Beans (Anumulu)', 'सेम फली बीज field beans (anumulu) field bean(anumulu)', false),
    'field pea': const _CropInfo('हरा मटर दाना', 'Field Peas', 'हरा मटर दाना field peas field pea', false),
    'fig(anjura/anjeer)': const _CropInfo('अंजीर', 'Fresh Fig (Anjeer)', 'अंजीर fresh fig (anjeer) fig(anjura/anjeer)', true),
    'firewood': const _CropInfo('जलाऊ लकड़ी', 'Firewood', 'जलाऊ लकड़ी firewood firewood', false),
    'fish': const _CropInfo('मछली', 'Freshwater Fish', 'मछली freshwater fish fish', false),
    'french beans(frasbean)': const _CropInfo('फ्रेंच बीन्स', 'French Beans', 'फ्रेंच बीन्स french beans french beans(frasbean)', true),
    'galgal(lemon)': const _CropInfo('गलगल नींबू', 'Hill Lemon (Galgal)', 'गलगल नींबू hill lemon (galgal) galgal(lemon)', true),
    'garlic': const _CropInfo('लहसुन', 'Garlic (Lahsun)', 'लहसुन garlic (lahsun) garlic', false),
    'ghee': const _CropInfo('देसी घी', 'Desi Ghee', 'देसी घी desi ghee ghee', false),
    'ginger(dry)': const _CropInfo('सोंठ (सूखा अदरक)', 'Dry Ginger (Sonth)', 'सोंठ (सूखा अदरक) dry ginger (sonth) ginger(dry)', false),
    'ginger(green)': const _CropInfo('ताज़ा अदरक', 'Fresh Ginger (Adrak)', 'ताज़ा अदरक fresh ginger (adrak) ginger(green)', true),
    'gond': const _CropInfo('खाने का गोंद', 'Edible Gum (Gond)', 'खाने का गोंद edible gum (gond) gond', false),
    'gram raw(chholia)': const _CropInfo('हरा चना (छोलिया)', 'Green Fresh Gram (Chholia)', 'हरा चना (छोलिया) green fresh gram (chholia) gram raw(chholia)', true),
    'grapes': const _CropInfo('अंगूर', 'Grapes', 'अंगूर grapes grapes', true),
    'green avare(w)': const _CropInfo('हरी सेम', 'Fresh Broad Beans', 'हरी सेम fresh broad beans green avare(w)', true),
    'green chilli': const _CropInfo('हरी मिर्च', 'Green Chilli', 'हरी मिर्च green chilli green chilli', true),
    'green fodder': const _CropInfo('हरा चारा (बरसीम/ज्वार)', 'Green Fodder (Barseem)', 'हरा चारा (बरसीम/ज्वार) green fodder (barseem) green fodder', false),
    'green gram dal(moong dal)': const _CropInfo('मूंग दाल', 'Green Gram Split (Moong Dal)', 'मूंग दाल green gram split (moong dal) green gram dal(moong dal)', false),
    'green gram(moong)(whole)': const _CropInfo('मूंग (साबुत)', 'Green Gram / Moong (Whole)', 'मूंग (साबुत) green gram / moong (whole) green gram(moong)(whole)', false),
    'green peas': const _CropInfo('हरी मटर', 'Fresh Green Peas', 'हरी मटर fresh green peas green peas', true),
    'ground nut seed': const _CropInfo('मूंगफली दाना', 'Peanut Kernels', 'मूंगफली दाना peanut kernels ground nut seed', false),
    'groundnut': const _CropInfo('मूंगफली', 'Groundnut / Peanut', 'मूंगफली groundnut / peanut groundnut', false),
    'groundnut (split)': const _CropInfo('मूंगफली गिरी', 'Groundnut Split', 'मूंगफली गिरी groundnut split groundnut (split)', false),
    'groundnut pods (raw)': const _CropInfo('मूंगफली (कच्ची)', 'Raw Groundnut Pods', 'मूंगफली (कच्ची) raw groundnut pods groundnut pods (raw)', false),
    'groundnut pods(raw)': const _CropInfo('मूंगफली (कच्ची)', 'Raw Groundnut Pods', 'मूंगफली (कच्ची) raw groundnut pods groundnut pods(raw)', false),
    'guar': const _CropInfo('ग्वार', 'Guar Bean', 'ग्वार guar bean guar', false),
    'guar churi': const _CropInfo('ग्वार चूरी', 'Guar Churi Feed', 'ग्वार चूरी guar churi feed guar churi', false),
    'guar gum': const _CropInfo('ग्वार गम', 'Guar Gum', 'ग्वार गम guar gum guar gum', false),
    'guar korma': const _CropInfo('ग्वार कोरमा', 'Guar Korma Feed', 'ग्वार कोरमा guar korma feed guar korma', false),
    'guar seed(cluster beans seed)': const _CropInfo('ग्वार बीज', 'Guar Seed (Cluster Beans)', 'ग्वार बीज guar seed (cluster beans) guar seed(cluster beans seed)', false),
    'guava': const _CropInfo('अमरूद', 'Guava (Amrood)', 'अमरूद guava (amrood) guava', true),
    'gur(jaggery)': const _CropInfo('गुड़', 'Jaggery (Gur)', 'गुड़ jaggery (gur) gur(jaggery)', false),
    'hingot': const _CropInfo('हिंगोट', 'Hingot Fruit', 'हिंगोट hingot fruit hingot', true),
    'indian beans(seam)': const _CropInfo('सेम फली', 'Indian Broad Beans (Sem)', 'सेम फली indian broad beans (sem) indian beans(seam)', true),
    'isabgol bhusi': const _CropInfo('इसबगोल भूसी', 'Psyllium Husk', 'इसबगोल भूसी psyllium husk isabgol bhusi', false),
    'isabgul(psyllium)': const _CropInfo('इसबगोल', 'Psyllium Seed (Isabgol)', 'इसबगोल psyllium seed (isabgol) isabgul(psyllium)', false),
    'jack fruit(ripe)': const _CropInfo('कटहल', 'Jackfruit (Kathal)', 'कटहल jackfruit (kathal) jack fruit(ripe)', true),
    'jasmine': const _CropInfo('चमेली फूल', 'Jasmine Flower', 'चमेली फूल jasmine flower jasmine', false),
    'jowar(sorghum)': const _CropInfo('ज्वार', 'Sorghum (Jowar)', 'ज्वार sorghum (jowar) jowar(sorghum)', false),
    'jute': const _CropInfo('जूट / पटसन', 'Raw Jute', 'जूट / पटसन raw jute jute', false),
    'kabuli chana': const _CropInfo('काबुली चना / डॉलर', 'Kabuli Chickpeas', 'काबुली चना / डॉलर kabuli chickpeas kabuli chana', false),
    'kabuli chana(chickpeas-white)': const _CropInfo('काबुली चना (सफेद छोला)', 'Kabuli Chana (White Chickpeas)', 'काबुली चना (सफेद छोला) kabuli chana (white chickpeas) kabuli chana(chickpeas-white)', false),
    'kakada': const _CropInfo('काकड़ा फूल', 'Kakada Flower', 'काकड़ा फूल kakada flower kakada', false),
    'kalonji': const _CropInfo('कलौंजी', 'Nigella Seeds (Kalonji)', 'कलौंजी nigella seeds (kalonji) kalonji', false),
    'kantakari': const _CropInfo('कंटकारी', 'Kantakari Herb', 'कंटकारी kantakari herb kantakari', false),
    'karbuja(musk melon)': const _CropInfo('खरबूजा', 'Muskmelon (Kharbooja)', 'खरबूजा muskmelon (kharbooja) karbuja(musk melon)', true),
    'kasuri methi': const _CropInfo('कसूरी मेथी', 'Dry Fenugreek Leaves', 'कसूरी मेथी dry fenugreek leaves kasuri methi', false),
    'kaunch': const _CropInfo('कौंच बीज', 'Mucuna Pruriens (Kaunch)', 'कौंच बीज mucuna pruriens (kaunch) kaunch', false),
    'khandsari(desi khand)': const _CropInfo('देसी खांड', 'Desi Khand (Khandsari)', 'देसी खांड desi khand (khandsari) khandsari(desi khand)', false),
    'kinnow': const _CropInfo('किन्नू', 'Kinnow Mandarin', 'किन्नू kinnow mandarin kinnow', true),
    'kiwi fruit': const _CropInfo('कीवी फल', 'Kiwi Fruit', 'कीवी फल kiwi fruit kiwi fruit', true),
    'knool khol': const _CropInfo('गांठ गोभी', 'Kohlrabi (Ganth Gobhi)', 'गांठ गोभी kohlrabi (ganth gobhi) knool khol', true),
    'kodo millet(varagu)': const _CropInfo('कोदो बाजरा', 'Kodo Millet', 'कोदो बाजरा kodo millet kodo millet(varagu)', false),
    'kulthi(horse gram)': const _CropInfo('कुलथी', 'Horse Gram (Kulthi)', 'कुलथी horse gram (kulthi) kulthi(horse gram)', false),
    'kutki': const _CropInfo('कुटकी बाजरा', 'Little Millet (Kutki)', 'कुटकी बाजरा little millet (kutki) kutki', false),
    'ladies finger': const _CropInfo('भिंडी', 'Okra / Ladies Finger', 'भिंडी okra / ladies finger ladies finger', true),
    'lak(teora)': const _CropInfo('तीवड़ा / लख दाल', 'Grass Pea (Teora/Lakh)', 'तीवड़ा / लख दाल grass pea (teora/lakh) lak(teora)', false),
    'leafy vegetable': const _CropInfo('हरी पत्तेदार सब्जी', 'Green Leafy Vegetables', 'हरी पत्तेदार सब्जी green leafy vegetables leafy vegetable', true),
    'lemon': const _CropInfo('नींबू', 'Lemon (Nimbu)', 'नींबू lemon (nimbu) lemon', true),
    'lentil(masur)(whole)': const _CropInfo('मसूर (साबुत)', 'Red Lentil / Masoor (Whole)', 'मसूर (साबुत) red lentil / masoor (whole) lentil(masur)(whole)', false),
    'lime': const _CropInfo('नींबू', 'Lime / Lemon', 'नींबू lime / lemon lime', true),
    'linseed': const _CropInfo('अलसी', 'Flaxseed / Linseed (Alsi)', 'अलसी flaxseed / linseed (alsi) linseed', false),
    'lint': const _CropInfo('कपास रुई (लिंट)', 'Cotton Lint', 'कपास रुई (लिंट) cotton lint lint', false),
    'little gourd(kundru)': const _CropInfo('कुंदरू', 'Ivy Gourd (Kundru)', 'कुंदरू ivy gourd (kundru) little gourd(kundru)', true),
    'long melon(kakri)': const _CropInfo('ककड़ी', 'Long Melon (Kakri)', 'ककड़ी long melon (kakri) long melon(kakri)', true),
    'mahedi': const _CropInfo('मेंहदी', 'Henna (Mehndi)', 'मेंहदी henna (mehndi) mahedi', false),
    'mahua': const _CropInfo('महुआ फूल', 'Mahua Flowers', 'महुआ फूल mahua flowers mahua', false),
    'mahua seed(hippe seed)': const _CropInfo('महुआ बीज (टोलिया)', 'Mahua Seeds', 'महुआ बीज (टोलिया) mahua seeds mahua seed(hippe seed)', false),
    'maize': const _CropInfo('मक्का', 'Maize / Corn (Makka)', 'मक्का maize / corn (makka) maize', false),
    'makhana(foxnut)': const _CropInfo('मखाना', 'Fox Nuts (Makhana)', 'मखाना fox nuts (makhana) makhana(foxnut)', false),
    'mango': const _CropInfo('पका आम', 'Mango (Aam)', 'पका आम mango (aam) mango', true),
    'mango(raw-ripe)': const _CropInfo('कच्चा/पका आम', 'Raw / Ripe Mango', 'कच्चा/पका आम raw / ripe mango mango(raw-ripe)', true),
    'marasebu': const _CropInfo('नाशपाती', 'Pear (Marasebu)', 'नाशपाती pear (marasebu) marasebu', true),
    'marigold(calcutta)': const _CropInfo('कलकत्ता गेंदा फूल', 'Calcutta Marigold', 'कलकत्ता गेंदा फूल calcutta marigold marigold(calcutta)', false),
    'marigold(loose)': const _CropInfo('गेंदा फूल', 'Loose Marigold', 'गेंदा फूल loose marigold marigold(loose)', false),
    'mashrooms': const _CropInfo('मशरूम (खुंबी)', 'Mushroom', 'मशरूम (खुंबी) mushroom mashrooms', true),
    'masur dal': const _CropInfo('मसूर दाल', 'Red Lentil Split (Masoor Dal)', 'मसूर दाल red lentil split (masoor dal) masur dal', false),
    'mataki': const _CropInfo('मटकी / मोठ', 'Moth Bean (Matki)', 'मटकी / मोठ moth bean (matki) mataki', false),
    'mentha oil': const _CropInfo('मेंथा तेल (पिपरमिंट)', 'Mentha / Peppermint Oil', 'मेंथा तेल (पिपरमिंट) mentha / peppermint oil mentha oil', false),
    'methi seeds': const _CropInfo('मेथी दाना', 'Fenugreek Seeds (Methi)', 'मेथी दाना fenugreek seeds (methi) methi seeds', false),
    'methi(leaves)': const _CropInfo('हरी मेथी', 'Fresh Fenugreek Leaves', 'हरी मेथी fresh fenugreek leaves methi(leaves)', true),
    'mint(pudina)': const _CropInfo('पुदीना', 'Mint Leaves (Pudina)', 'पुदीना mint leaves (pudina) mint(pudina)', true),
    'moong(green gram)': const _CropInfo('मूंग', 'Green Gram (Moong)', 'मूंग green gram (moong) moong(green gram)', false),
    'moth': const _CropInfo('मोठ', 'Moth Bean', 'मोठ moth bean moth', false),
    'moth dal': const _CropInfo('मोठ दाल', 'Moth Split Dal', 'मोठ दाल moth split dal moth dal', false),
    'mousambi(sweet lime)': const _CropInfo('मौसमी', 'Sweet Lime (Mousambi)', 'मौसमी sweet lime (mousambi) mousambi(sweet lime)', true),
    'mushrooms': const _CropInfo('मशरूम', 'Mushroom', 'मशरूम mushroom mushrooms', true),
    'musk melon': const _CropInfo('खरबूजा', 'Muskmelon', 'खरबूजा muskmelon musk melon', true),
    'mustard': const _CropInfo('सरसों / रायड़ा', 'Mustard Seed (Sarson)', 'सरसों / रायड़ा mustard seed (sarson) mustard', false),
    'mustard oil': const _CropInfo('सरसों तेल', 'Mustard Oil', 'सरसों तेल mustard oil mustard oil', false),
    'neem seed': const _CropInfo('नीम बीज (निंबोली)', 'Neem Seed (Nimboli)', 'नीम बीज (निंबोली) neem seed (nimboli) neem seed', false),
    'onion': const _CropInfo('प्याज', 'Onion (Pyaj)', 'प्याज onion (pyaj) onion', true),
    'onion green': const _CropInfo('हरा प्याज (आल)', 'Spring Onion (Hara Pyaj)', 'हरा प्याज (आल) spring onion (hara pyaj) onion green', true),
    'orange': const _CropInfo('संतरा', 'Orange (Santra)', 'संतरा orange (santra) orange', true),
    'other green and fresh vegetables': const _CropInfo('ताज़ी हरी सब्जियां', 'Mixed Fresh Vegetables', 'ताज़ी हरी सब्जियां mixed fresh vegetables other green and fresh vegetables', true),
    'ox': const _CropInfo('बैल', 'Ox / Bull', 'बैल ox / bull ox', false),
    'paddy(basmati)': const _CropInfo('बासमती धान', 'Basmati Paddy', 'बासमती धान basmati paddy paddy(basmati)', false),
    'paddy(common)': const _CropInfo('धान (चावल)', 'Common Paddy (Dhan)', 'धान (चावल) common paddy (dhan) paddy(common)', false),
    'papaya': const _CropInfo('पपीता', 'Papaya (Papita)', 'पपीता papaya (papita) papaya', true),
    'papaya(raw)': const _CropInfo('कच्चा पपीता', 'Raw Green Papaya', 'कच्चा पपीता raw green papaya papaya(raw)', true),
    'pea pod/pea cod/हरी मटर': const _CropInfo('हरी मटर', 'Green Peas Pods', 'हरी मटर green peas pods pea pod/pea cod/हरी मटर', true),
    'pear(marasebu)': const _CropInfo('नाशपाती', 'Pear (Nashpati)', 'नाशपाती pear (nashpati) pear(marasebu)', true),
    'peas wet': const _CropInfo('ताज़ी हरी मटर', 'Fresh Green Peas', 'ताज़ी हरी मटर fresh green peas peas wet', true),
    'peas(dry)': const _CropInfo('सूखी मटर', 'Dry Peas', 'सूखी मटर dry peas peas(dry)', false),
    'pegeon pea(arhar fali)': const _CropInfo('अरहर फली', 'Pigeon Pea Pods', 'अरहर फली pigeon pea pods pegeon pea(arhar fali)', true),
    'pepper garbled': const _CropInfo('काली मिर्च (साफ)', 'Garbled Black Pepper', 'काली मिर्च (साफ) garbled black pepper pepper garbled', false),
    'persimon(japani fal)': const _CropInfo('जापानी फल (अमलोक)', 'Persimmon Fruit', 'जापानी फल (अमलोक) persimmon fruit persimon(japani fal)', true),
    'pineapple': const _CropInfo('अनानास', 'Pineapple', 'अनानास pineapple pineapple', true),
    'plum': const _CropInfo('आलूबुखारा', 'Plum (Aloo Bukhara)', 'आलूबुखारा plum (aloo bukhara) plum', true),
    'pointed gourd(parval)': const _CropInfo('परवल', 'Pointed Gourd (Parwal)', 'परवल pointed gourd (parwal) pointed gourd(parval)', true),
    'pomegranate': const _CropInfo('अनार', 'Pomegranate (Anaar)', 'अनार pomegranate (anaar) pomegranate', true),
    'potato': const _CropInfo('आलू', 'Potato (Aloo)', 'आलू potato (aloo) potato', true),
    'prawn': const _CropInfo('झींगा मछली', 'Prawns', 'झींगा मछली prawns prawn', false),
    'pumpkin': const _CropInfo('कद्दू / सीताफल', 'Pumpkin (Kaddu)', 'कद्दू / सीताफल pumpkin (kaddu) pumpkin', true),
    'quinoa': const _CropInfo('क्विनोआ', 'Quinoa Grain', 'क्विनोआ quinoa grain quinoa', false),
    'rab/liquid jaggery/molasses': const _CropInfo('राब (तरल गुड़)', 'Liquid Jaggery (Rab)', 'राब (तरल गुड़) liquid jaggery (rab) rab/liquid jaggery/molasses', false),
    'raddish': const _CropInfo('मूली', 'Radish (Mooli)', 'मूली radish (mooli) raddish', true),
    'ragi(finger millet)': const _CropInfo('रागी / मडुआ', 'Finger Millet (Ragi)', 'रागी / मडुआ finger millet (ragi) ragi(finger millet)', false),
    'rajgir': const _CropInfo('राजगिरा / रामदाना', 'Amaranth Seed (Rajgira)', 'राजगिरा / रामदाना amaranth seed (rajgira) rajgir', false),
    'rambans(agave /century plant)': const _CropInfo('रामबांस', 'Agave Plant', 'रामबांस agave plant rambans(agave /century plant)', false),
    'rape seed': const _CropInfo('राई / लाहा', 'Rapeseed / Rai', 'राई / लाहा rapeseed / rai rape seed', false),
    'red gram split/arhar dal/tur dal': const _CropInfo('अरहर / तुअर दाल', 'Toor Dal / Arhar Dal', 'अरहर / तुअर दाल toor dal / arhar dal red gram split/arhar dal/tur dal', false),
    'red gram/arhar/tur(whole)': const _CropInfo('अरहर (साबुत)', 'Whole Pigeon Pea (Arhar)', 'अरहर (साबुत) whole pigeon pea (arhar) red gram/arhar/tur(whole)', false),
    'rice': const _CropInfo('चावल', 'Rice (Chawal)', 'चावल rice (chawal) rice', false),
    'ridgeguard(tori)': const _CropInfo('तोरई / झिंगा', 'Ridge Gourd (Tori)', 'तोरई / झिंगा ridge gourd (tori) ridgeguard(tori)', true),
    'rose(local)': const _CropInfo('देसी गुलाब', 'Local Desi Rose', 'देसी गुलाब local desi rose rose(local)', false),
    'rose(loose))': const _CropInfo('गुलाब फूल', 'Loose Rose', 'गुलाब फूल loose rose rose(loose))', false),
    'round gourd': const _CropInfo('टिंडा', 'Round Gourd (Tinda)', 'टिंडा round gourd (tinda) round gourd', true),
    'rubber': const _CropInfo('रबर', 'Natural Rubber', 'रबर natural rubber rubber', false),
    'sabu dan': const _CropInfo('साबूदाना', 'Sago (Sabudana)', 'साबूदाना sago (sabudana) sabu dan', false),
    'safflower': const _CropInfo('कुसुम बीज (करड़ी)', 'Safflower (Kusum)', 'कुसुम बीज (करड़ी) safflower (kusum) safflower', false),
    'same/savi': const _CropInfo('सावां बाजरा', 'Barnyard Millet (Sawa)', 'सावां बाजरा barnyard millet (sawa) same/savi', false),
    'seemebadnekai': const _CropInfo('चौ-चौ', 'Chayote Squash', 'चौ-चौ chayote squash seemebadnekai', true),
    'seetapal': const _CropInfo('सीताफल (शरीफा)', 'Custard Apple (Sitaphal)', 'सीताफल (शरीफा) custard apple (sitaphal) seetapal', true),
    'sesamum': const _CropInfo('तिल', 'Sesame Seeds (Til)', 'तिल sesame seeds (til) sesamum', false),
    'sesamum(sesame,gingelly,til)': const _CropInfo('तिल', 'Sesame Seeds (Til)', 'तिल sesame seeds (til) sesamum(sesame,gingelly,til)', false),
    'she buffalo': const _CropInfo('भैंस', 'She Buffalo', 'भैंस she buffalo she buffalo', false),
    'snakeguard': const _CropInfo('चिचिंडा / पडवल', 'Snake Gourd (Chichinda)', 'चिचिंडा / पडवल snake gourd (chichinda) snakeguard', true),
    'soanf': const _CropInfo('सौंफ', 'Fennel Seeds (Saunf)', 'सौंफ fennel seeds (saunf) soanf', false),
    'soyabean': const _CropInfo('सोयाबीन', 'Soybean', 'सोयाबीन soybean soyabean', false),
    'spinach': const _CropInfo('पालक', 'Spinach (Palak)', 'पालक spinach (palak) spinach', true),
    'spiny gourd / kartali(kantola)': const _CropInfo('कंटोला / काकोड़ा', 'Spiny Gourd (Kantola)', 'कंटोला / काकोड़ा spiny gourd (kantola) spiny gourd / kartali(kantola)', true),
    'sponge gourd': const _CropInfo('तोरई / तोरी', 'Sponge Gourd (Ghiya Tori)', 'तोरई / तोरी sponge gourd (ghiya tori) sponge gourd', true),
    'squash(chappal kadoo)': const _CropInfo('चप्पन कद्दू', 'Squash (Chappan Kaddu)', 'चप्पन कद्दू squash (chappan kaddu) squash(chappal kadoo)', true),
    'sugar': const _CropInfo('चीनी (शक्कर)', 'Sugar', 'चीनी (शक्कर) sugar sugar', false),
    'sugarcane': const _CropInfo('गन्ना', 'Sugarcane', 'गन्ना sugarcane sugarcane', false),
    'sunflower/sunflower seed': const _CropInfo('सूरजमुखी बीज', 'Sunflower Seed', 'सूरजमुखी बीज sunflower seed sunflower/sunflower seed', false),
    'surat beans(papadi)': const _CropInfo('सूरत पापड़ी सेम', 'Surat Papdi Beans', 'सूरत पापड़ी सेम surat papdi beans surat beans(papadi)', true),
    'suva': const _CropInfo('सुवा / सोया बीज', 'Dill Seed (Suva)', 'सुवा / सोया बीज dill seed (suva) suva', false),
    'suva(dill seed)': const _CropInfo('सुवा / सोया बीज', 'Dill Seed (Suva)', 'सुवा / सोया बीज dill seed (suva) suva(dill seed)', false),
    'sweet corn': const _CropInfo('स्वीट कॉर्न (मीठा भुट्टा)', 'Sweet Corn', 'स्वीट कॉर्न (मीठा भुट्टा) sweet corn sweet corn', true),
    'sweet potato': const _CropInfo('शकरकंद', 'Sweet Potato (Shakarkand)', 'शकरकंद sweet potato (shakarkand) sweet potato', true),
    'sweet pumpkin': const _CropInfo('मीठा कद्दू', 'Sweet Pumpkin', 'मीठा कद्दू sweet pumpkin sweet pumpkin', true),
    'sweet saag': const _CropInfo('मीठा साग', 'Sweet Greens', 'मीठा साग sweet greens sweet saag', true),
    'tamarind fruit': const _CropInfo('इमली', 'Tamarind (Imli)', 'इमली tamarind (imli) tamarind fruit', true),
    'tapioca': const _CropInfo('कसावा / टैपिओका', 'Tapioca (Cassava)', 'कसावा / टैपिओका tapioca (cassava) tapioca', true),
    'taramira': const _CropInfo('तारामीरा', 'Taramira Seed', 'तारामीरा taramira seed taramira', false),
    'taro (arvi) stem': const _CropInfo('अरबी डंठल', 'Colocasia Stem', 'अरबी डंठल colocasia stem taro (arvi) stem', true),
    'tender coconut': const _CropInfo('डाभ नारियल (पानी वाला)', 'Tender Coconut (Dabh)', 'डाभ नारियल (पानी वाला) tender coconut (dabh) tender coconut', true),
    'tendu leaves/kendu leaves/bidi leaves': const _CropInfo('तेंदू पत्ता', 'Tendu / Bidi Leaves', 'तेंदू पत्ता tendu / bidi leaves tendu leaves/kendu leaves/bidi leaves', false),
    'thondekai': const _CropInfo('कुंदरू', 'Ivy Gourd (Kundru)', 'कुंदरू ivy gourd (kundru) thondekai', true),
    'til': const _CropInfo('तिल', 'Sesame Seeds (Til)', 'तिल sesame seeds (til) til', false),
    'tinda': const _CropInfo('टिंडा', 'Round Gourd (Tinda)', 'टिंडा round gourd (tinda) tinda', true),
    'tobacco': const _CropInfo('तंबाकू', 'Tobacco Leaves', 'तंबाकू tobacco leaves tobacco', false),
    'tomato': const _CropInfo('टमाटर', 'Tomato (Tamatar)', 'टमाटर tomato (tamatar) tomato', true),
    'tube flower': const _CropInfo('रजनीगंधा फूल', 'Tuberose Flower', 'रजनीगंधा फूल tuberose flower tube flower', false),
    'tube rose(loose)': const _CropInfo('रजनीगंधा (खुला)', 'Loose Tuberose', 'रजनीगंधा (खुला) loose tuberose tube rose(loose)', false),
    'turmeric': const _CropInfo('हल्दी', 'Turmeric (Haldi)', 'हल्दी turmeric (haldi) turmeric', false),
    'turmeric(raw)': const _CropInfo('कच्ची हल्दी', 'Raw Fresh Turmeric', 'कच्ची हल्दी raw fresh turmeric turmeric(raw)', false),
    'turnip': const _CropInfo('शलजम', 'Turnip (Shalgam)', 'शलजम turnip (shalgam) turnip', true),
    'water melon': const _CropInfo('तरबूज', 'Watermelon (Tarbooj)', 'तरबूज watermelon (tarbooj) water melon', true),
    'wheat': const _CropInfo('गेहूं', 'Wheat (Gehu)', 'गेहूं wheat (gehu) wheat', false),
    'white pumpkin': const _CropInfo('पेठा / सफेद कद्दू', 'White Ash Pumpkin (Petha)', 'पेठा / सफेद कद्दू white ash pumpkin (petha) white pumpkin', true),
    'wild cucumber': const _CropInfo('कचरी / जंगली ककड़ी', 'Wild Cucumber (Kachri)', 'कचरी / जंगली ककड़ी wild cucumber (kachri) wild cucumber', true),
    'wood': const _CropInfo('लकड़ी', 'Timber / Wood', 'लकड़ी timber / wood wood', false),
    'yam(ratalu)': const _CropInfo('रतालू', 'Purple Yam (Ratalu)', 'रतालू purple yam (ratalu) yam(ratalu)', true),
    'basil': const _CropInfo('तुलसी', 'Holy Basil (Tulsi)', 'तुलसी holy basil (tulsi) basil', false),
    'buttery': const _CropInfo('मक्खन फल', 'Avocado / Butter Fruit', 'मक्खन फल avocado / butter fruit buttery', true),
    'dried mango': const _CropInfo('अमचूर / सूखी खटाई', 'Dry Mango (Amchur)', 'अमचूर / सूखी खटाई dry mango (amchur) dried mango', true),
    'gulli': const _CropInfo('महुआ बीज (गुल्ली)', 'Mahua Seed (Gulli)', 'महुआ बीज (गुल्ली) mahua seed (gulli) gulli', false),
    'karanja seeds': const _CropInfo('करंज बीज', 'Karanja Seeds', 'करंज बीज karanja seeds karanja seeds', false),
    'nigella': const _CropInfo('कलौंजी', 'Nigella Seeds (Kalonji)', 'कलौंजी nigella seeds (kalonji) nigella', false),
    'nigella seeds': const _CropInfo('कलौंजी बीज', 'Nigella Seeds (Kalonji)', 'कलौंजी बीज nigella seeds (kalonji) nigella seeds', false),
    'poppy seeds': const _CropInfo('खसखस (पोस्ता दाना)', 'Poppy Seeds (Khaskhas)', 'खसखस (पोस्ता दाना) poppy seeds (khaskhas) poppy seeds', false),
    'sanay': const _CropInfo('सनाय पत्ती', 'Senna Leaves (Sanay)', 'सनाय पत्ती senna leaves (sanay) sanay', false),
  };

  /// Popular crop shortcuts for Crops / Grains category
  static const List<Map<String, String>> popularCrops = [
    {'name': 'गेहूं', 'key': 'wheat', 'icon': '🌾'},
    {'name': 'सरसों/रायड़ा', 'key': 'mustard', 'icon': '🟡'},
    {'name': 'चना', 'key': 'gram', 'icon': '🟤'},
    {'name': 'सोयाबीन', 'key': 'soyabean', 'icon': '🫘'},
    {'name': 'ग्वार बीज', 'key': 'guar', 'icon': '🌿'},
    {'name': 'कपास/नरमा', 'key': 'cotton', 'icon': '⚪'},
    {'name': 'मूंगफली', 'key': 'groundnut', 'icon': '🥜'},
    {'name': 'मूंग', 'key': 'moong', 'icon': '🟢'},
    {'name': 'जीरा', 'key': 'jeera', 'icon': '🌿'},
    {'name': 'इसबगोल', 'key': 'isabgul', 'icon': '🌾'},
    {'name': 'सौंफ', 'key': 'soanf', 'icon': '🌿'},
    {'name': 'बाजरा', 'key': 'bajra', 'icon': '🌾'},
    {'name': 'मक्का', 'key': 'maize', 'icon': '🌽'},
    {'name': 'धान (चावल)', 'key': 'paddy', 'icon': '🌾'},
    {'name': 'तिल', 'key': 'til', 'icon': '🌰'},
    {'name': 'मोठ', 'key': 'moth', 'icon': '🌾'},
    {'name': 'तारामीरा', 'key': 'taramira', 'icon': '🌱'},
    {'name': 'लहसुन', 'key': 'garlic', 'icon': '🧄'},
    {'name': 'धनिया', 'key': 'dhaniya', 'icon': '🌿'},
    {'name': 'मेथी', 'key': 'methi', 'icon': '🌿'},
    {'name': 'जौ', 'key': 'barley', 'icon': '🌾'},
  ];

  /// Popular shortcuts for Vegetables & Fruits category
  static const List<Map<String, String>> popularVegetables = [
    {'name': 'प्याज', 'key': 'onion', 'icon': '🧅'},
    {'name': 'आलू', 'key': 'potato', 'icon': '🥔'},
    {'name': 'टमाटर', 'key': 'tomato', 'icon': '🍅'},
    {'name': 'हरी मिर्च', 'key': 'green chilli', 'icon': '🌶️'},
    {'name': 'भिंडी', 'key': 'bhindi', 'icon': '🥒'},
    {'name': 'बैंगन', 'key': 'brinjal', 'icon': '🍆'},
    {'name': 'पत्ता गोभी', 'key': 'cabbage', 'icon': '🥬'},
    {'name': 'फूल गोभी', 'key': 'cauliflower', 'icon': '🥦'},
    {'name': 'लौकी', 'key': 'bottle gourd', 'icon': '🥒'},
    {'name': 'करेला', 'key': 'bitter gourd', 'icon': '🥒'},
    {'name': 'खीरा', 'key': 'kheera', 'icon': '🥒'},
    {'name': 'अदरक', 'key': 'ginger', 'icon': '🫚'},
    {'name': 'गाजर', 'key': 'carrot', 'icon': '🥕'},
    {'name': 'नींबू', 'key': 'lemon', 'icon': '🍋'},
    {'name': 'केला', 'key': 'banana', 'icon': '🍌'},
    {'name': 'अनार', 'key': 'pomegranate', 'icon': '🍎'},
    {'name': 'तरबूज', 'key': 'water melon', 'icon': '🍉'},
  ];

  /// Check if commodity is a Vegetable or Fruit
  static bool isVegetableOrFruit(String rawCommodity) {
    final clean = rawCommodity.trim().toLowerCase();

    // Direct safeguard for major field crops, grains, pulses, oilseeds & spices
    if (clean.contains('guar') ||
        clean.contains('gwar') ||
        clean.contains('taramira') ||
        clean.contains('mustard') ||
        clean.contains('wheat') ||
        clean.contains('gram') ||
        clean.contains('chana') ||
        clean.contains('bajra') ||
        clean.contains('maize') ||
        clean.contains('soyabean') ||
        clean.contains('cotton') ||
        clean.contains('paddy') ||
        clean.contains('rice') ||
        clean.contains('barley') ||
        clean.contains('jau') ||
        clean.contains('isabgol') ||
        clean.contains('isabgul') ||
        clean.contains('jeera') ||
        clean.contains('cumin') ||
        clean.contains('methi seeds') ||
        clean.contains('corriander seed') ||
        clean.contains('linseed') ||
        clean.contains('sesamum') ||
        clean.contains('til')) {
      return false;
    }

    if (_cropMap.containsKey(clean)) {
      return _cropMap[clean]!.isVegetable;
    }
    for (final entry in _cropMap.entries) {
      if (clean == entry.key || clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value.isVegetable;
      }
    }
    return clean.contains('vegetable') ||
        clean.contains('fruit') ||
        clean.contains('sabji') ||
        clean.contains('subzi');
  }

  /// Get Hindi name for raw API commodity name
  static String getHindiName(String rawCommodity) {
    final clean = rawCommodity.trim().toLowerCase();
    
    // 1. Direct O(1) exact map lookup
    if (_cropMap.containsKey(clean)) {
      return _cropMap[clean]!.hindiName;
    }

    // 2. Substring & keyword search
    for (final entry in _cropMap.entries) {
      if (clean == entry.key || clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value.hindiName;
      }
    }

    // 3. Fallback: return commodity name cleaned of extra technical codes
    return rawCommodity.replaceAll(RegExp(r'\(.*?\)'), '').trim();
  }

  /// Get English display name
  static String getEnglishName(String rawCommodity) {
    final clean = rawCommodity.trim().toLowerCase();
    if (_cropMap.containsKey(clean)) {
      return _cropMap[clean]!.englishName;
    }
    for (final entry in _cropMap.entries) {
      if (clean == entry.key || clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value.englishName;
      }
    }
    return rawCommodity;
  }

  /// Check if a commodity matches a search query (Hindi, Hinglish, or English)
  static bool matchesSearch(String rawCommodity, String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    final cleanComm = rawCommodity.trim().toLowerCase();
    
    // Check raw commodity name
    if (cleanComm.contains(cleanQuery)) return true;

    // Check mapped Hindi name, English name, and search keywords
    _CropInfo? info = _cropMap[cleanComm];
    if (info == null) {
      for (final entry in _cropMap.entries) {
        if (cleanComm.contains(entry.key) || entry.key.contains(cleanComm)) {
          info = entry.value;
          break;
        }
      }
    }

    if (info != null) {
      if (info.hindiName.toLowerCase().contains(cleanQuery)) return true;
      if (info.englishName.toLowerCase().contains(cleanQuery)) return true;
      if (info.searchKeywords.contains(cleanQuery)) return true;
    }

    return false;
  }

  /// Maps commodity to built-in crop ID if available for advisory & medicine section
  static String? getCropIdForCommodity(String rawCommodity) {
    final clean = rawCommodity.toLowerCase().trim();
    if (clean.contains('wheat') || clean.contains('gehu')) return 'wheat';
    if (clean.contains('mustard') || clean.contains('rape') || clean.contains('sarson')) return 'mustard';
    if (clean.contains('rice') || clean.contains('paddy') || clean.contains('dhan')) return 'rice';
    if (clean.contains('sugarcane') || clean.contains('ganna')) return 'sugarcane';
    if (clean.contains('cotton') || clean.contains('kapas')) return 'cotton';
    if (clean.contains('moong') || clean.contains('green gram')) return 'moong';
    if (clean.contains('chana') || clean.contains('bengal gram')) return 'chana';
    if (clean.contains('guar') || clean.contains('gawar')) return 'guar';
    if (clean.contains('tomato') || clean.contains('tamatar')) return 'tomato';
    if (clean.contains('chilli') || clean.contains('mirch')) return 'chilli';
    if (clean.contains('garlic') || clean.contains('lahsun')) return 'garlic';
    if (clean.contains('onion') || clean.contains('pyaj')) return 'onion';
    if (clean.contains('potato') || clean.contains('aloo')) return 'potato';
    return null;
  }

  /// Get emoji for commodity
  static String getEmoji(String rawCommodity) {
    final clean = rawCommodity.toLowerCase();
    for (final c in popularCrops) {
      if (clean.contains(c['key']!)) return c['icon']!;
    }
    for (final v in popularVegetables) {
      if (clean.contains(v['key']!)) return v['icon']!;
    }
    if (isVegetableOrFruit(rawCommodity)) return '🥬';
    return '🌾';
  }
}

class _CropInfo {
  final String hindiName;
  final String englishName;
  final String searchKeywords;
  final bool isVegetable;

  const _CropInfo(this.hindiName, this.englishName, this.searchKeywords, this.isVegetable);
}
