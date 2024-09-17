import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CitySearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool showSuggestions;
  final List<dynamic> suggestions;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final Function() onClear;
  final Function(dynamic) onSuggestionTap;
  final String? Function(String?)? validator; // External validator function

  const CitySearchField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.showSuggestions,
    required this.suggestions,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onSuggestionTap,
    this.validator, // Add validator to the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            filled: true,
            prefixIcon: Icon(Icons.location_on),
            hintText: hintText,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
              icon: FaIcon(FontAwesomeIcons.times),
              onPressed: onClear,
            )
                : null,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: (value) {
            // Call the external validator if provided
            final externalValidationResult = validator?.call(value);
            if (externalValidationResult != null) {
              return externalValidationResult;
            }
            // Add any additional internal validation if needed
            if (value == null || value.isEmpty) {
              return 'Please fill in this field';
            }
            return null;
          }, // Combine external and internal validation
        ),
        if (showSuggestions)
          SizedBox(height: 10), // Add space between field and suggestions
        if (showSuggestions)
          Card(
            elevation: 4.0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 340, // Limit the height of the suggestions container
              ),
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('${suggestion['city']}, ${suggestion['pname']}'),
                      onTap: () => onSuggestionTap(suggestion),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
