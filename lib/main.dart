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

// Plan data model with priority
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

  // Show modal to create a new plan
  void _showCreatePlanModal(BuildContext context) {
    String name = '';
    String description = '';
    DateTime date = _selectedDay ?? DateTime.now();
    Priority selectedPriority = Priority.low;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Plan Name'),
                      onChanged: (value) => name = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      onChanged: (value) => description = value,
                    ),
                    DropdownButton<Priority>(
                      value: selectedPriority,
                      items: Priority.values
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority.toString().split('.').last),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedPriority = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setModalState(() {
                            date = pickedDate;
                          });
                        }
                      },
                      child: Text('Selected Date: ${date.toString().substring(0, 10)}'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (name.isNotEmpty) {
                          setState(() {
                            plans.add(Plan(
                              name: name,
                              description: description,
                              date: date,
                              priority: selectedPriority,
                            ));
                            plans.sort((a, b) => b.priority.index.compareTo(a.priority.index));
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add Plan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Edit plan details
  void _editPlan(int index) {
    String name = plans[index].name;
    String description = plans[index].description;
    Priority priority = plans[index].priority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Plan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Plan Name'),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    controller: TextEditingController(text: description),
                    onChanged: (value) => description = value,
                  ),
                  DropdownButton<Priority>(
                    value: priority,
                    items: Priority.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.toString().split('.').last),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        priority = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      plans[index].name = name;
                      plans[index].description = description;
                      plans[index].priority = priority;
                      plans.sort((a, b) => b.priority.index.compareTo(a.priority.index));
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Get events for a specific day
  List<Plan> _getEventsForDay(DateTime day) {
    return plans.where((plan) => isSameDay(plan.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adoption & Travel Planner')),
      body: Column(
        children: [
          // Interactive Calendar
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
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
          // Drag Target for Plans
          DragTarget<Plan>(
            onAccept: (plan) {
              setState(() {
                plan.date = _selectedDay ?? DateTime.now();
                plans.add(plan);
                plans.sort((a, b) => b.priority.index.compareTo(a.priority.index));
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 50,
                color: Colors.blue[100],
                child: const Center(child: Text('Drag New Plans Here')),
              );
            },
          ),
          // Plan List with Checkbox
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      plans.removeAt(index); // Remove plan on double-tap
                    });
                  },
                  onLongPress: () => _editPlan(index),
                  child: Draggable<Plan>(
                    data: plan,
                    feedback: Material(
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.blue.withOpacity(0.7),
                        child: Text(plan.name, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    childWhenDragging: Container(),
                    child: ListTile(
                      leading: Checkbox(
                        value: plan.isCompleted,
                        onChanged: (bool? value) {
                          setState(() {
                            plan.isCompleted = value ?? false; // Toggle completion with checkbox
                          });
                        },
                      ),
                      title: Text(
                        '${plan.name} (${plan.priority.toString().split('.').last})',
                        style: TextStyle(
                          color: plan.isCompleted ? Colors.grey : Colors.black,
                          decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text('${plan.description} - ${plan.date.toString().substring(0, 10)}'),
                      tileColor: plan.isCompleted ? Colors.green[100] : Colors.yellow[100],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlanModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}