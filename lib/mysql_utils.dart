import 'package:mysql1/mysql1.dart';

class MysqlUtils {
  static final settings = ConnectionSettings(
    host: 'dbpsb-pemwebbasdat.f.aivencloud.com', 
    port: 15792,
    user: 'avnadmin',
    password: 'AVNS_gREu8LMcDggh05KsGWI',
    db: 'defaultdb',
  );
  static late MySqlConnection conn;

  static void initConnection() async {
    conn = await MySqlConnection.connect(settings);
  }

  static Future<MySqlConnection> getConnection() async {
    return await MySqlConnection.connect(settings);
  }
}