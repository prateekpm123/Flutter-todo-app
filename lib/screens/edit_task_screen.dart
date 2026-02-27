import 'package:flutter/material.dart' hide DateUtils;
// import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/models/enums.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/providers/task_provider.dart';
import 'package:task_management/utils/utils.dart';
import 'package:task_management/widgets/task_widgets.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  late TaskStatus _selectedStatus;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
    _selectedDate = widget.task.dueDate;
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
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

  void _handleUpdateTask() {
    if (_formKey.currentState!.validate()) {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        dueDate: _selectedDate,
      );

      context.read<TaskProvider>().updateTask(updatedTask).then((_) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
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
              const SizedBox(height: 100),
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
              // Update button
              Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  return ElevatedButton(
                    onPressed: _handleUpdateTask,
                    child: const Text('Update Task'),
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
