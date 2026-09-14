import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// User hiện tại đang đăng nhập
  static User? get currentUser => _client.auth.currentUser;

  /// Kiểm tra có phải người dùng ẩn danh (Guest) hay không
  static bool get isAnonymous {
    final user = _client.auth.currentUser;
    if (user == null) return true;
    return user.isAnonymous;
  }

  /// Stream theo dõi trạng thái thay đổi Auth
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Đảm bảo luôn có 1 phiên đăng nhập (tối thiểu là Anonymous)
  static Future<String> getUserId() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      return user.id;
    }

    try {
      final res = await _client.auth.signInAnonymously();
      if (res.user != null) {
        return res.user!.id;
      }
    } catch (e) {
      debugPrint('Anonymous auth notice: $e');
    }

    return 'anonymous_user';
  }

  /// Đăng nhập bằng Email & Mật khẩu đã có
  static Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.user != null) {
        return null; // Thành công, không có lỗi
      }
      return 'Không thể đăng nhập. Vui lòng thử lại.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Lỗi kết nối: ${e.toString()}';
    }
  }

  /// Đăng ký tài khoản mới hoặc Nâng cấp từ tài khoản Ẩn danh (giữ nguyên dữ liệu cũ)
  static Future<String?> signUpOrUpgrade({
    required String email,
    required String password,
  }) async {
    try {
      final user = _client.auth.currentUser;

      // Nếu đang là phiên ẩn danh, nâng cấp phiên này thành tài khoản thật để không mất dữ liệu DASS-21/Daily log
      if (user != null && user.isAnonymous) {
        try {
          await _client.auth.updateUser(
            UserAttributes(
              email: email.trim(),
              password: password,
            ),
          );
          return null;
        } catch (_) {
          // Nếu cập nhật thất bại (ví dụ tài khoản đã tồn tại), chuyển sang đăng ký mới
        }
      }

      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (res.user != null) {
        return null; // Thành công
      }
      return 'Không thể tạo tài khoản. Vui lòng thử lại.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Lỗi kết nối: ${e.toString()}';
    }
  }

  /// Đăng xuất tài khoản và chuyển về phiên Ẩn danh mới
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // Sau khi đăng xuất, tự động tạo lại một phiên ẩn danh mới để người dùng vẫn ghi nhận được data
      try {
        await _client.auth.signInAnonymously();
      } catch (e) {
        debugPrint('SignOut anonymous fallback error: $e');
      }
    } catch (e) {
      debugPrint('SignOut error: $e');
    }
  }
}
