import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/quiz.dart';
import '../../core/models/course.dart';
import '../../core/services/data_service.dart';

class AddQuizScreen extends StatefulWidget {
  final String? courseId;
  final Quiz? quiz;
  const AddQuizScreen({super.key, this.courseId, this.quiz});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _titleController = TextEditingController();
  final List<Question> _questions = [];
  String? _selectedCourseId;
  bool _isLoading = false;

  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
    if (widget.quiz != null) {
      _titleController.text = widget.quiz!.title;
      _questions.addAll(widget.quiz!.questions);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        Question(
          questionText: '',
          options: ['', '', '', ''],
          correctOptionIndex: 0,
        ),
      );
    });
  }

  Future<void> _saveQuiz() async {
    if (_titleController.text.isEmpty ||
        _selectedCourseId == null ||
        _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and add at least one question'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newQuiz = Quiz(
        id: widget.quiz?.id ?? '',
        courseId: _selectedCourseId!,
        title: _titleController.text,
        questions: _questions,
      );

      await _dataService.addQuiz(newQuiz);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Quiz', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryPink,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.save, color: AppColors.primaryPink),
              onPressed: _saveQuiz,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quiz Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(_titleController, 'Quiz Title', LucideIcons.type),
            const SizedBox(height: 20),
            _buildCourseDropdown(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Questions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Add Question'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionEditor(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return StreamBuilder<List<Course>>(
      stream: _dataService.streamCourses(),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourseId,
              dropdownColor: AppColors.surface,
              hint: const Text(
                'Select Course',
                style: TextStyle(color: AppColors.textGrey),
              ),
              isExpanded: true,
              items: courses
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedCourseId = val),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionEditor(int index) {
    final q = _questions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  color: AppColors.primaryPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  color: Colors.red,
                  size: 18,
                ),
                onPressed: () => setState(() => _questions.removeAt(index)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => _questions[index] = Question(
              questionText: val,
              options: q.options,
              correctOptionIndex: q.correctOptionIndex,
            ),
            controller: TextEditingController(text: q.questionText),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter question text',
              hintStyle: TextStyle(color: AppColors.textGrey),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Options',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...List.generate(4, (i) {
            return Row(
              children: [
                IconButton(
                  icon: Icon(
                    q.correctOptionIndex == i
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: q.correctOptionIndex == i
                        ? AppColors.primaryPink
                        : AppColors.textGrey,
                  ),
                  onPressed: () => setState(
                    () => _questions[index] = Question(
                      questionText: q.questionText,
                      options: q.options,
                      correctOptionIndex: i,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      final newOpts = List<String>.from(q.options);
                      newOpts[i] = val;
                      _questions[index] = Question(
                        questionText: q.questionText,
                        options: newOpts,
                        correctOptionIndex: q.correctOptionIndex,
                      );
                    },
                    controller: TextEditingController(text: q.options[i]),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      hintStyle: const TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
