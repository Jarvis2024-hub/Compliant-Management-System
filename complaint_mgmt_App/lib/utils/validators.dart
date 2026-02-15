class Validators {
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  static String? validateResponse(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a response';
    }
    return null;
  }
}