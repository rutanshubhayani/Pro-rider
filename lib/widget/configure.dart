// ignore_for_file: duplicate_import


import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, rootBundle;


const String oneSingalAPPID = "3afcec9d-d025-4c1a-81fe-b46d71cf6959";
const Color kbgColor = Color(0xFFFFFFFF);
const Color kPrimaryColor = Color(0xFF3d5a80);
// const Color kPrimaryColor = Color(0xFF3d5a80);  secondary color
const Color kPrimaryAppColor = Color(0xFF006B5C);
const Color textPlaceholderColor = Color.fromRGBO(66, 66, 66, 1);
const Color textColor = Color(0xFF1F1F1F);
const Color iconColor = Color(0xFF2C2C2C);

const Color borderColor = Color(0xFFE8E8E8);
const Color shadowColor = Color.fromARGB(255, 224, 224, 224);

const Color expiryColor = Color(0xFFFF9C29);
const Color activeColor = Color(0xFF5BC940);
const Color inactiveColor = Color(0xFFFF2929);
const Color buttonshadowColor = Color(0xFF454545);

//section color
const Color redColor = Color(0xFFc23e2e);
const Color redFontsColor = Color.fromARGB(255, 255, 219, 214);
const Color pinkColor = Color(0xFFa12a60);
const Color pinkFontsColor = Color.fromARGB(255, 255, 203, 227);
const Color blue1Color = Color(0xFF4d67d4);
const Color blue1FontsColor = Color.fromARGB(255, 229, 226, 255);
const Color greenColor = Color.fromRGBO(5, 162, 141, 1);
const Color greenFontsColor = Color.fromRGBO(200, 255, 248, 1);
const Color lemonYellowColor = Color(0xFFFFFACD);
const Color grayDotColor = Color(0xFFE8E8E8);
const Color starndedMaroonColor = Color(0xFFB1005B);
const Color starndedBlueColor = Color(0xFF3183FF);

const Color shimmerbgColor = Color(0xFFCCCCCC);
const Color shimmerOverColor = Color(0xFFF4F4F4);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006B5C),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF77F8DF),
  onPrimaryContainer: Color(0xFF00201B),
  secondary: Color(0xFF006782),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFBBEAFF),
  onSecondaryContainer: Color(0xFF001F29),
  tertiary: Color(0xFF006B5D),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF77F8DF),
  onTertiaryContainer: Color(0xFF00201B),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFF3FFFA),
  onBackground: Color(0xFF00201A),
  surface: Color(0xFFF3FFFA),
  onSurface: Color(0xFF00201A),
  surfaceVariant: Color(0xFFDAE5E1),
  onSurfaceVariant: Color(0xFF3F4946),
  outline: Color(0xFF6F7976),
  onInverseSurface: Color(0xFFB7FFEC),
  inverseSurface: Color(0xFF00382E),
  inversePrimary: Color(0xFF57DBC3),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006B5C),
  outlineVariant: Color(0xFFBEC9C5),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF57DBC3),
  onPrimary: Color(0xFF00382F),
  primaryContainer: Color(0xFF005045),
  onPrimaryContainer: Color(0xFF77F8DF),
  secondary: Color(0xFF60D4FE),
  onSecondary: Color(0xFF003545),
  secondaryContainer: Color(0xFF004D62),
  onSecondaryContainer: Color(0xFFBBEAFF),
  tertiary: Color(0xFF57DBC3),
  onTertiary: Color(0xFF00382F),
  tertiaryContainer: Color(0xFF005045),
  onTertiaryContainer: Color(0xFF77F8DF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF00201A),
  onBackground: Color(0xFF79F8DC),
  surface: Color(0xFF00201A),
  onSurface: Color(0xFF79F8DC),
  surfaceVariant: Color(0xFF3F4946),
  onSurfaceVariant: Color(0xFFBEC9C5),
  outline: Color(0xFF89938F),
  onInverseSurface: Color(0xFF00201A),
  inverseSurface: Color(0xFF79F8DC),
  inversePrimary: Color(0xFF006B5C),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF57DBC3),
  outlineVariant: Color(0xFF3F4946),
  scrim: Color(0xFF000000),
);



class NoEmojiInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Regular expression to match emoji characters
    final emojiRegExp = RegExp(
      r'[\u{1F600}-\u{1F64F}' // emoticons
      r'\u{1F300}-\u{1F5FF}' // symbols & pictographs
      r'\u{1F680}-\u{1F6FF}' // transport & map symbols
      r'\u{1F700}-\u{1F77F}' // alchemical symbols
      r'\u{1F780}-\u{1F7FF}' // Geometric Shapes Extended
      r'\u{1F800}-\u{1F8FF}' // Supplemental Arrows-C
      r'\u{1F900}-\u{1F9FF}' // Supplemental Symbols and Pictographs
      r'\u{1FA00}-\u{1FA6F}' // Chess Symbols
      r'\u{1FA70}-\u{1FAFF}' // Symbols and Pictographs Extended-A
      r'\u{2600}-\u{26FF}' // Miscellaneous Symbols
      r'\u{2700}-\u{27BF}]', // Dingbats
      unicode: true,
      multiLine: true,
    );

    final newText = newValue.text.replaceAll(emojiRegExp, '');
    return newText == newValue.text
        ? newValue
        : TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}


class ActionButton extends StatelessWidget {
  final String label;
  final String? tootltipmessage;
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.label,
    required this.icon,
     this.tootltipmessage,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: tootltipmessage ?? '',
      child: MaterialButton(
        color: kPrimaryColor,
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Adjust as needed
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Adjust padding as needed
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white), // Icon passed as a parameter
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CustomDialog {
  static Future<bool> show(
      BuildContext context, {
        required String title,
        required String content,
        String cancelButtonText = 'Cancel',
        String confirmButtonText = 'OK',
        VoidCallback? onConfirm,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 7,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                    child: Text(
                      cancelButtonText,
                      style: TextStyle(color: kPrimaryColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false); // Close the dialog and return false
                    },
                  ),
                ),
                SizedBox(width: 7),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 7,
                      backgroundColor: kPrimaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      confirmButtonText,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (onConfirm != null) onConfirm(); // Execute onConfirm if provided
                      Navigator.of(context).pop(true); // Close the dialog and return true
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Return false if the dialog was dismissed
  }
}
