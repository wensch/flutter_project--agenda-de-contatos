import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final contactTable = 'contactTable';
final idColumn = 'idColumn';
final nameColumn = 'nameColumn';
final emailColumn = 'emailColumn';
final phoneColumn = 'phoneColumn';
final imgColumn = 'imgColumn';

class ContatcHelper {
	static final ContatcHelper _instance = ContatcHelper.internal();
	
	factory ContatcHelper() => _instance;

	ContatcHelper.internal();

	Database _db;

	Future<Database> get db async {
		if (_db != null) {
			return _db;
		} else {
			_db = await initDb();
			return _db;
		}
	}

	Future<Database> initDb() async {
		final databasePath = await getDatabasesPath();
		final path = join(databasePath, 'contactsnew.db');

		return await openDatabase(path, version: 1, onCreate: (Database db, int newVersion) async {
			await db.execute(
				"CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
			);
		});
	}

	Future<Contact> saveContact(Contact contact) async{
		Database dbContact = await db;
		contact.id = dbContact.insert(contactTable, contact.toMap());
		return contact;
	}

	Future<Contact> getContact(int id) async {
		Database dbContact = await db;
		List<Map> maps = await dbContact.query(contactTable, 
		columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
		where: "$idColumn = ?",
		whereArgs: [id]);
		if (maps.length > 0) {
			return Contact.fromMap(maps.first);
		} else {
			return null;
		}
	}

  Future deleteContact(id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (var m in listMap) {
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  var id;
  var name;
  var email;
  var phone;
  var img;

  Contact();

  Contact.fromMap(map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}