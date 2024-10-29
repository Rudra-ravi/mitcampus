import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mitcampus/blocs/task_bloc.dart';
import 'package:mitcampus/models/task.dart';
import 'package:mitcampus/repositories/user_repository.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:mitcampus/models/user.dart' as app_user;

class CreateTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const CreateTaskScreen({super.key, this.taskToEdit});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;
  List<String> _assignedUsers = [];
  bool _isLoading = false;
  List<app_user.User> _availableUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _loadUsers();
  }

  void _initializeFormData() {
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description ?? '';
      _deadline = widget.taskToEdit!.deadline;
      _assignedUsers = List.from(widget.taskToEdit!.assignedUsers);
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final userRepository = UserRepository();
      final users = await userRepository.getAllUsers();
      if (mounted) {
        setState(() {
          _availableUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load users: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.taskToEdit != null ? 'Edit Task' : 'Create Task',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF2563EB),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withOpacity(0.9),
            const Color(0xFF0EA5E9).withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildForm(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 20),
            _buildDeadlineSelector(),
            const SizedBox(height: 20),
            _buildUserSelection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return _buildInputField(
      controller: _titleController,
      label: 'Title',
      hint: 'Enter task title',
      icon: Icons.title,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return _buildInputField(
      controller: _descriptionController,
      label: 'Description',
      hint: 'Enter task description',
      icon: Icons.description,
      maxLines: 3,
    );
  }

  Widget _buildDeadlineSelector() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  'Deadline: ${_deadline?.toString().split(' ')[0] ?? 'Not set'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text('Select Deadline'),
                onPressed: _selectDeadline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        widget.taskToEdit != null ? 'Update Task' : 'Create Task',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      _showErrorSnackBar('Please select a deadline');
      return;
    }

    setState(() => _isLoading = true);
    try {
      _formKey.currentState!.save();
      final task = Task(
        id: widget.taskToEdit?.id,
        title: _titleController.text,
        deadline: _deadline!,
        description: _descriptionController.text,
        assignedUsers: _assignedUsers,
        comments: widget.taskToEdit?.comments ?? [],
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
      );

      if (widget.taskToEdit != null) {
        context.read<TaskBloc>().add(UpdateTaskEvent(task));
      } else {
        context.read<TaskBloc>().add(CreateTaskEvent(task));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.taskToEdit != null 
              ? 'Task updated successfully' 
              : 'Task created successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to ${widget.taskToEdit != null ? 'update' : 'create'} task: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: const Color(0xFF2563EB).withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSelection() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  'Assign Users',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MultiSelectDialogField<String>(
              items: _availableUsers
                  .map((user) => MultiSelectItem<String>(
                      user.id, user.displayName))
                  .toList(),
              initialValue: _assignedUsers,
              title: const Text("Select Users"),
              selectedColor: const Color(0xFF2563EB),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2563EB)),
              ),
              buttonIcon: const Icon(Icons.arrow_drop_down),
              buttonText: const Text("Select Users"),
              onConfirm: (values) {
                setState(() {
                  _assignedUsers = values;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}



extension on Object? {
  get displayName => null;
}
