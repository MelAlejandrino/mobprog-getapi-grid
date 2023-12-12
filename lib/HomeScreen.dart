import 'package:api/Model.dart';
import 'package:api/ProductScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Album>> futureAlbums;

  @override
  void initState() {
    super.initState();
    futureAlbums = getAlbums();
  }

  Future<List<Album>> getAlbums() async {
    await dotenv.load();
    String env = dotenv.get('ACCESS_TOKEN', fallback: 'sane-default');
    String accessToken = env;
    final response = await http.get(Uri.parse(
        "https://graph.facebook.com/v17.0/me/feed?access_token=$accessToken&fields=id,message,full_picture"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> albumsData = data['data'];

      List<Album> albums = albumsData.map((albumData) {
        return Album.fromJson(albumData);
      }).toList();

      return albums;
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mary Crochet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: FutureBuilder<List<Album>>(
          future: futureAlbums,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final album = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductScreen(
                                  imageUrl: album.imageUrl,
                                  title: album.title)));
                    },
                    child: ListTile(
                      title: Image.network(album.imageUrl),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
