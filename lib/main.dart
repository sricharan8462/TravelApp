import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption & Travel Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PlanManagerScreen(),
    );
  }
}

enum Priority { low, medium, high }

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;
  Priority priority;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.priority = Priority.low,
  });
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adoption & Travel Planner')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      plans.removeAt(index);
                    });
                  },
                  child: ListTile(
                    leading: Checkbox(
                      value: plan.isCompleted,
                      onChanged: (bool? value) {
                        setState(() {
                          plan.isCompleted = value ?? false;
                        });
                      },
                    ),
                    title: Text(
                      '${plan.name} (${plan.priority.toString().split('.').last})',
                      style: TextStyle(
                        color: plan.isCompleted ? Colors.grey : Colors.black,
                        decoration:
                            plan.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    subtitle: Text(
                      '${plan.description} - ${plan.date.toString().substring(0, 10)}',
                    ),
                    tileColor:
                        plan.isCompleted
                            ? Colors.green[100]
                            : Colors.yellow[100],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
