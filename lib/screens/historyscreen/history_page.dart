import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';
import 'package:intl/intl.dart';
import 'download_service.dart';
import 'history_model.dart';
import 'monthly_download_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isCalendarVisible = false;
  Map<int, bool> expansionState = {};
  TextEditingController searchController = TextEditingController();
  bool showFilteredCards = false;
  List<Data> filteredData = [];
  bool isFilterApplied = false;
  int? selectedMonth;
  int? selectedYear;
  List<Data> allData = [];
  String searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 1;
  // bool _isDownloading = false;

  Future<HistoryModel> getHistoryData() async {
    final response = await http.get(Uri.parse(
        'https://beds-accomodation.vercel.app/api/formattedBookingHistory'));
    if (response.statusCode == 200) {
      final history = jsonDecode(response.body);
      return HistoryModel.fromJson(history);
    } else {
      throw Exception('Failed to load history data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoading = true;
    });
    try {
      HistoryModel history = await getHistoryData();
      setState(() {
        allData = history.data;
        filteredData = allData;
        currentPage++;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      try {
        HistoryModel history = await getHistoryData();
        setState(() {
          allData.addAll(history.data);
          currentPage++;
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _fetchMoreData();
    }
  }

  void _filterDataByMonthYear(int month, int year) {
    setState(() {
      selectedMonth = month;
      selectedYear = year;
      filteredData = allData
          .map((employeeData) {
        final filteredEvents = employeeData.bookingDetails?.where((event) {
          DateTime startDate = DateFormat('yyyy-MM-dd').parse(event.loggedInDate);
          DateTime endDate = DateFormat('yyyy-MM-dd').parse(event.loggedOutDate);
          bool isStartDateInMonthYear = startDate.month == month && startDate.year == year;
          bool isEndDateInMonthYear = endDate.month == month && endDate.year == year;
          return isStartDateInMonthYear || isEndDateInMonthYear;
        }).toList();
        if (filteredEvents != null && filteredEvents.isNotEmpty) {
          return Data(
            empId: employeeData.empId,
            name: employeeData.name,
            deptName: employeeData.deptName,
            email: employeeData.email,
            bookingDetails: filteredEvents,
          );
        }
        return null;
      })
          .where((employee) => employee != null)
          .cast<Data>()
          .toList();
    });
  }

  void _searchEmployees(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      List<Data> searchResults = allData.where((employee) {
        bool nameMatches = employee.name.toLowerCase().contains(searchQuery);
        bool deptNameMatches = employee.deptName.toLowerCase().contains(searchQuery);
        return nameMatches || deptNameMatches;
      }).toList();
      if (selectedMonth != null && selectedYear != null) {
        filteredData = searchResults
            .map((employee) {
          final filteredEvents = employee.bookingDetails?.where((event) {
            DateTime startDate = DateFormat('yyyy-MM-dd').parse(event.loggedInDate);
            DateTime endDate = DateFormat('yyyy-MM-dd').parse(event.loggedOutDate);
            bool isStartDateInMonthYear = startDate.month == selectedMonth && startDate.year == selectedYear;
            bool isEndDateInMonthYear = endDate.month == selectedMonth && endDate.year == selectedYear;
            return isStartDateInMonthYear || isEndDateInMonthYear;
          }).toList();
          if (filteredEvents != null && filteredEvents.isNotEmpty) {
            return Data(
              empId: employee.empId,
              name: employee.name,
              deptName: employee.deptName,
              email: employee.email,
              bookingDetails: filteredEvents,
            );
          }
          return null;
        })
            .where((employee) => employee != null)
            .cast<Data>()
            .toList();
      } else {
        filteredData = searchResults;
      }
    });
  }

  void _onApplyPressed() {
    setState(() {
      showFilteredCards = true;
    });
  }

  void _resetFilter() {
    setState(() {
      selectedMonth = null;
      selectedYear = null;
      filteredData = allData;
      searchQuery = '';
    });
  }

  void _filterEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = allData;
      } else {
        filteredData = allData.where((employee) {
          return employee.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deleteBooking(String bookingId, int bedId) async {
    final response = await http.post(
      Uri.parse('https://beds-accomodation.vercel.app/api/cancelBooking'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "bookingId": bookingId,
        "bedId": bedId,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == 1) {
        await _fetchInitialData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking deleted successfully'),
          ),
        );
        expansionState = {
          for (var index
          in List.generate(filteredData.length, (index) => index))
            index: false
        };
        await _fetchInitialData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to delete booking: ${responseBody['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      _searchEmployees(value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search by Employee name and Designation',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 16),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                        onPressed: () {
                          searchController.clear();
                          _filterEmployees('');
                          searchQuery = '';
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 2,
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                    height: 35,
                    width: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          if (isFilterApplied) {
                            _resetFilter();
                            isFilterApplied = false;
                            isCalendarVisible = false;
                            showFilteredCards = false;
                            filteredData = allData;
                            expansionState = {
                              for (var index in List.generate(
                                  filteredData.length, (index) => index))
                                index: false
                            };
                          } else {
                            isFilterApplied = true;
                            isCalendarVisible = true;
                          }
                        });
                      },
                      icon: Icon(
                        isFilterApplied
                            ? Icons.clear_outlined
                            : Icons.filter_list,
                        color: isFilterApplied
                            ? Colors.red
                            : Colors.deepOrangeAccent,
                        size: isFilterApplied ? 25 : 40,
                      ),
                    )),
              ],
            ),
          ),
          if (isCalendarVisible)
            SizedBox(
              height: 65,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: DropdownButton<int>(
                        dropdownColor: Colors.white,
                        value: selectedMonth,
                        hint: const Text('Select Month'),
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(DateFormat('MMMM')
                                .format(DateTime(0, index + 1))),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value;
                          });
                        },
                      ),
                    ),
                    DropdownButton<int>(
                      dropdownColor: Colors.white,
                      value: selectedYear,
                      hint: const Text('Select Year'),
                      items: List.generate(5, (index) {
                        int currentYear = DateTime.now().year;
                        return DropdownMenuItem(
                          value: currentYear - index,
                          child: Text('${currentYear - index}'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedMonth != null && selectedYear != null) {
                          _onApplyPressed();
                          _filterDataByMonthYear(selectedMonth!, selectedYear!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text('Please select both month and year')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:  EdgeInsets.symmetric(horizontal: showFilteredCards ? 10 : 20,vertical: 10),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.deepOrangeAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:  Text(
                        'Apply',
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    ),
                    showFilteredCards
                        ? Container(
                      width: 40, // Square size
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                      // _isDownloading
                      //             ? const Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             SizedBox(
                      //               width: 20,
                      //               height: 20,
                      //               child: CircularProgressIndicator(strokeWidth: 2),
                      //             ),
                      //           ],
                      //         )
                      //                         :
                      IconButton(
                        icon: const Icon(Icons.download_outlined,
                            color: Colors.white),
                        // onPressed:   _isDownloading
                        //             ? null
                        //             : () async {
                        //           setState(() => _isDownloading = true);
                        //           try {
                        //             if (selectedMonth != null &&
                        //                 selectedYear != null &&
                        //                 isFilterApplied == true) {
                        //               MonthlyDownloadService().monthlyExcel(
                        //                   context, selectedMonth!, selectedYear!);
                        //             } else {
                        //               ScaffoldMessenger.of(context).showSnackBar(
                        //                 const SnackBar(
                        //                     content: Text(
                        //                         'Please select both month and year and apply the filter ')),
                        //               );
                        //             }
                        //           } finally {
                        //             if (mounted) {
                        //               setState(() => _isDownloading = false);
                        //             }
                        //           }
                        //         },
                        onPressed: () {
                          if (selectedMonth != null &&
                              selectedYear != null &&
                              isFilterApplied == true) {
                            MonthlyDownloadService().monthlyExcel(
                                context, selectedMonth!, selectedYear!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please select both month and year and apply the filter ')),
                            );
                          }
                        },
                      ),
                    )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          Expanded(
              child: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
                  : showFilteredCards
                  ? ListView.builder(
                controller: _scrollController,
                itemCount: filteredData.isEmpty
                    ? 1
                    : filteredData.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (filteredData.isEmpty) {
                    return  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          "No data available",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == filteredData.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child:
                      Center(child: CircularProgressIndicator()),
                    );
                  }
                  final employee = filteredData[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: employee.bookingDetails!.map((event) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: Card(
                          color: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.grey.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              radius: 30,
                              child: Text(
                                employee.name[0],
                                style:  GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            title: Text(
                              employee.name,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Room No. : ${event.roomNumber}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Bed No. : ${event.bedNumber}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (event.isCancel == 1)
                                  Flexible(
                                    child: Text(
                                      "Canceled",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  employee.deptName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 15,
                                        color: Colors.orange),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Start: ${event.loggedInDate}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 15,
                                        color: Colors.orange),
                                    const SizedBox(width: 5),
                                    Text(
                                      "End: ${event.loggedOutDate}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
                  : ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final employee = filteredData[index];
                  final isExpanded = expansionState[index] ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          radius: 20,
                          child: Text(
                            employee.name[0],
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              employee.deptName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: isExpanded
                            ? Container(
                          width: 40, // Square size
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(
                                Icons.download_outlined,
                                color: Colors.white),
                            onPressed: () {
                              DownloadService().downloadExcel(
                                  context, employee.name);
                            },
                          ),
                        )
                            : const Icon(Icons.expand_more,
                            color: Colors.grey),
                        onExpansionChanged: (isExpanded) {
                          setState(() {
                            expansionState[index] = isExpanded;
                          });
                        },
                        children: [
                          if (isExpanded)
                            Container(
                              width: double.infinity,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: employee.bookingDetails!.length <= 4
                                        ? 100
                                        : 200,
                                    maxHeight: employee.bookingDetails!.length > 4
                                        ? 250
                                        : double.infinity,
                                  ),
                                  child: SingleChildScrollView(
                                    child: FixedTimeline(
                                      theme: TimelineThemeData(
                                        nodePosition: 0.1,
                                        color: Colors.grey,
                                        connectorTheme:
                                        ConnectorThemeData(color: Colors.grey[300],),
                                      ),
                                      children: List.generate(
                                          employee.bookingDetails!.length, (eventIndex) {
                                        final event = employee.bookingDetails![eventIndex];
                                        return TimelineTile(
                                          nodeAlign: TimelineNodeAlign.start,
                                          contents: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0,
                                                vertical: 10.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        event.loggedInDate,
                                                        style: GoogleFonts.poppins(
                                                            color: (event.isCancel == 1)
                                                                ? Colors.grey
                                                                : Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold)),
                                                    const SizedBox(width: 10),
                                                    Text("to",
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color: (event.isCancel == 1)
                                                                ? Colors.grey
                                                                : Colors.black54)),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                        event.loggedOutDate,
                                                        style: GoogleFonts.poppins(
                                                            color: (event.isCancel == 1)
                                                                ? Colors.grey
                                                                : Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold)),
                                                    const Spacer(),
                                                    buildIconOrText(event, context),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(color: Colors.black12, width: 2)),
                                                  child: Text(
                                                    "  Room No.: ${event.roomNumber}, Bed No.: ${event.bedNumber} ",
                                                    style: GoogleFonts.poppins(
                                                      color: (event.isCancel == 1)
                                                          ? Colors.grey
                                                          : Colors.black,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          node: TimelineNode(
                                            indicator: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                DotIndicator(
                                                  color: getDotIndicatorColor(event),
                                                  size: 16,
                                                ),
                                                if (DateTime.now().isAfter(DateTime.parse(event.loggedOutDate)) &&
                                                    DateTime.now().isAfter(DateTime.parse(event.loggedInDate)))
                                                  event.isCancel == 1
                                                      ? const SizedBox()
                                                      : const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 11,
                                                  )
                                              ],
                                            ),
                                            endConnector: eventIndex != employee.bookingDetails!.length + 1
                                                ? const SolidLineConnector()
                                                : null,
                                            startConnector: eventIndex != 0
                                                ? const SolidLineConnector()
                                                : null,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  Color getDotIndicatorColor(var event) {
    final DateTime now = DateTime.now();
    final DateTime loggedInDate = DateTime.parse(event.loggedInDate);
    final DateTime loggedOutDate = DateTime.parse(event.loggedOutDate);
    String caseLabel;
    if (now.isBefore(loggedInDate) && now.isBefore(loggedOutDate)) {
      caseLabel = event.isCancel == 1
          ? 'beforeDatesIsCanceled'
          : 'beforeDatesNotCanceled';
    } else if (now.isAfter(loggedInDate) && now.isAfter(loggedOutDate)) {
      caseLabel = event.isCancel == 1
          ? 'afterDatesIsCanceled'
          : 'afterDatesNotCanceled';
    } else {
      caseLabel = 'default';
    }
    switch (caseLabel) {
      case 'beforeDatesIsCanceled':
        return Colors.grey;
      case 'beforeDatesNotCanceled':
        return Colors.red.shade300;
      case 'afterDatesIsCanceled':
        return Colors.grey;
      case 'afterDatesNotCanceled':
        return Colors.black;
      default:
        return event.isCancel == 0 ? Colors.green.shade300 : Colors.grey;
    }
  }

  Widget buildIconOrText(var event, BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime loggedInDate = DateTime.parse(event.loggedInDate);
    final DateTime loggedOutDate = DateTime.parse(event.loggedOutDate);
    if (now.isBefore(loggedInDate) && now.isBefore(loggedOutDate)) {
      if (event.isCancel == 1) {
        return  Text(
          "Canceled",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.poppins(
            color: Colors.redAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
      } else if (event.isCancel == 0) {
        return IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.black54,
          ),
          onPressed: () {
            String bookingId = event.id;
            int bedId = event.bedId;
            _showDeleteConfirmationDialog(context, bookingId, bedId);
          },
        );
      }
    } else if (now.isAfter(loggedInDate) || now.isAfter(loggedOutDate)) {
      if (event.isCancel == 1) {
        return Text(
          "Canceled",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style:GoogleFonts.poppins(
            color: Colors.redAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String bookingId, int bedId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Confirm',
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content:  Text(
            'Do you want to delete this booking permanently?',
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(

              onPressed: () async {
                await _deleteBooking(bookingId, bedId);
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
                style:GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),

          ],
        );
      },
    );
  }
}
