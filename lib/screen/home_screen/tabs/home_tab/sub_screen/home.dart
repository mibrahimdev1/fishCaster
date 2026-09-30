// import 'package:fish_caster/import_file.dart';
// import 'package:fish_caster/screen/criteria_screen/create_criteria_screen.dart';
// import 'package:fish_caster/screen/home_screen/tabs/home_tab/sub_screen/score_detail_screen.dart';
// import 'package:fish_caster/screen/home_screen/tabs/home_tab/sub_screen/select_location.dart';
// import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/notification_screen.dart';
// import 'package:fish_caster/screen/home_screen/tabs/setting_tab/sub_screens/profile/profile_setting.dart';
// import 'package:fish_caster/widgets/Buttons/custom_button_textfield.dart';
// import 'package:flutter/material.dart';

// class Hometab extends StatefulWidget {
//   const Hometab({super.key});

//   @override
//   State<Hometab> createState() => _HometabState();
// }

// class _HometabState extends State<Hometab> with SingleTickerProviderStateMixin {
//   bool _isRefreshing = false;

//   late AnimationController _rotationController;

//   @override
//   void initState() {
//     super.initState();
//     _rotationController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 1),
//     )..repeat(); // We'll stop it initially
//     _rotationController.stop(); // Start paused
//   }

//   @override
//   void dispose() {
//     _rotationController.dispose();
//     super.dispose();
//   }

//   List<Map<String, dynamic>> data = [
//     {
//       'title': 'Today',
//       'day1': "Morning",
//       'day1Clr': Color(0xff565F27),
//       'day1Score': '88',
//       'day2': "Mid day",
//       'day2Clr': Color(0xffBA6E12),
//       'day2Score': '58',
//       'day3': "Evening",
//       'day3Clr': Color(0xff87132C),
//       'day3Score': '24',
//     },
//     {
//       'title': 'Sat 05/19',
//       'day1': "Morning",
//       'day1Clr': Color(0xffBA6E12),
//       'day1Score': '44',
//       'day2': "Mid day",
//       'day2Clr': Color(0xffBA6E12),
//       'day2Score': '60',
//       'day3': "Evening",
//       'day3Clr': Color(0xffBA6E12),
//       'day3Score': '62',
//     },
//     {
//       'title': 'Fri 05/18',
//       'day1': "Morning",
//       'day1Clr': Color(0xff87132C),
//       'day1Score': '24',
//       'day2': "Mid day",
//       'day2Clr': Color(0xffBA6E12),
//       'day2Score': '38',
//       'day3': "Evening",
//       'day3Clr': Color(0xffBA6E12),
//       'day3Score': '44',
//     },
//   ];

//   Future<void> _refreshData() async {
//     setState(() {
//       _isRefreshing = true;
//     });
//     _rotationController.repeat();

//     // Simulate network delay or fetch
//     await Future.delayed(Duration(seconds: 2));

//     setState(() {
//       data.shuffle(); // Simulate new data
//       _isRefreshing = false;
//     });
//     _rotationController.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: AppBar(
//           toolbarHeight: 80,
//           backgroundColor: Colors.transparent,
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           flexibleSpace: Padding(
//             padding: const EdgeInsets.only(top: 0), // for status bar spacing
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                   ), // Optional inner padding
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ProfileSettingScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: 60,
//                           height: 60,
//                           // decoration: const BoxDecoration(
//                           //   image: DecorationImage(
//                           //     image: AssetImage(ImgCons.profile),
//                           //     fit: BoxFit.contain,
//                           //   ),
//                           //   shape: BoxShape.circle,
//                           // ),
//                         ),
//                       ),
//                       Container(
//                         width: 230,
//                         height: 90,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             image: AssetImage(ImgCons.name_logo),
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => NotificationScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: AssetImage(ImgCons.notificationIcon),
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   height: 1,
//                   color: Colors.white.withOpacity(0.5),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),

//       body: ThemedBackground(
//         child: SafeArea(
//           child: RefreshIndicator(
//             onRefresh: _refreshData,
//             color: ClrCons.whiteColor, // Customize if needed
//             backgroundColor: Colors.transparent,
//             child: SingleChildScrollView(
//               child: Center(
//                 child: Container(
//                   width: SizeCons.getWidth(context) * 0.95,
//                   child: Column(
//                     children: [
//                       SizedBox(height: 20),
//                       GestureDetector(
//                         onTap: () async {
//                           final selectedLocation = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SelectLocationScreen(),
//                             ),
//                           );

//                           if (selectedLocation != null) {
//                             print("Selected Location: $selectedLocation");
//                             // You can store it or update your state here
//                           }
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CustomButtonTextField(
//                               child: Center(
//                                 child: CustomText(
//                                   text: 'Location',
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               width: SizeCons.getWidth(context) * 0.7,
//                               height: 50,
//                             ),
//                             SizedBox(width: 10),
//                             Container(
//                               width: 30,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 image: DecorationImage(
//                                   image: AssetImage(ImgCons.locationIcon),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       CustomButtonTextField(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               CustomText(
//                                 text: 'Select Criteria',
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               Icon(
//                                 Icons.keyboard_arrow_down,
//                                 size: 28,
//                                 color: ClrCons.whiteColor,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 25,
//                                 height: 25,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: ClrCons.whiteColor),
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(3.0),
//                                   child: Image.asset(ImgCons.fireIcon),
//                                 ),
//                               ),
//                               SizedBox(width: 5),
//                               CustomText(text: 'Hot Fishing', fontSize: 16),
//                             ],
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => CreateCriteriaScreen(),
//                                 ),
//                               );
//                             },
//                             child: Row(
//                               children: [
//                                 CustomText(
//                                   text: 'Create Criteria',
//                                   fontSize: 16,
//                                 ),
//                                 SizedBox(width: 5),

//                                 Container(
//                                   width: 25,
//                                   height: 25,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: ClrCons.whiteColor,
//                                     ),
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   child: Icon(
//                                     Icons.add,
//                                     color: ClrCons.whiteColor,
//                                     size: 18,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 20),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CustomButtonTextField(
//                             width: SizeCons.getWidth(context) * 0.4,
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   CustomText(
//                                     text: 'Current',
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   scoreWidget(
//                                     score: '55',
//                                     color: Color(0xffBA6E12),
//                                     ontap: () {},
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 30),
//                           // GestureDetector(
//                           //   onTap: _refreshData,
//                           //   child: Icon(
//                           //     Icons.refresh,
//                           //     size: 30,
//                           //     color: ClrCons.whiteColor,
//                           //   ),
//                           // ),
//                           GestureDetector(
//                             onTap: () {
//                               if (!_isRefreshing) {
//                                 _refreshData();
//                               }
//                             },
//                             child: AnimatedBuilder(
//                               animation: _rotationController,
//                               builder: (_, child) {
//                                 return Transform.rotate(
//                                   angle:
//                                       _rotationController.value *
//                                       6.3, // Full rotation
//                                   child: child,
//                                 );
//                               },
//                               child: Icon(
//                                 Icons.refresh,
//                                 size: 30,
//                                 color: ClrCons.whiteColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       // ListView.builder(
//                       //   itemCount: data.length,
//                       //   shrinkWrap: true,
//                       //   physics: NeverScrollableScrollPhysics(),
//                       //   itemBuilder: (context, index) {
//                       //     return Padding(
//                       //       padding: const EdgeInsets.only(bottom: 20),
//                       //       child: Container(
//                       //         child: Column(
//                       //           children: [
//                       //             CustomText(
//                       //               text: data[index]['title'],
//                       //               fontSize: 20,
//                       //             ),
//                       //             Row(
//                       //               children: [
//                       //                 Container(
//                       //                   width: SizeCons.getWidth(context) * 0.3,
//                       //                   height: 140,
//                       //                   decoration: BoxDecoration(
//                       //                     border: Border.all(
//                       //                       color: ClrCons.whiteColor,
//                       //                     ),
//                       //                     borderRadius: BorderRadius.only(
//                       //                       bottomLeft: Radius.circular(20),
//                       //                       topLeft: Radius.circular(20),
//                       //                     ),
//                       //                   ),
//                       //                   child: Column(
//                       //                     mainAxisAlignment:
//                       //                         MainAxisAlignment.spaceAround,
//                       //                     children: [
//                       //                       CustomText(
//                       //                         text: data[index]['day1'],
//                       //                         fontSize: 20,
//                       //                       ),
//                       //                       scoreWidget(
//                       //                         score: data[index]['day1Score'],
//                       //                         color: data[index]['day1Clr'],
//                       //                         ontap: () {
//                       //                           Navigator.push(
//                       //                             context,
//                       //                             MaterialPageRoute(
//                       //                               builder:
//                       //                                   (
//                       //                                     context,
//                       //                                   ) => ScoreDetailScreen(
//                       //                                     title:
//                       //                                         data[index]['title'],
//                       //                                     score:
//                       //                                         data[index]['day1Score'],
//                       //                                     color:
//                       //                                         data[index]['day1Clr'],
//                       //                                     day:
//                       //                                         data[index]['day1'],
//                       //                                   ),
//                       //                             ),
//                       //                           );
//                       //                         },
//                       //                       ),
//                       //                     ],
//                       //                   ),
//                       //                 ),
//                       //                 Container(
//                       //                   width: SizeCons.getWidth(context) * 0.3,
//                       //                   height: 140,
//                       //                   decoration: BoxDecoration(
//                       //                     border: Border(
//                       //                       bottom: BorderSide(
//                       //                         color: ClrCons.whiteColor,
//                       //                       ),
//                       //                       top: BorderSide(
//                       //                         color: ClrCons.whiteColor,
//                       //                       ),
//                       //                     ),
//                       //                   ),
//                       //                   child: Column(
//                       //                     mainAxisAlignment:
//                       //                         MainAxisAlignment.spaceAround,
//                       //                     children: [
//                       //                       CustomText(
//                       //                         text: data[index]['day2'],
//                       //                         fontSize: 20,
//                       //                       ),
//                       //                       scoreWidget(
//                       //                         score: data[index]['day2Score'],
//                       //                         color: data[index]['day2Clr'],
//                       //                         ontap: () {
//                       //                           Navigator.push(
//                       //                             context,
//                       //                             MaterialPageRoute(
//                       //                               builder:
//                       //                                   (
//                       //                                     context,
//                       //                                   ) => ScoreDetailScreen(
//                       //                                     title:
//                       //                                         data[index]['title'],
//                       //                                     score:
//                       //                                         data[index]['day2Score'],
//                       //                                     color:
//                       //                                         data[index]['day2Clr'],
//                       //                                     day:
//                       //                                         data[index]['day2'],
//                       //                                   ),
//                       //                             ),
//                       //                           );
//                       //                         },
//                       //                       ),
//                       //                     ],
//                       //                   ),
//                       //                 ),
//                       //                 Container(
//                       //                   width: SizeCons.getWidth(context) * 0.3,
//                       //                   height: 140,
//                       //                   decoration: BoxDecoration(
//                       //                     border: Border.all(
//                       //                       color: ClrCons.whiteColor,
//                       //                     ),
//                       //                     borderRadius: BorderRadius.only(
//                       //                       bottomRight: Radius.circular(20),
//                       //                       topRight: Radius.circular(20),
//                       //                     ),
//                       //                   ),
//                       //                   child: Column(
//                       //                     mainAxisAlignment:
//                       //                         MainAxisAlignment.spaceAround,
//                       //                     children: [
//                       //                       CustomText(
//                       //                         text: data[index]['day3'],
//                       //                         fontSize: 20,
//                       //                       ),
//                       //                       scoreWidget(
//                       //                         score: data[index]['day3Score'],
//                       //                         color: data[index]['day3Clr'],
//                       //                         ontap: () {
//                       //                           Navigator.push(
//                       //                             context,
//                       //                             MaterialPageRoute(
//                       //                               builder:
//                       //                                   (
//                       //                                     context,
//                       //                                   ) => ScoreDetailScreen(
//                       //                                     title:
//                       //                                         data[index]['title'],
//                       //                                     day:
//                       //                                         data[index]['day3'],
//                       //                                     score:
//                       //                                         data[index]['day3Score'],
//                       //                                     color:
//                       //                                         data[index]['day3Clr'],
//                       //                                   ),
//                       //                             ),
//                       //                           );
//                       //                         },
//                       //                       ),
//                       //                     ],
//                       //                   ),
//                       //                 ),
//                       //               ],
//                       //             ),
//                       //           ],
//                       //         ),
//                       //       ),
//                       //     );
//                       //   },
//                       // ),
//                       CustomColorTable(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class scoreWidget extends StatelessWidget {
//   final String score;
//   final Color color;
//   final Function() ontap;
//   const scoreWidget({
//     super.key,
//     required this.score,
//     required this.color,
//     required this.ontap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: ontap,
//       child: Container(
//         height: 40,
//         width: 40,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: color,
//         ),
//         child: Center(child: CustomText(text: score, fontSize: 20)),
//       ),
//     );
//   }
// }

// // class CustomColorTable extends StatelessWidget {
// //   final List<String> headers = [
// //     "Early morning",
// //     "Late morning early afternoon",
// //     "Late afternoon evening",
// //   ];

// //   final List<List<dynamic>> data = [
// //     ["Today", 88, 58, 23],
// //     ["Sat\n3/23", 44, "60!", 62],
// //     ["Sun\n3/24", 24, 38, 44],
// //     ["Mon\n3/25", 90, 92, 70],
// //     ["Tues\n3/26", 65, 67, 43],
// //     ["Wed\n3/27", 22, 24, "45!"],
// //     ["Thurs\n3/28", 88, 67, 44],
// //   ];

// //   Color getColor(value) {
// //     int val = int.tryParse(value.toString().replaceAll('!', '')) ?? 0;
// //     if (val >= 80) return Color(0xff565F27);
// //     if (val >= 45) return Color(0xffBA6E12);
// //     return Color(0xff87132C);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         child: Container(
// //           margin: const EdgeInsets.all(20),
// //           child: Column(
// //             children: [
// //               // Header Row
// //               Row(
// //                 children: [
// //                   _buildFixedCell(
// //                     width: 120,
// //                     height: 60,
// //                     bgColor: Colors.transparent,
// //                     borderRadius: const BorderRadius.only(
// //                       topLeft: Radius.circular(12),
// //                     ),
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: const [
// //                         CustomText(
// //                           text: "Date",
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: ClrCons.whiteColor,
// //                         ),
// //                         // CustomText(
// //                         //   text: "55",
// //                         //   fontWeight: FontWeight.bold,
// //                         //   color: ClrCons.whiteColor,
// //                         // ),
// //                       ],
// //                     ),
// //                   ),
// //                   ...headers.asMap().entries.map((entry) {
// //                     int i = entry.key;
// //                     return _buildFixedCell(
// //                       width: 120,
// //                       height: 60,
// //                       bgColor: Colors.transparent,
// //                       borderRadius:
// //                           i == headers.length - 1
// //                               ? const BorderRadius.only(
// //                                 topRight: Radius.circular(12),
// //                               )
// //                               : null,
// //                       child: CustomText(
// //                         text: entry.value,
// //                         fontWeight: FontWeight.bold,
// //                         color: ClrCons.whiteColor,
// //                         textAlign: TextAlign.center,
// //                         // maxLines: 2,
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ],
// //               ),

// //               // Data Rows
// //               ...data.asMap().entries.map((entry) {
// //                 int rowIndex = entry.key;
// //                 List<dynamic> row = entry.value;
// //                 return Row(
// //                   children: [
// //                     _buildFixedCell(
// //                       width: 120,
// //                       height: 60,
// //                       bgColor: Colors.transparent,
// //                       borderRadius:
// //                           rowIndex == data.length - 1
// //                               ? const BorderRadius.only(
// //                                 bottomLeft: Radius.circular(12),
// //                               )
// //                               : null,
// //                       child: Center(
// //                         child: CustomText(
// //                           text: row[0],
// //                           fontWeight: FontWeight.bold,
// //                           color: ClrCons.whiteColor,
// //                           textAlign: TextAlign.center,
// //                         ),
// //                       ),
// //                     ),
// //                     ...List.generate(3, (i) {
// //                       return _buildFixedCell(
// //                         width: 120,
// //                         height: 60,
// //                         bgColor: getColor(row[i + 1]),
// //                         borderRadius:
// //                             (rowIndex == data.length - 1 && i == 2)
// //                                 ? const BorderRadius.only(
// //                                   bottomRight: Radius.circular(12),
// //                                 )
// //                                 : null,
// //                         child: Text(
// //                           row[i + 1].toString(),
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: ClrCons.whiteColor,
// //                           ),
// //                         ),
// //                       );
// //                     }),
// //                   ],
// //                 );
// //               }).toList(),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFixedCell({
// //     required double width,
// //     required double height,
// //     required Widget child,
// //     required Color bgColor,
// //     BorderRadius? borderRadius,
// //   }) {
// //     return Container(
// //       width: width,
// //       height: height,
// //       decoration: BoxDecoration(
// //         color: bgColor,
// //         borderRadius: borderRadius ?? BorderRadius.zero,
// //         border: Border.all(color: ClrCons.whiteColor, width: 1),
// //       ),
// //       alignment: Alignment.center,
// //       child: child,
// //     );
// //   }
// // }

// class CustomColorTable extends StatelessWidget {
//   final List<String> headers = [
//     "Early morning",
//     "Late morning to early afternoon",
//     "Late afternoon to evening",
//   ];

//   final List<List<dynamic>> data = [
//     ["Today", 88, 58, 23],
//     ["Sat\n3/23", 44, "60!", 62],
//     ["Sun\n3/24", 24, 38, 44],
//     ["Mon\n3/25", 90, 92, 70],
//     ["Tues\n3/26", 65, 67, 43],
//     ["Wed\n3/27", 22, 24, "45!"],
//     ["Thurs\n3/28", 88, 67, 44],
//   ];

//   Color getColor(value) {
//     int val = int.tryParse(value.toString().replaceAll('!', '')) ?? 0;
//     if (val >= 80) return Color(0xff565F27);
//     if (val >= 45) return Color(0xffBA6E12);
//     return Color(0xff87132C);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Container(
//         width: SizeCons.getWidth(context) * 0.94,
//         child: Column(
//           children: [
//             // Header Row
//             Row(
//               children: [
//                 _buildFixedCell(
//                   width: 90,
//                   height: 60,
//                   bgColor: Colors.transparent,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: const [
//                       CustomText(
//                         text: "Date",
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: ClrCons.whiteColor,
//                       ),
//                     ],
//                   ),
//                 ),
//                 ...headers.asMap().entries.map((entry) {
//                   int i = entry.key;
//                   return _buildFixedCell(
//                     width: 105,
//                     height: 60,
//                     bgColor: Colors.transparent,
//                     borderRadius: i == headers.length - 1
//                         ? const BorderRadius.only(
//                             topRight: Radius.circular(12),
//                           )
//                         : null,
//                     child: CustomText(
//                       text: entry.value,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: ClrCons.whiteColor,
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),

//             // Data Rows
//             ...data.asMap().entries.map((entry) {
//               int rowIndex = entry.key;
//               List<dynamic> row = entry.value;
//               return Row(
//                 children: [
//                   _buildFixedCell(
//                     width: 90,
//                     height: 60,
//                     bgColor: Colors.transparent,
//                     borderRadius: rowIndex == data.length - 1
//                         ? const BorderRadius.only(
//                             bottomLeft: Radius.circular(12),
//                           )
//                         : null,
//                     child: Center(
//                       child: CustomText(
//                         text: row[0],
//                         fontWeight: FontWeight.bold,
//                         color: ClrCons.whiteColor,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                   ...List.generate(3, (i) {
//                     return GestureDetector(
//                       onTap: () {
//                         // Navigate to ScoreDetailScreen with appropriate data
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ScoreDetailScreen(
//                               title: row[0],
//                               score: row[i + 1].toString(),
//                               color: getColor(row[i + 1]),
//                               day: headers[i],
//                             ),
//                           ),
//                         );
//                       },
//                       child: _buildFixedCell(
//                         width: 105,
//                         height: 60,
//                         bgColor: getColor(row[i + 1]),
//                         borderRadius: (rowIndex == data.length - 1 && i == 2)
//                             ? const BorderRadius.only(
//                                 bottomRight: Radius.circular(12),
//                               )
//                             : null,
//                         child: Text(
//                           row[i + 1].toString(),
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: ClrCons.whiteColor,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ],
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFixedCell({
//     required double width,
//     required double height,
//     required Widget child,
//     required Color bgColor,
//     BorderRadius? borderRadius,
//   }) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: borderRadius ?? BorderRadius.zero,
//         border: Border.all(color: ClrCons.whiteColor, width: 1),
//       ),
//       alignment: Alignment.center,
//       child: child,
//     );
//   }
// }
