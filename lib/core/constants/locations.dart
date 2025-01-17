import 'package:e_travel/features/locations/models/location_model.dart';

final List<Location> locations = [
  // Popular Locations
  Location(
    name: 'Taj Mahal',
    description:
        'A UNESCO World Heritage Site and one of the seven wonders of the world in Agra, India.',
    category: 'Popular',
    imageUrl:
        'https://images.unsplash.com/photo-1732639840730-a3cdf066a9e6?q=80&w=1631&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    latitude: 27.1751,
    longitude: 78.0421,
    address:
        'Dharmapuri, Forest Colony, Tajganj, Agra, Uttar Pradesh 282001, India',
    rating: 4.9,
    type: 'Monument',
    bestTimeToVisit: 'October to March',
  ),
  Location(
    name: 'Great Wall of China',
    description:
        'One of the most iconic structures in the world, spanning thousands of miles.',
    category: 'Popular',
    imageUrl:
        'https://images.unsplash.com/photo-1558981012-236ee58eb5c9?q=80&w=1384&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    latitude: 40.4319,
    longitude: 116.5704,
    address: 'Huanghua Cheng, Beijing, China',
    rating: 4.8,
    type: 'Historical Landmark',
    bestTimeToVisit: 'April to October',
  ),
  Location(
    name: 'Burj Khalifa',
    description: 'The tallest skyscraper in the world, located in Dubai, UAE.',
    category: 'Popular',
    imageUrl:
        'https://images.unsplash.com/photo-1509821361533-422c91a204f0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8QnVyaiUyMEtoYWxpZmF8ZW58MHx8MHx8fDA%3D',
    latitude: 25.1972,
    longitude: 55.2744,
    address: '1 Sheikh Mohammed bin Rashid Blvd - Dubai - United Arab Emirates',
    rating: 4.7,
    type: 'Skyscraper',
    bestTimeToVisit: 'November to February',
  ),
  Location(
    name: 'Petra',
    description:
        'An archaeological site famous for its rock-cut architecture in Jordan.',
    category: 'Popular',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1724754604549-f48d1caab92a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8UGV0cmF8ZW58MHx8MHx8fDA%3D',
    latitude: 30.3285,
    longitude: 35.4444,
    address: "Petra, Ma'an Governorate, Jordan",
    rating: 4.9,
    type: 'Archaeological Site',
    bestTimeToVisit: 'March to May and September to November',
  ),

  // Summer Locations
  Location(
    name: 'Maldives',
    description:
        'A tropical paradise known for its beaches, coral reefs, and luxury resorts.',
    category: 'Summer',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1666286163385-abe05f0326c4?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8TWFsZGl2ZXN8ZW58MHx8MHx8fDA%3D',
    latitude: 3.2028,
    longitude: 73.2207,
    address: 'Maldives',
    rating: 4.8,
    type: 'Island',
    bestTimeToVisit: 'December to April',
  ),
  Location(
    name: 'Bali',
    description:
        'A popular tourist destination in Indonesia known for its forested volcanic mountains.',
    category: 'Summer',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1677829177642-30def98b0963?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8QmFsaXxlbnwwfHwwfHx8MA%3D%3D',
    latitude: -8.3405,
    longitude: 115.0919,
    address: 'Bali, Indonesia',
    rating: 4.7,
    type: 'Island',
    bestTimeToVisit: 'April to October',
  ),
  Location(
    name: 'Phuket',
    description:
        'A tropical island in Thailand known for its stunning beaches and nightlife.',
    category: 'Summer',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1661881114924-536307040c49?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8UGh1a2V0fGVufDB8fDB8fHww',
    latitude: 7.8804,
    longitude: 98.3923,
    address: 'Phuket, Thailand',
    rating: 4.6,
    type: 'Island',
    bestTimeToVisit: 'November to February',
  ),
  Location(
    name: 'Boracay',
    description:
        'A small island in the Philippines known for its white sand beaches.',
    category: 'Summer',
    imageUrl:
        'https://images.unsplash.com/photo-1462557522227-30b31bfb0db9?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Qm9yYWNheXxlbnwwfHwwfHx8MA%3D%3D',
    latitude: 11.9674,
    longitude: 121.9244,
    address: 'Boracay, Aklan, Philippines',
    rating: 4.8,
    type: 'Island',
    bestTimeToVisit: 'November to April',
  ),

  // Winter Locations
  Location(
    name: 'Mount Fuji',
    description:
        'An iconic symbol of Japan, known for its beauty and cultural significance.',
    category: 'Winter',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1661964177687-57387c2cbd14?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8TW91bnQlMjBGdWppfGVufDB8fDB8fHww',
    latitude: 35.3606,
    longitude: 138.7274,
    address: 'Mount Fuji, Yamanashi Prefecture, Japan',
    rating: 4.9,
    type: 'Mountain',
    bestTimeToVisit: 'July to September',
  ),
  Location(
    name: 'Hokkaido',
    description: 'Famous for its powder snow and ski resorts in Japan.',
    category: 'Winter',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1661882926003-91a51e3dfe64?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8SG9ra2FpZG98ZW58MHx8MHx8fDA%3D',
    latitude: 43.2203,
    longitude: 142.8636,
    address: 'Hokkaido, Japan',
    rating: 4.7,
    type: 'Mountain',
    bestTimeToVisit: 'December to February',
  ),
  Location(
    name: 'Niseko',
    description:
        'A popular winter destination in Japan for skiing and snowboarding.',
    category: 'Winter',
    imageUrl:
        'https://images.unsplash.com/photo-1674297026373-6e2b74da47b6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8TmlzZWtvfGVufDB8fDB8fHww',
    latitude: 42.9550,
    longitude: 140.6879,
    address: 'Niseko, Hokkaido, Japan',
    rating: 4.8,
    type: 'Ski Resort',
    bestTimeToVisit: 'December to March',
  ),
  Location(
    name: 'Pyeongchang',
    description:
        'Home to the 2018 Winter Olympics, known for skiing in South Korea.',
    category: 'Winter',
    imageUrl:
        'https://plus.unsplash.com/premium_photo-1716968595134-f74c3e3ced1d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8UHllb25nY2hhbmd8ZW58MHx8MHx8fDA%3D',
    latitude: 37.6344,
    longitude: 128.5884,
    address: 'Pyeongchang, Gangwon Province, South Korea',
    rating: 4.6,
    type: 'Ski Resort',
    bestTimeToVisit: 'December to February',
  ),
];
