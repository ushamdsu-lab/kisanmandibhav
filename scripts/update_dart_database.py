import json
import re

with open('assets/data/crop_diseases.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

diseases = data.get('diseases', [])
print(f"Generating Dart code for {len(diseases)} diseases...")

def escape_dart_str(s):
    if s is None:
        return "''"
    # Escape $ and \ and '
    escaped = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{escaped}'"

dart_entries = []
for d in diseases:
    symptoms_list = ",\n        ".join([escape_dart_str(s) for s in d.get('symptoms', [])])
    tags_list = ", ".join([escape_dart_str(t) for t in d.get('symptomTags', [])])
    tips_list = ",\n        ".join([escape_dart_str(t) for t in d.get('preventionTips', [])])

    entry = f"""    CropDisease(
      id: {escape_dart_str(d.get('id', ''))},
      cropId: {escape_dart_str(d.get('cropId', ''))},
      cropName: {escape_dart_str(d.get('cropName', ''))},
      cropHindi: {escape_dart_str(d.get('cropHindi', ''))},
      diseaseNameHindi: {escape_dart_str(d.get('diseaseNameHindi', ''))},
      diseaseNameEnglish: {escape_dart_str(d.get('diseaseNameEnglish', ''))},
      pathogen: {escape_dart_str(d.get('pathogen', ''))},
      severity: {escape_dart_str(d.get('severity', 'मध्यम'))},
      confidenceScore: {float(d.get('confidenceScore', 94.5))},
      symptoms: [
        {symptoms_list}
      ],
      symptomTags: [{tags_list}],
      organicRemedy: {escape_dart_str(d.get('organicRemedy', ''))},
      chemicalMedicine: {escape_dart_str(d.get('chemicalMedicine', ''))},
      sprayDosage: {escape_dart_str(d.get('sprayDosage', ''))},
      precautions: {escape_dart_str(d.get('precautions', ''))},
      preventionTips: [
        {tips_list}
      ],
      icon: {escape_dart_str(d.get('icon', '🌿'))},
    ),"""
    dart_entries.append(entry)

all_dart_entries = "\n".join(dart_entries)

# Read current file to get headers and helper methods
with open('lib/data/crop_disease_database.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Match from start of file up to `static const List<CropDisease> defaultDiseases = [`
prefix_match = re.search(r'^(.*?static const List<CropDisease> defaultDiseases = \[)', content, re.DOTALL)
if not prefix_match:
    print("Could not find defaultDiseases opening")
    exit(1)
prefix = prefix_match.group(1)

# Match from helper methods to end:
# Look for `static List<CropDisease> getDiseasesByCrop`
suffix_match = re.search(r'(\s*/// Get all diseases for a crop\s*static List<CropDisease> getDiseasesByCrop.*)$', content, re.DOTALL)
if not suffix_match:
    # Try finding `static List<CropDisease> getDiseasesByCrop` without doc comment
    suffix_match = re.search(r'(\s*static List<CropDisease> getDiseasesByCrop.*)$', content, re.DOTALL)

if not suffix_match:
    print("Could not find getDiseasesByCrop suffix")
    exit(1)

suffix = suffix_match.group(1)

normalize_crop_func = """  /// Normalize regional crop names to canonical IDs
  static String normalizeCropId(String cropId) {
    final c = cropId.toLowerCase().trim();
    if (c.contains('wheat') || c.contains('gehu') || c.contains('गेहूं') || c.contains('गेहू')) return 'wheat';
    if (c.contains('paddy') || c.contains('rice') || c.contains('dhan') || c.contains('chawal') || c.contains('धान') || c.contains('चावल')) return 'paddy';
    if (c.contains('mustard') || c.contains('sarson') || c.contains('sarso') || c.contains('राई') || c.contains('सरसों')) return 'mustard';
    if (c.contains('cotton') || c.contains('kapas') || c.contains('narma') || c.contains('कपास') || c.contains('नरमा')) return 'cotton';
    if (c.contains('soybean') || c.contains('सोयाबीन')) return 'soybean';
    if (c.contains('gram') || c.contains('chana') || c.contains('चना')) return 'gram';
    if (c.contains('tomato') || c.contains('tamatar') || c.contains('टमाटर')) return 'tomato';
    if (c.contains('potato') || c.contains('aloo') || c.contains('alu') || c.contains('आलू')) return 'potato';
    if (c.contains('chilli') || c.contains('chili') || c.contains('mirch') || c.contains('मिर्च')) return 'chilli';
    if (c.contains('onion') || c.contains('pyaj') || c.contains('pyaaj') || c.contains('प्याज')) return 'onion';
    if (c.contains('garlic') || c.contains('lahsun') || c.contains('लहसुन')) return 'garlic';
    if (c.contains('groundnut') || c.contains('mungfali') || c.contains('मूंगफली')) return 'groundnut';
    if (c.contains('maize') || c.contains('makka') || c.contains('मक्का')) return 'maize';
    if (c.contains('bajra') || c.contains('बाजरा')) return 'bajra';
    if (c.contains('moong') || c.contains('mung') || c.contains('मूंग')) return 'moong';
    if (c.contains('urad') || c.contains('उड़द')) return 'urad';
    if (c.contains('arhar') || c.contains('tur') || c.contains('अरहर') || c.contains('तुअर')) return 'arhar';
    if (c.contains('cauliflower') || c.contains('gobhi') || c.contains('gobi') || c.contains('गोभी')) return 'cauliflower';
    if (c.contains('brinjal') || c.contains('baingan') || c.contains('बैंगन')) return 'brinjal';
    if (c.contains('okra') || c.contains('bhindi') || c.contains('भिंडी')) return 'okra';
    if (c.contains('pea') || c.contains('matar') || c.contains('मटर')) return 'pea';
    if (c.contains('jeera') || c.contains('cumin') || c.contains('जीरा')) return 'jeera';
    if (c.contains('coriander') || c.contains('dhaniya') || c.contains('धनिया')) return 'coriander';
    if (c.contains('fennel') || c.contains('saunf') || c.contains('सौंफ')) return 'fennel';
    if (c.contains('fenugreek') || c.contains('methi') || c.contains('मेथी')) return 'fenugreek';
    if (c.contains('ginger') || c.contains('adrak') || c.contains('अदरक')) return 'ginger';
    if (c.contains('turmeric') || c.contains('haldi') || c.contains('हल्दी')) return 'turmeric';
    if (c.contains('sugarcane') || c.contains('ganna') || c.contains('गन्ना')) return 'sugarcane';
    if (c.contains('guar') || c.contains('ग्वार')) return 'guar';
    if (c.contains('isabgol') || c.contains('इसबगोल')) return 'isabgol';
    if (c.contains('pomegranate') || c.contains('anar') || c.contains('अनार')) return 'pomegranate';
    if (c.contains('citrus') || c.contains('nimbu') || c.contains('santra') || c.contains('संतरा') || c.contains('नींबू')) return 'citrus';
    if (c.contains('mango') || c.contains('aam') || c.contains('आम')) return 'mango';
    if (c.contains('guava') || c.contains('amrood') || c.contains('अमरूद')) return 'guava';
    if (c.contains('papaya') || c.contains('papita') || c.contains('पपीता')) return 'papaya';
    if (c.contains('watermelon') || c.contains('tarbooj') || c.contains('तरबूज') || c.contains('kharbooza') || c.contains('खरबूजा')) return 'watermelon';
    if (c.contains('castor') || c.contains('arandi') || c.contains('अरंडी')) return 'castor';
    if (c.contains('sunflower') || c.contains('surajmukhi') || c.contains('सूरजमुखी')) return 'sunflower';
    if (c.contains('sesame') || c.contains('til') || c.contains('तिल')) return 'sesame';
    if (c.contains('banana') || c.contains('kela') || c.contains('केला')) return 'banana';
    if (c.contains('apple') || c.contains('seb') || c.contains('सेब')) return 'apple';
    if (c.contains('grapes') || c.contains('angoor') || c.contains('अंगूर')) return 'grapes';
    if (c.contains('carrot') || c.contains('gajar') || c.contains('गाजर')) return 'carrot';
    if (c.contains('radish') || c.contains('mooli') || c.contains('मूली')) return 'radish';
    if (c.contains('spinach') || c.contains('palak') || c.contains('पालक')) return 'spinach';
    if (c.contains('capsicum') || c.contains('shimla') || c.contains('शिमला मिर्च')) return 'capsicum';
    if (c.contains('bottle_gourd') || c.contains('lauki') || c.contains('ghiya') || c.contains('लौकी')) return 'bottle_gourd';
    if (c.contains('bitter_gourd') || c.contains('karela') || c.contains('करेला')) return 'bitter_gourd';
    if (c.contains('cholai') || c.contains('chaulai') || c.contains('chawli') || c.contains('lobia') || c.contains('chawla') || c.contains('चौलाई') || c.contains('चंवला') || c.contains('लोबिया')) return 'chaulai';
    return c;
  }
"""

new_content = f"""{prefix}
{all_dart_entries}
  ];

{normalize_crop_func}
{suffix.lstrip()}"""

with open('lib/data/crop_disease_database.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Successfully updated lib/data/crop_disease_database.dart with all diseases!")
