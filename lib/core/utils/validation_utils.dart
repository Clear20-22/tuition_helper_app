class ValidationUtils {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates phone number (Bangladesh format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and dashes
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Bangladesh phone number regex (supports both local and international format)
    final phoneRegex = RegExp(r'^(\+88)?01[3-9]\d{8}$');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Please enter a valid Bangladesh phone number';
    }

    return null;
  }

  /// Validates required field
  static String? validateRequired(
    String? value, [
    String fieldName = 'This field',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(
    String? value,
    int minLength, [
    String fieldName = 'This field',
  ]) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, [
    String fieldName = 'This field',
  ]) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates name (only letters and spaces)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Validates password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validates confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates amount (currency)
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  /// Validates grade/class
  static String? validateGrade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Grade is required';
    }

    final gradeRegex = RegExp(
      r'^(Class\s)?(1|2|3|4|5|6|7|8|9|10|11|12|SSC|HSC|A\sLevel|O\sLevel)$',
      caseSensitive: false,
    );
    if (!gradeRegex.hasMatch(value.trim())) {
      return 'Please enter a valid grade (e.g., Class 10, SSC, HSC)';
    }

    return null;
  }

  /// Validates date format
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validates time format (HH:mm)
  static String? validateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Time is required';
    }

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value.trim())) {
      return 'Please enter time in HH:mm format';
    }

    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates multiple fields at once
  static Map<String, String?> validateForm(
    Map<String, dynamic> formData,
    Map<String, String? Function(String?)> validators,
  ) {
    final errors = <String, String?>{};

    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final validator = entry.value;
      final value = formData[fieldName]?.toString();

      errors[fieldName] = validator(value);
    }

    return errors;
  }

  /// Checks if form has any errors
  static bool hasErrors(Map<String, String?> errors) {
    return errors.values.any((error) => error != null);
  }

  /// Gets first error message from validation errors
  static String? getFirstError(Map<String, String?> errors) {
    for (final error in errors.values) {
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  // Boolean validation methods for convenience
  
  /// Checks if email is valid (returns boolean)
  static bool isValidEmail(String? value) {
    return validateEmail(value) == null;
  }

  /// Checks if phone is valid (returns boolean)
  static bool isValidPhone(String? value) {
    return validatePhone(value) == null;
  }

  /// Checks if name is valid (returns boolean)
  static bool isValidName(String? value) {
    return validateName(value) == null;
  }

  /// Checks if password is valid (returns boolean)
  static bool isValidPassword(String? value) {
    return validatePassword(value) == null;
  }

  /// Checks if amount is valid (returns boolean)
  static bool isValidAmount(String? value) {
    return validateAmount(value) == null;
  }

  /// Checks if grade is valid (returns boolean)
  static bool isValidGrade(String? value) {
    return validateGrade(value) == null;
  }

  /// Checks if date is valid (returns boolean)
  static bool isValidDate(String? value) {
    return validateDate(value) == null;
  }

  /// Checks if time is valid (returns boolean)
  static bool isValidTime(String? value) {
    return validateTime(value) == null;
  }

  /// Checks if URL is valid (returns boolean)
  static bool isValidUrl(String? value) {
    return validateUrl(value) == null;
  }
}
