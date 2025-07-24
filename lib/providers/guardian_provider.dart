import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/guardian_model.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../core/utils/validation_utils.dart';

class GuardianProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<GuardianModel> _guardians = [];
  GuardianModel? _selectedGuardian;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<GuardianModel> get guardians => _guardians;
  GuardianModel? get selectedGuardian => _selectedGuardian;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize provider
  Future<void> initialize() async {
    await loadGuardians();
  }

  // Load all guardians
  Future<void> loadGuardians() async {
    try {
      _setLoading(true);
      _clearError();

      // Load from storage service (Hive)
      _guardians = _storageService.getAllGuardians();
      
      // If no data in Hive, try loading from SQLite
      if (_guardians.isEmpty) {
        _guardians = await _databaseService.getAllGuardians();
        
        // Save to Hive for faster access
        for (final guardian in _guardians) {
          await _storageService.saveGuardian(guardian);
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load guardians: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new guardian
  Future<bool> addGuardian({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? profession,
    String? emergencyContact,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate input
      if (!ValidationUtils.isValidName(name)) {
        throw Exception('Please enter a valid name');
      }

      if (email != null && email.isNotEmpty && !ValidationUtils.isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (phone != null && phone.isNotEmpty && !ValidationUtils.isValidPhone(phone)) {
        throw Exception('Please enter a valid phone number');
      }

      // Check if guardian with same email already exists
      if (email != null && email.isNotEmpty) {
        final existingGuardian = _guardians.where((g) => g.email?.toLowerCase() == email.toLowerCase()).firstOrNull;
        if (existingGuardian != null) {
          throw Exception('Guardian with this email already exists');
        }
      }

      // Create new guardian
      final guardian = GuardianModel.create(
        id: _uuid.v4(),
        name: name.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        address: address?.trim(),
        profession: profession?.trim(),
        emergencyContact: emergencyContact?.trim(),
        notes: notes?.trim(),
      );

      // Save to storage and database
      await _storageService.saveGuardian(guardian);
      await _databaseService.insertGuardian(guardian);

      // Add to local list
      _guardians.add(guardian);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to add guardian: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing guardian
  Future<bool> updateGuardian({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? address,
    String? profession,
    String? emergencyContact,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate input
      if (!ValidationUtils.isValidName(name)) {
        throw Exception('Please enter a valid name');
      }

      if (email != null && email.isNotEmpty && !ValidationUtils.isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (phone != null && phone.isNotEmpty && !ValidationUtils.isValidPhone(phone)) {
        throw Exception('Please enter a valid phone number');
      }

      // Find existing guardian
      final existingIndex = _guardians.indexWhere((g) => g.id == id);
      if (existingIndex == -1) {
        throw Exception('Guardian not found');
      }

      // Check if email is being changed to one that already exists
      if (email != null && email.isNotEmpty) {
        final existingGuardian = _guardians.where((g) => g.id != id && g.email?.toLowerCase() == email.toLowerCase()).firstOrNull;
        if (existingGuardian != null) {
          throw Exception('Guardian with this email already exists');
        }
      }

      // Update guardian
      final updatedGuardian = _guardians[existingIndex].copyWith(
        name: name.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        address: address?.trim(),
        profession: profession?.trim(),
        emergencyContact: emergencyContact?.trim(),
        notes: notes?.trim(),
      );

      // Save to storage and database
      await _storageService.saveGuardian(updatedGuardian);
      await _databaseService.updateGuardian(updatedGuardian);

      // Update local list
      _guardians[existingIndex] = updatedGuardian;
      
      // Update selected guardian if it's the one being updated
      if (_selectedGuardian?.id == id) {
        _selectedGuardian = updatedGuardian;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update guardian: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete guardian
  Future<bool> deleteGuardian(String id) async {
    try {
      _setLoading(true);
      _clearError();

      // Remove from storage and database
      await _storageService.deleteGuardian(id);
      await _databaseService.deleteGuardian(id);

      // Remove from local list
      _guardians.removeWhere((guardian) => guardian.id == id);

      // Clear selected guardian if it's the one being deleted
      if (_selectedGuardian?.id == id) {
        _selectedGuardian = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete guardian: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select guardian
  void selectGuardian(String id) {
    _selectedGuardian = _guardians.where((guardian) => guardian.id == id).firstOrNull;
    notifyListeners();
  }

  // Clear selected guardian
  void clearSelectedGuardian() {
    _selectedGuardian = null;
    notifyListeners();
  }

  // Search guardians
  List<GuardianModel> searchGuardians(String query) {
    if (query.isEmpty) return _guardians;

    final lowerQuery = query.toLowerCase();
    return _guardians.where((guardian) {
      return guardian.name.toLowerCase().contains(lowerQuery) ||
             (guardian.email?.toLowerCase().contains(lowerQuery) ?? false) ||
             (guardian.phone?.contains(query) ?? false) ||
             (guardian.address?.toLowerCase().contains(lowerQuery) ?? false) ||
             (guardian.profession?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get guardian by ID
  GuardianModel? getGuardianById(String id) {
    return _guardians.where((guardian) => guardian.id == id).firstOrNull;
  }

  // Get guardians by profession
  List<GuardianModel> getGuardiansByProfession(String profession) {
    return _guardians.where((guardian) => 
        guardian.profession?.toLowerCase() == profession.toLowerCase()).toList();
  }

  // Get guardians count
  int get guardiansCount => _guardians.length;

  // Check if guardian exists by email
  bool guardianExistsByEmail(String email) {
    return _guardians.any((guardian) => 
        guardian.email?.toLowerCase() == email.toLowerCase());
  }

  // Check if guardian exists by phone
  bool guardianExistsByPhone(String phone) {
    return _guardians.any((guardian) => guardian.phone == phone);
  }

  // Get guardian statistics
  Map<String, dynamic> getGuardianStatistics() {
    final withEmail = _guardians.where((g) => g.email?.isNotEmpty == true).length;
    final withPhone = _guardians.where((g) => g.phone?.isNotEmpty == true).length;
    final withAddress = _guardians.where((g) => g.address?.isNotEmpty == true).length;
    final withProfession = _guardians.where((g) => g.profession?.isNotEmpty == true).length;

    return {
      'total': _guardians.length,
      'withEmail': withEmail,
      'withPhone': withPhone,
      'withAddress': withAddress,
      'withProfession': withProfession,
    };
  }

  // Sort guardians
  void sortGuardians(SortOption sortOption) {
    switch (sortOption) {
      case SortOption.nameAsc:
        _guardians.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        _guardians.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.emailAsc:
        _guardians.sort((a, b) => (a.email ?? '').compareTo(b.email ?? ''));
        break;
      case SortOption.emailDesc:
        _guardians.sort((a, b) => (b.email ?? '').compareTo(a.email ?? ''));
        break;
      case SortOption.createdAtAsc:
        _guardians.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.createdAtDesc:
        _guardians.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadGuardians();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum SortOption {
  nameAsc,
  nameDesc,
  emailAsc,
  emailDesc,
  createdAtAsc,
  createdAtDesc,
}
