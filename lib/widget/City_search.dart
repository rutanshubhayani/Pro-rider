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

    widget.focusNode.addListener(() {
      if (!widget.focusNode.hasFocus) {
        setState(() {
          showSuggestions = false;
        });
      }
    });
  }

  void _handleOutsideTap() {
    FocusScope.of(context).unfocus();
    setState(() {
      showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleOutsideTap, // Handle outside tap
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
                onPressed: () {
                  widget.onClear();
                  setState(() {
                    showSuggestions = false;
                  });
                },
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
                showSuggestions = value.isNotEmpty;
              });
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
          ),
          if (showSuggestions)
            SizedBox(height: 10),
          if (showSuggestions)
            Card(
              elevation: 4.0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 280,
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
                          setState(() {
                            showSuggestions = false;
                          });
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
