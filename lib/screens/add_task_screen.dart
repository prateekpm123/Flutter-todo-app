import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import 'package:task_management/models/enums.dart';
import 'package:task_management/providers/auth_provider.dart';
import 'package:task_management/providers/task_provider.dart';
import 'package:task_management/utils/utils.dart';
import 'package:task_management/widgets/task_widgets.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  TaskStatus _selectedStatus = TaskStatus.pending;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _dueDateController = TextEditingController(
      text: DateUtils.formatDate(_selectedDate),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateUtils.formatDate(picked);
      });
    }
  }

  void _handleCreateTask() {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<TaskProvider>().createTask(
          authProvider.currentUser!.id,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          _selectedDate,
        ).then((_) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Title is required';
                  }
                  if (!ValidationUtils.isValidTitle(value!)) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Description field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Status selector
              StatusSelector(
                selectedStatus: _selectedStatus,
                onStatusChanged: (status) {
                  setState(() => _selectedStatus = status);
                },
              ),
              const SizedBox(height: 20),
              // Due date field
              TextFormField(
                controller: _dueDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  hintText: 'Select due date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _dueDateController.clear();
                      setState(() {
                        _selectedDate = DateTime.now();
                      });
                    },
                  ),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 32),
              // Create button
              Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  return ElevatedButton(
                    onPressed: _handleCreateTask,
                    child: const Text('Create Task'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
