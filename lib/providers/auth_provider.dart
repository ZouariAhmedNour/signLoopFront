import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

/// Contient l'utilisateur connecté (ou null si non connecté)
final authProvider = StateProvider<User?>((ref) => null);
