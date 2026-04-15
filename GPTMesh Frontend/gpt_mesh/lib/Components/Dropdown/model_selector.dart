import 'package:flutter/material.dart';

enum AIModel {
  openai,
  gemini,
  claude,
  deepseek,
}

class ModelSelector extends StatelessWidget {
  final AIModel selectedModel;
  final Function(AIModel) onChanged;

  const ModelSelector({
    super.key,
    required this.selectedModel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AIModel> (
      value: selectedModel,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(
          value: AIModel.openai,
          child: Text("OpenAI"),
        ),
        DropdownMenuItem(
          value: AIModel.gemini,
          child: Text("Gemini"),
        ),
        DropdownMenuItem(
          value: AIModel.claude,
          child: Text("Claude"),
        ),
        DropdownMenuItem(
          value: AIModel.deepseek,
          child: Text("DeepSeek"),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}