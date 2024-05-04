import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class Categoriespage extends StatefulWidget {
  final String title;
  final String catImage;
  final String tag;

  const Categoriespage({
    Key? key,
    required this.title,
    required this.catImage,
    required this.tag,
  }) : super(key: key);

  @override
  State<Categoriespage> createState() => _CategoriespageState();
}

Widget productsUI(
    String category,
    String pName,
    String price,
    String pid,
    String image,
    String type,
    String description,
    ) {
  return GestureDetector(
    onTap: () {
      // Handle the onTap event
    },
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Stack(
              children: [
                Container(
                  height: 140,
                  width: 160,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  height: 140,
                  width: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            pName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

class _CategoriespageState extends State<Categoriespage> {
  final ref = FirebaseDatabase.instance.reference().child('Products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              backgroundColor: Colors.white,
              expandedHeight: 140,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        widget.catImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [
                          Colors.black.withOpacity(.0),
                          Colors.black.withOpacity(.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Expanded(
              child: FirebaseAnimatedList(
                defaultChild: Text('loading'),
                query: ref,
                itemBuilder: (context, snapshot, animation, index) {
                  return productsUI(
                    snapshot.child('category').value.toString(),
                    snapshot.child('pName').value.toString(),
                    snapshot.child('price').value.toString(),
                    snapshot.child('pid').value.toString(),
                    snapshot.child('image').value.toString(),
                    snapshot.child('type').value.toString(),
                    snapshot.child('description').value.toString(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
