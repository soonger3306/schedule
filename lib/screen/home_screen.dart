import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:schedule/component/calendar.dart';
import 'package:schedule/component/schedule_bottom_sheet.dart';
import 'package:schedule/component/schedule_card.dart';
import 'package:schedule/component/today_banner.dart';
import 'package:schedule/const/colors.dart';
import 'package:schedule/database/drift_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: renderFloatingActionButton(),
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              onDaySelected: onDaySelected,
              selectedDay: selectedDay,
              focusedDay: focusedDay,
            ),
            const SizedBox(
              height: 8.0,
            ),
            TodayBanner(
              scheduleCount: 3,
              selectedDay: selectedDay,
            ),
            const SizedBox(
              height: 8.0,
            ),
            _ScheduleList(
              selectedDate: selectedDay,
            )
          ],
        ),
      ),
    );
  }

  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
              return ScheduleBottomSheet(
                selectedDate: selectedDay,
              );
            });
      },
      backgroundColor: PRIMARY_COLOR,
      child: const Icon(Icons.add),
    );
  }

  onDaySelected(selectedDay, focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = selectedDay;
    });
  }
}

class _ScheduleList extends StatelessWidget {
  final DateTime selectedDate;
  const _ScheduleList({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<List<Schedule>>(
            stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
            builder: (context, snapshot) {
              print(snapshot.data);
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('스케쥴이 없습니다'),
                );
              }
              return ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 8.0,
                    );
                  },
                  itemBuilder: (context, index) {
                    final schedule = snapshot.data![index];
                    return ScheduleCard(
                      color: Colors.blue,
                      content: schedule.content,
                      startTime: schedule.startTime,
                      endTime: schedule.endTime,
                    );
                  });
            }),
      ),
    );
  }
}
