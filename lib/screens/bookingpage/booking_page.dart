import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../style/color.dart';
import 'booking_model2.dart';

class BookingPage extends StatefulWidget {
  final int bedIndex;
  final String roomNumber;
  final String gender;
  final String dateTime;

  const BookingPage(
      {super.key,
        required this.bedIndex,
        required this.roomNumber,
        required this.gender,
        required this.dateTime});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _selectedGender;
  String? _selectedBedNo;
  DateTime? _startDate;
  DateTime? _endDate;
  String? selectedValue;
  List<Data> _employees = [];
  List<Data> _filteredEmployees = [];
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _fetchEmployeeData() async {
    final response = await http.get(
        Uri.parse('https://beds-accomodation.vercel.app/api/getEmployeeList'));
    if (response.statusCode == 200) {
      final employeeDropdown =
      EmployeeDropdown.fromJson(jsonDecode(response.body));
      setState(() {
        _employees = employeeDropdown.data!;
        _filteredEmployees = _employees
            .where((employee) => employee.gender == _selectedGender)
            .toList();
        selectedValue = null;
      });
    } else {
      throw Exception('Failed to load employee data');
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.gender;
    _selectedBedNo = 'Bed No. ${widget.bedIndex}';
    _startDate = DateTime.parse(widget.dateTime);
    _fetchEmployeeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Booking",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              _buildDropdowns(),
              const SizedBox(height: 30),
              _buildDatePickers(),
              const SizedBox(height: 30),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Row(
                    children: [
                      Icon(Icons.person, color: Theme.of(context).hintColor),
                      const SizedBox(width: 5),
                      Text(
                        'Select Employee Name',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  items: _filteredEmployees.map((employee) {
                    return DropdownMenuItem<String>(
                      value: employee.name,
                      child: Text(employee.name!),
                    );
                  }).toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                      final selectedEmployee = _filteredEmployees.firstWhere(
                              (employee) => employee.name == selectedValue);
                      _employeeIdController.text = selectedEmployee.id ?? '';
                      _emailIdController.text = selectedEmployee.email ?? '';
                      _departmentController.text =
                          selectedEmployee.deptName ?? '';
                      _designationController.text =
                          selectedEmployee.roleName ?? '';
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        border: const Border.symmetric(
                            vertical: BorderSide.none,
                            horizontal: BorderSide.none),
                        borderRadius: BorderRadius.circular(12)),
                    height: 40,
                  ),
                  dropdownStyleData: const DropdownStyleData(
                    decoration: BoxDecoration(color: Colors.white),
                    maxHeight: 200,
                  ),
                  menuItemStyleData: const MenuItemStyleData(height: 40),
                  dropdownSearchData: DropdownSearchData(
                    searchController: _textEditingController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 50,
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 4,
                        right: 8,
                        left: 8,
                      ),
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          hintText: 'Search for an item...',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black12, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (items, searchValue) {
                      return items.value
                          .toString()
                          .toLowerCase()
                          .contains(searchValue.toLowerCase());
                    },
                  ),
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      _textEditingController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              buildTextFormField(_employeeIdController, "EmployeeID"),
              const SizedBox(height: 30),
              buildTextFormField(_emailIdController, "EmailID"),
              const SizedBox(height: 30),
              buildTextFormField(_departmentController, "Department"),
              const SizedBox(height: 30),
              buildTextFormField(_designationController, "Designation"),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField(
      formcontroller,
      String label,
      ) {
    return TextFormField(
      controller: formcontroller,
      decoration: InputDecoration(
        fillColor: const Color(0xFFF5F5F5),
        labelText: label,
        prefixIcon: const Icon(Icons.work),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      readOnly: true,
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
            child: TextFormField(
              readOnly: true,
              initialValue: _selectedGender,
              decoration: InputDecoration(
                fillColor: const Color(0xFFF5F5F5),
                labelText: 'Gender',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: null,
            )),
        const SizedBox(width: 16),
        Expanded(
            child: TextFormField(
              readOnly: true,
              initialValue: _selectedBedNo,
              decoration: InputDecoration(
                fillColor: const Color(0xFFF5F5F5),
                labelText: 'Bed No.',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: null,
            )),
      ],
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_today),
              labelText: 'Start Date',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            controller: TextEditingController(
              text: formatDate(_startDate),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Text('To',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              DateTime? selectedDate =
              await _selectLogoutDate(context, _endDate.toString());
              if (selectedDate != null) {
                setState(() {
                  _endDate = selectedDate;
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_today),
                  labelText: 'End Date',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: TextEditingController(
                  text: formatDate(_endDate),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _selectLogoutDate(
      BuildContext context, String currentEndDate) async {
    DateTime initialDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: myOnSecondaryColor,
            colorScheme: ColorScheme.light(
              primary: myPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    return pickedDate;
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final startDateIso = _startDate != null
              ? DateFormat('yyyy-MM-dd').format(_startDate!)
              : '';
          final endDateIso = _endDate != null
              ? DateFormat('yyyy-MM-dd').format(_endDate!)
              : '';
          final bedId = int.parse(_selectedBedNo!.split(' ').last);
          final selectedEmployee = _employees.firstWhere(
                  (employee) => employee.name == selectedValue,
              orElse: () => Data());
          final employeeId =
          selectedEmployee.id != null ? int.parse(selectedEmployee.id!) : 0;
          final response = await http.post(
            Uri.parse('https://beds-accomodation.vercel.app/api/bookingBeds'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "empId": employeeId,
              "loggedInDate": startDateIso,
              "loggedOutDate": endDateIso,
              "bedId": bedId,
            }),
          );
          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            if (responseBody['success'] == 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Booking Added Successfully',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ));
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${responseBody['message']}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ));
            }
          } else {
            final responseBody = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${responseBody['message']}')));
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          'Save Booking',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
