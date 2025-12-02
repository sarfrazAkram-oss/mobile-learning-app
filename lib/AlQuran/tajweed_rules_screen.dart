import 'package:flutter/material.dart';

class TajweedRulesScreen extends StatelessWidget {
  const TajweedRulesScreen({Key? key}) : super(key: key);

  static final List<Map<String, String>> _rules = [
    {
      'title': 'Introduction',
      'short': 'What is Tajweed?',
      'detail':
          'Tajweed is the set of rules governing pronunciation during the recitation of the Qur\'an. It ensures correct articulation, proper timing (madd), clear pronunciation (idh-haar), assimilation (idghaam), and observance of nasalization (ghunnah), among other rules. The aim is to recite the Qur\'an as it was revealed and taught by the Prophet (peace be upon him).',
    },
    {
      'title': 'Makharij (Points of Articulation)',
      'short': 'Where letters are produced',
      'detail':
          'Makharij refers to the place from which each Arabic letter emanates (e.g., the throat, tongue, lips). Correct tajweed begins with correct makhraj so that letters are distinct and do not merge incorrectly.',
    },
    {
      'title': 'Sifaat (Characteristics of Letters)',
      'short': 'Qualities like heaviness, softness',
      'detail':
          'Sifaat are inherent qualities of letters such as shiddah (strength), rakhawah (softness), hams (aspiration), qalqalah (echo), and tafkhim (emphasis). Recognising these qualities helps in correct pronunciation.',
    },
    {
      'title': 'Madd (Prolongation)',
      'short': 'Extending vowel sounds',
      'detail':
          'Madd is the elongation of a vowel for a specific number of counts (harakaat). Types of madd include:\n- Madd Tabee\'i (natural madd): length of 1 vowel (approx. 2 counts in some recitations).\n- Madd Munfasil and Madd Muttasil (connected/separated madd): varies between 2 to 6 counts depending on rules and presence of hamzah.\n- Madd Laazim: obligatory madd in certain contexts (usually 6 counts), e.g., madd followed by a hamzah in specific cases.\nProper application of madd is crucial for correct recitation.',
    },
    {
      'title': 'Ghunna (Nasalization)',
      'short': 'Nasal sound on Noon and Meem',
      'detail':
          'Ghunna is a nasal sound produced on letters Noon (ن) and Meem (م) when they carry a shadda (ّ) or in certain contexts (e.g., idghaam with ghunnah). It is typically held for two counts. Examples: the doubled Noon or Meem.',
    },
    {
      'title': 'Noon Sakinah & Tanween Rules',
      'short': 'Izhar, Idghaam, Iqlab, Ikhfa',
      'detail':
          'When Noon is sakin (نْ) or followed by tanween, there are four outcomes depending on the following letter:\n- Izhar (clarity): pronounce the noon clearly when followed by throat letters (أ, هـ, ع, ح, غ, خ).\n- Idghaam (assimilation): merge the noon into the following letter when followed by certain letters; some idghaam require ghunnah (nasalization) and some do not.\n- Iqlab (conversion): change the noon sound to a meem-like sound before the letter ب (with ghunnah).\n- Ikhfa (concealment): hide the noon sound, producing a nasalized sound between clarity and merging (applies before other letters not in the previous groups).',
    },
    {
      'title': 'Meem Sakinah Rules',
      'short': 'Idghaam Shafawi, Iqlab, Izhar',
      'detail':
          'Meem Sakinah (مْ) has special rules when followed by other letters:\n- Idghaam Shafawi: when meem is followed by meem, the two meems are merged and pronounced with ghunnah.\n- Ikhfa Shafawi: when meem is followed by the letter ب, the sound is hidden slightly with nasalization (context specific).\n- Izhar (clarity): when meem is followed by letters other than those causing idghaam/ikhfa, it is pronounced clearly.',
    },
    {
      'title': 'Idghaam (Assimilation)',
      'short': 'Merging letters',
      'detail':
          'Idghaam occurs when a letter is assimilated into the following letter so that the first is not pronounced separately. There are categories such as idghaam with ghunnah (nasalization) and idghaam without ghunnah. Recognize the specific letters that cause idghaam to apply the correct pronunciation.',
    },
    {
      'title': 'Ikhfa (Concealment)',
      'short': 'Partial hiding of sound',
      'detail':
          'Ikhfa takes place when noon sakin or tanween is followed by certain letters; the noon is not pronounced clearly nor fully merged — it is concealed producing a nasalized sound. The exact degree of concealment is taught by tajweed instructors and practiced by ear.',
    },
    {
      'title': 'Iqlab (Conversion)',
      'short': 'Convert noon to meem before ب',
      'detail':
          'Iqlab applies when noon sakin or tanween is followed by the letter ب. The noon sound is converted to a meem-like sound with ghunnah (nasalization for two counts).',
    },
    {
      'title': 'Izhar (Clarity)',
      'short': 'Clear pronunciation',
      'detail':
          'Izhar requires pronouncing the noon confidently and clearly when followed by throat letters. There is no nasalization in izhar.',
    },
    {
      'title': 'Qalqalah (Echoing)',
      'short': 'Bouncing sound on certain letters',
      'detail':
          'Qalqalah is a slight echoing sound produced on the letters ق ط ب ج د when they are in a state of sukun (or at the end of a word). The sound is crisp and resembles a light bounce or reverberation. Recognize these letters and apply qalqalah when appropriate.',
    },
    {
      'title': 'Tafkhim and Tarqiq (Emphasis and Lightness)',
      'short': 'Heavy vs light letters',
      'detail':
          'Some letters are pronounced with emphasis (tafkhim) — they sound heavier — while others are pronounced lightly (tarqiq). The classic example is the letter ر which may be heavy or light depending on surrounding vowels and contexts. Learning tafkhim/tarqiq distinctions is important for correct recitation.',
    },
    {
      'title': 'Hamzatul Wasl and Hamzatul Qat\'',
      'short': 'Connecting and separating hamzah',
      'detail':
          'Hamzatul Wasl (the connecting hamzah) is pronounced only when beginning from that word; when joining words in speech it is often dropped. Hamzatul Qat\' is pronounced wherever it occurs and must be articulated clearly. Recognize their symbols and apply them correctly in recitation and joining words.',
    },
    {
      'title': 'Waqf (Stopping Rules)',
      'short': 'How and where to stop',
      'detail':
          'Waqf rules (stop marks) guide where to pause or continue in recitation. Stopping at different places can change meaning; some stops require completing the word or pausing then continuing without changing the ending. Study the Qur\'anic stop marks and practise proper waqf to preserve meaning and grammar.',
    },
    {
      'title': 'Practical Advice',
      'short': 'Practice and listen',
      'detail':
          'Tajweed is best learned through a qualified teacher and by listening to proficient reciters. Practice regularly, record your recitation, and compare. Use the rules above as a study reference but prioritise guided, practical training for mastery.',
    },
  ];

  // Color mapping used in the Tajweed reader. These are the colors applied
  // to examples of each tajweed rule in the reader.
  static const Map<String, Color> ruleColors = {
    'madd': Colors.amber,
    'ghunna': Colors.red,
    'idghaam': Colors.orange,
    'izhar': Colors.green,
    'iqlab': Colors.purple,
    'ikhfa': Colors.teal,
    'qalqalah': Colors.blue,
    'shadda': Colors.deepPurple,
    'sukun': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tajweed Rules')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _rules.length,
        itemBuilder: (context, index) {
          final r = _rules[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color:
                          ruleColors[(r['title'] ?? '').toLowerCase()] ??
                          Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  Expanded(child: Text(r['title'] ?? '')),
                ],
              ),
              subtitle: Text(r['short'] ?? ''),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(r['detail'] ?? ''),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
