import 'package:supabase_flutter/supabase_flutter.dart';

// Bucket công khai batch_photos (0038): đường dẫn trong bucket → URL hiển thị. 1 chỗ duy nhất cho khách (danh sách,
// chi tiết) và tài xế (SCR-D07 集荷先の詳細).
String? batchPhotoUrl(SupabaseClient client, String? path) =>
    path == null ? null : client.storage.from('batch_photos').getPublicUrl(path);
