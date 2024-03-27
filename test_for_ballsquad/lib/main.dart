import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';


bool isInForm = false;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Author Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class SearchBloc extends Cubit<String> {
  SearchBloc() : super('');

  void updateQuery(String query) {
    emit(query);
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Authors'),
      ),
      body: BlocProvider(
        create: (_) => SearchBloc(),
        child: SearchForm(),
      ),
    );
  }
}

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (query) => searchBloc.updateQuery(query),
            decoration: InputDecoration(
              hintText: 'Enter author name',
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<SearchBloc, String>(
            builder: (context, query) {
              return FutureBuilder(
                future: getData(query),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if(snapshot.connectionState == ConnectionState.none){
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List? authors = snapshot.data;
                    if (authors!.isEmpty) {
                      return Center(
                        child: Container(
                          color: Colors.red,
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Author not found.',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white, 
                              
                            ),
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: authors.length,
                        itemBuilder: (context, index) {
                          return AuthorItem(
                            author: authors[index]['name'],
                            birthDate: authors[index]['birth_date'] ?? 'Unknown', // Handle null birth date
                            deathDate: authors[index]['death_date'], // Handle null death date
                            topWork: authors[index]['top_work'] ?? 'Unknown', // Handle null top work
                          );
                        },
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<dynamic>> getData(String query) async {
  try {
    if (query.trim().isEmpty) {
      // Form is empty, return an empty list
      return [];
    } else {
      // Form is not empty, proceed with API call
      var response = await Dio().get('https://openlibrary.org/search/authors.json?q=${query.replaceAll(' ', '%20')}');
      return response.data['docs'];
    }
  } catch (e) {
    print(e);
    return [];
  }
}
}

class AuthorItem extends StatefulWidget {
  final String author;
  final String birthDate;
  final String? deathDate;
  final String topWork;

  AuthorItem({required this.author, required this.birthDate, this.deathDate, required this.topWork});

  @override
  _AuthorItemState createState() => _AuthorItemState();
}

class _AuthorItemState extends State<AuthorItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            color: _isExpanded ? Colors.blue.withOpacity(0.3) : null,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.author,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text(
                  'Birth Date: ${widget.birthDate}',
                  style: TextStyle(fontSize: 16.0),
                ),
                if (widget.deathDate != null)
                  SizedBox(height: 4.0),
                  Text(
                    'Death Date: ${widget.deathDate ?? 'Unknown'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                SizedBox(height: 4.0),
                Text(
                  'Top Work: "${widget.topWork}"',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
          Divider(),
        ],
      ],
    );
  }
}
