import '../models/consult_models.dart';

final myPets = <Pet>[
  const Pet(
    name: 'Moji',
    breed: 'Shiba Inu',
    species: 'Dog',
    ageMonths: 28,
    weightKg: 12.4,
    sex: 'male',
    neutered: true,
    avatarSeed: 'moji',
  ),
  const Pet(
    name: 'Luna',
    breed: 'British Shorthair',
    species: 'Cat',
    ageMonths: 14,
    weightKg: 4.2,
    sex: 'female',
    neutered: true,
    avatarSeed: 'luna',
  ),
  const Pet(
    name: 'Coco',
    breed: 'Holland Lop',
    species: 'Rabbit',
    ageMonths: 9,
    weightKg: 1.8,
    sex: 'female',
    avatarSeed: 'coco',
  ),
];

final ownerWaew = const Author(
  name: 'Waew P.',
  avatarSeed: 'waew',
  role: AuthorRole.owner,
);
final ownerNick = const Author(
  name: 'Nick T.',
  avatarSeed: 'nick',
  role: AuthorRole.owner,
);
final ownerMint = const Author(
  name: 'Mint S.',
  avatarSeed: 'mint',
  role: AuthorRole.owner,
);

final vetSomchai = const Author(
  name: 'Dr. Somchai R.',
  clinic: 'Arak Animal Hospital',
  avatarSeed: 'somchai',
  role: AuthorRole.vet,
  specialty: 'Internal Medicine',
  treatsSpecies: ['Dog', 'Cat'],
  verified: true,
);
final vetPloy = const Author(
  name: 'Dr. Ploy K.',
  clinic: 'PetWell Clinic',
  avatarSeed: 'ploy',
  role: AuthorRole.vet,
  specialty: 'Dermatology',
  treatsSpecies: ['Dog', 'Cat', 'Rabbit'],
  verified: true,
);
final vetMana = const Author(
  name: 'Dr. Mana V.',
  clinic: 'Bangkok Vet Center',
  avatarSeed: 'mana',
  role: AuthorRole.vet,
  specialty: 'Nutrition',
  treatsSpecies: ['Dog', 'Cat', 'Bird', 'Reptile'],
  verified: true,
);

final brandRoyalCanin = const Author(
  name: 'Royal Canin Thailand',
  avatarSeed: 'royalcanin',
  role: AuthorRole.brand,
  verified: true,
);

final mockQuestions = <Question>[
  Question(
    id: 'q1',
    title: 'โมจิอ้วก 3 ครั้งตั้งแต่เช้า ปกติไหมคะ?',
    body:
        'เช้านี้ตื่นมาเจอโมจิอ้วกบนพรม สีออกเหลืองๆ ปนอาหารเก่า อ้วกอีก 2 ครั้งระหว่างวัน ยังกินน้ำได้ปกติ แต่ไม่ค่อยอยากกินข้าว ควรพาไปหาหมอเลยไหมคะ?',
    category: ConsultCategory.health,
    author: ownerWaew,
    pet: myPets[0],
    photos: const [
      'https://images.unsplash.com/photo-1507146426996-ef05306b995a?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&q=80',
    ],
    upvotes: 12,
    isUrgent: true,
    postedAt: DateTime.now().subtract(const Duration(hours: 2)),
    answers: [
      Answer(
        id: 'a1',
        author: vetSomchai,
        body:
            'อ้วก 3 ครั้งใน 1 วันถือว่าควรเฝ้าระวังครับ แนะนำให้ทำดังนี้:\n\n1. งดอาหาร 12 ชม. แต่ให้น้ำได้\n2. สังเกตว่ามีอาการซึม ท้องเสีย หรือไข้ร่วมด้วยไหม\n3. ถ้ายังอ้วกอีกหลังงดอาหาร หรือมีเลือดปน ให้พามาคลินิกทันที\n\nสีอ้วกเหลืองอาจเป็นน้ำดี แสดงว่าท้องว่างนานเกินไป ลองให้อาหารอ่อนปริมาณน้อยทุก 4 ชม. หลังครบ 12 ชม.ครับ',
        upvotes: 28,
        accepted: true,
        suggestsClinicVisit: false,
        postedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Answer(
        id: 'a2',
        author: vetPloy,
        body:
            'เห็นด้วยกับ Dr. Somchai ครับ เพิ่มเติมว่าถ้าโมจิอายุน้อยกว่า 6 เดือน หรือมีโรคประจำตัว ควรพามาตรวจเร็วขึ้น เพราะเสี่ยงขาดน้ำเร็วครับ',
        upvotes: 9,
        accepted: false,
        postedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ],
  ),
  Question(
    id: 'q2',
    title: 'แมวเริ่มเลียขนตัวเองเยอะมาก จนขนร่วงเป็นหย่อม',
    body:
        'Luna อายุ 1 ขวบ 2 เดือน ช่วง 2 สัปดาห์ที่ผ่านมาเริ่มเลียบริเวณท้องและขาหลังเยอะมาก จนขนเริ่มบาง เห็นผิวหนังแล้ว ไม่มีรอยแดงหรือผื่น เปลี่ยนอาหารหรือสภาพแวดล้อมไหม?',
    category: ConsultCategory.behavior,
    author: ownerMint,
    pet: myPets[1],
    photos: const [
      'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?auto=format&fit=crop&w=400&q=80',
    ],
    upvotes: 7,
    postedAt: DateTime.now().subtract(const Duration(hours: 8)),
    answers: [
      Answer(
        id: 'a3',
        author: vetPloy,
        body:
            'อาการเลียขนมากเกินไป (over-grooming) ในแมวเกิดได้จากหลายสาเหตุครับ:\n\n• ความเครียด/วิตกกังวล\n• แพ้อาหารหรือสิ่งแวดล้อม\n• ปรสิตภายนอก (เห็บ หมัด ไร)\n• ปัญหาผิวหนัง\n\nแนะนำให้พามาตรวจผิวหนังและขูดผิวเพื่อหาปรสิตครับ ระหว่างนี้ลองสังเกตว่ามีการเปลี่ยนแปลงอะไรในบ้านไหม เช่น คนใหม่ สัตว์ใหม่ เฟอร์นิเจอร์',
        upvotes: 14,
        accepted: false,
        suggestsClinicVisit: true,
        postedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ],
  ),
  Question(
    id: 'q3',
    title: 'ควรให้อาหารเม็ดยี่ห้อไหนดีกับลูกหมา 4 เดือน?',
    body:
        'เพิ่งรับลูกโกลเด้นมาเลี้ยง อายุ 4 เดือน ตอนนี้กินอาหารยี่ห้อเดิมจากผู้ขาย แต่อยากเปลี่ยนมาให้แบบที่มีคุณภาพดีกว่า งบประมาณ 1,500-2,500/เดือน ควรเลือกแบบไหนดี?',
    category: ConsultCategory.nutrition,
    author: ownerNick,
    photos: const [],
    upvotes: 22,
    postedAt: DateTime.now().subtract(const Duration(days: 1)),
    answers: [
      Answer(
        id: 'a4',
        author: vetMana,
        body:
            'สำหรับลูกโกลเด้น 4 เดือน ผมแนะนำให้เลือกอาหารที่:\n\n1. มี AAFCO certification สำหรับ Large Breed Puppy\n2. โปรตีนคุณภาพสูง 26-30%\n3. แคลเซียม:ฟอสฟอรัส 1.2:1\n4. มี DHA สำหรับพัฒนาสมอง\n\nในงบนี้มีตัวเลือกดีๆหลายยี่ห้อครับ',
        upvotes: 18,
        accepted: false,
        postedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      Answer(
        id: 'a5',
        author: brandRoyalCanin,
        body:
            'Royal Canin Maxi Puppy ออกแบบมาเฉพาะลูกสุนัขพันธุ์ใหญ่ อายุ 2-15 เดือน ให้สารอาหารครบถ้วนรองรับการเจริญเติบโตอย่างเหมาะสม พร้อมระบบป้องกันการย่อยอาหารที่อ่อนแอ',
        upvotes: 5,
        accepted: false,
        isBrandSponsored: true,
        brandCta: 'Shop Royal Canin Maxi Puppy',
        postedAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ],
  ),
  Question(
    id: 'q4',
    title: 'กระต่ายฟันยาวผิดปกติ ตัดเองได้ไหม?',
    body: 'Coco อายุ 9 เดือน สังเกตว่าฟันหน้าด้านล่างเริ่มยาวเกินจนเกยกับริมฝีปาก กินอาหารเม็ดได้ปกติ แต่กินผักลำบาก',
    category: ConsultCategory.health,
    author: ownerWaew,
    pet: myPets[2],
    upvotes: 4,
    postedAt: DateTime.now().subtract(const Duration(days: 2)),
    answers: const [],
  ),
  Question(
    id: 'q5',
    title: 'อาบน้ำหมาบ่อยแค่ไหนถึงจะดี?',
    body: 'อยู่คอนโด หมาไม่ค่อยได้ออกข้างนอก ตอนนี้อาบน้ำสัปดาห์ละครั้ง มากไปไหม?',
    category: ConsultCategory.grooming,
    author: ownerNick,
    upvotes: 16,
    postedAt: DateTime.now().subtract(const Duration(days: 3)),
    answers: [
      Answer(
        id: 'a6',
        author: vetPloy,
        body: 'สัปดาห์ละครั้งมากเกินไปครับสำหรับสุนัขทั่วไป แนะนำ 2-4 สัปดาห์/ครั้ง ขึ้นกับสายพันธุ์และสภาพผิวหนัง',
        upvotes: 22,
        accepted: true,
        postedAt: DateTime.now().subtract(const Duration(days: 2, hours: 22)),
      ),
    ],
  ),
];

final List<ActivityEntry> myActivities = <ActivityEntry>[
  ActivityEntry(
    type: ActivityType.privateConsult,
    title: 'Private Consult · Dr. Somchai R.',
    subtitle: '30 นาที · สำเร็จ',
    amount: '฿500',
    relatedAvatarSeed: 'somchai',
    at: DateTime.now().subtract(const Duration(days: 5)),
  ),
  ActivityEntry(
    type: ActivityType.shopPurchased,
    title: 'Royal Canin Maxi Puppy 3 kg',
    subtitle: 'จำนวน 2 · จัดส่งแล้ว',
    amount: '฿2,580',
    relatedAvatarSeed: 'royalcanin',
    at: DateTime.now().subtract(const Duration(days: 12)),
  ),
];

void logActivity(ActivityEntry entry) {
  myActivities.insert(0, entry);
}

Author currentUser = ownerWaew;
List<Pet> get currentUserPets => myPets;

final allAuthors = <Author>[
  ownerWaew,
  ownerNick,
  ownerMint,
  vetSomchai,
  vetPloy,
  vetMana,
  brandRoyalCanin,
];

Author? authorBySeed(String seed) {
  for (final a in allAuthors) {
    if (a.avatarSeed == seed) return a;
  }
  return null;
}

List<Question> questionsByAuthor(String seed) =>
    mockQuestions.where((q) => q.author.avatarSeed == seed).toList();

List<Answer> answersByAuthor(String seed) => mockQuestions
    .expand((q) => q.answers)
    .where((a) => a.author.avatarSeed == seed)
    .toList();

int acceptedAnswersByAuthor(String seed) =>
    answersByAuthor(seed).where((a) => a.accepted).length;

int followerCountFor(String seed) {
  final base = seed.codeUnits.fold<int>(0, (a, b) => a + b);
  return 120 + (base % 480);
}

double vetRatingFor(String seed) {
  final base = seed.codeUnits.fold<int>(0, (a, b) => a + b);
  return 4.4 + ((base % 6) * 0.1);
}

const List<String> speciesMasterData = ['Dog', 'Cat', 'Rabbit', 'Bird', 'Fish', 'Reptile', 'Other'];

const Map<String, List<String>> breedsBySpecies = {
  'Dog': [
    'Shiba Inu',
    'Golden Retriever',
    'Labrador Retriever',
    'Poodle',
    'French Bulldog',
    'Beagle',
    'Pomeranian',
    'Chihuahua',
    'Siberian Husky',
    'Corgi',
    'Shih Tzu',
    'Mixed breed',
    'Other',
  ],
  'Cat': [
    'British Shorthair',
    'Persian',
    'Siamese',
    'Ragdoll',
    'Scottish Fold',
    'Maine Coon',
    'Bengal',
    'Abyssinian',
    'Sphynx',
    'Domestic Shorthair',
    'Other',
  ],
  'Rabbit': [
    'Holland Lop',
    'Netherland Dwarf',
    'Rex',
    'Lionhead',
    'Mini Rex',
    'Flemish Giant',
    'Other',
  ],
  'Bird': [
    'Budgerigar',
    'Cockatiel',
    'Lovebird',
    'Macaw',
    'Parrot (Grey)',
    'Canary',
    'Other',
  ],
  'Fish': [
    'Betta',
    'Goldfish',
    'Guppy',
    'Koi',
    'Arowana',
    'Other',
  ],
  'Reptile': [
    'Leopard Gecko',
    'Ball Python',
    'Bearded Dragon',
    'Corn Snake',
    'Red-eared Slider',
    'Other',
  ],
  'Other': ['Other'],
};

final List<HealthLogEntry> healthLogs = [
  HealthLogEntry(
    type: HealthLogType.weight,
    petSeed: 'moji',
    title: '12.4 kg',
    note: 'ลดลง 0.2 kg จากครั้งก่อน กินอาหารน้อยลง',
    loggedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  HealthLogEntry(
    type: HealthLogType.vaccine,
    petSeed: 'moji',
    title: 'วัคซีนรวม 5 โรค',
    note: 'ครบกำหนดฉีดครั้งถัดไป: อีก 12 เดือน',
    loggedAt: DateTime.now().subtract(const Duration(days: 45)),
  ),
  HealthLogEntry(
    type: HealthLogType.grooming,
    petSeed: 'moji',
    title: 'ตัดขน + อาบน้ำ',
    note: 'ที่ร้าน Puppy Parlour',
    loggedAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  HealthLogEntry(
    type: HealthLogType.checkup,
    petSeed: 'moji',
    title: 'ตรวจสุขภาพประจำปี',
    note: 'ผลเลือดและหัวใจปกติ',
    loggedAt: DateTime.now().subtract(const Duration(days: 60)),
  ),
  HealthLogEntry(
    type: HealthLogType.weight,
    petSeed: 'luna',
    title: '4.2 kg',
    loggedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  HealthLogEntry(
    type: HealthLogType.vaccine,
    petSeed: 'luna',
    title: 'วัคซีน FVRCP',
    loggedAt: DateTime.now().subtract(const Duration(days: 90)),
  ),
  HealthLogEntry(
    type: HealthLogType.weight,
    petSeed: 'coco',
    title: '1.8 kg',
    note: 'น้ำหนักอยู่ในเกณฑ์ปกติ',
    loggedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

List<HealthLogEntry> healthLogsFor(String petSeed) =>
    healthLogs.where((e) => e.petSeed == petSeed).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
