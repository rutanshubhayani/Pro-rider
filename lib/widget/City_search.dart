import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'configure.dart';

class CitySearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool showSuggestions;
  final List<dynamic> suggestions;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final Function() onClear;
  final Function(dynamic) onSuggestionTap;
  final String? Function(String?)? validator;

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
    this.validator,
  }) : super(key: key);

  @override
  _CitySearchFieldState createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        showSuggestions = widget.controller.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          showSuggestions = false; // Close suggestions when tapping outside
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on),
              hintText: widget.hintText,
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                icon: FaIcon(FontAwesomeIcons.times),
                onPressed: widget.onClear,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  width: 2.0,
                  color: Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  width: 2.0,
                  color: kPrimaryColor,
                ),
              ),
            ),

            textInputAction: TextInputAction.next,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {
                showSuggestions = value.isNotEmpty; // Update suggestion visibility
              });
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: (value) {
              // Only call the external validator if it is provided
              if (widget.validator != null) {
                return widget.validator!(value);
              }
              // Allow empty values without an error if no validator is provided
              return null;
            },
          ),
          if (widget.showSuggestions)
            SizedBox(height: 10),
          if (widget.showSuggestions)
            Card(
              elevation: 4.0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 340,
                ),
                child: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = widget.suggestions[index];
                      return ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text('${suggestion['city']}, ${suggestion['pname']}'),
                        onTap: () {
                          widget.onSuggestionTap(suggestion);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
