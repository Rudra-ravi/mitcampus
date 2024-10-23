import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/blocs/task_bloc.dart';
import 'package:mitcampus/models/task.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _deadline;
  late String _description;
  final List<String> _assignedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onSaved: (value) => _description = value!,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _deadline = picked;
                  });
                }
              },
              child: const Text('Select Deadline'),
            ),
            const SizedBox(height: 16),
            // Add a widget to select assigned users here
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _title,
                    deadline: _deadline,
                    description: _description,
                    assignedUsers: _assignedUsers,
                    comments: [],
                  );
                  context.read<TaskBloc>().add(CreateTaskEvent(newTask));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
