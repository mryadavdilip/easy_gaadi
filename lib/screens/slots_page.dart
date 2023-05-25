import 'package:change_case/change_case.dart';
import 'package:easy_gaadi/const.dart';
import 'package:easy_gaadi/widgets/background.dart';
import 'package:easy_gaadi/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

enum SlotStatus {
  available,
  booked,
  unavailable,
}

class SlotsPage extends StatefulWidget {
  const SlotsPage({super.key});

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  SlotStatus? _statusFilter;
  Object _objectKey = Object();
  @override
  Widget build(BuildContext context) {
    return Background(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Parking Slots'),
      ),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2.sp, color: Colors.white),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: DropdownButton<SlotStatus>(
              dropdownColor: Colors.black,
              value: _statusFilter,
              isDense: true,
              icon: const Icon(
                Icons.expand_more,
                color: Colors.white,
              ),
              underline: const Center(),
              onChanged: (SlotStatus? newValue) {
                _statusFilter = newValue;
                _objectKey = Object();
                setState(() {});
              },
              items: SlotStatus.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    '  ${e.name.toUpperFirstCase()}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textScaleFactor: 1.sp,
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 30.h),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              key: ValueKey<Object>(_objectKey),
              stream: _statusFilter == null
                  ? firestore.collection('slots').snapshots()
                  : firestore
                      .collection('slots')
                      .where('status', isEqualTo: _statusFilter!.name)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Slot> slots = snapshot.data!.docs
                      .map((doc) => Slot.fromFirestore(doc))
                      .toList();
                  return GridView.count(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    crossAxisCount: 2,
                    children:
                        slots.map((slot) => SlotCard(slot: slot)).toList(),
                  );
                } else {
                  return const CustomProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Slot {
  final String id;
  final String number;
  final SlotStatus status;
  final String bookedBy;

  Slot({
    required this.id,
    required this.number,
    required this.status,
    required this.bookedBy,
  });

  factory Slot.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data();
    SlotStatus status = SlotStatus.values.byName(data['status']);
    return Slot(
      id: doc.id,
      number: data['number'],
      status: status,
      bookedBy: data['bookedBy'] ?? '',
    );
  }
}

class SlotCard extends StatefulWidget {
  final Slot slot;

  const SlotCard({super.key, required this.slot});

  @override
  State<SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<SlotCard> {
  bool _isBooking = false;

  void _bookSlot() {
    setState(() {
      _isBooking = true;
    });
    FirebaseFirestore.instance.collection('slots').doc(widget.slot.id).update({
      'status': SlotStatus.booked.name,
      'bookedBy': auth.currentUser?.email,
    }).then((value) {
      setState(() {
        _isBooking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Slot ${widget.slot.number} booked successfully.'),
      ));
    }).catchError((error) {
      setState(() {
        _isBooking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('An error occurred while booking slot ${widget.slot.number}.'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Slot ${widget.slot.number}',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            widget.slot.status.name.toUpperFirstCase(),
            style: TextStyle(
              fontSize: 18.0,
              color: widget.slot.status == SlotStatus.available
                  ? Colors.green
                  : widget.slot.status == SlotStatus.booked
                      ? Colors.amber
                      : Colors.red,
            ),
          ),
          const SizedBox(height: 16.0),
          if (widget.slot.status == SlotStatus.booked)
            Text('Booked by: ${widget.slot.bookedBy}'),
          ElevatedButton(
            onPressed: widget.slot.status == SlotStatus.available && !_isBooking
                ? _bookSlot
                : null,
            child: _isBooking
                ? const CustomProgressIndicator()
                : const Text('Book Slot'),
          ),
        ],
      ),
    );
  }
}
