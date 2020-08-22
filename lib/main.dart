import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:friend_favor/favor.dart';
import 'package:friend_favor/friend.dart';
import 'package:friend_favor/mock_values.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friend Favor',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FavorsPage(
      ),
    );
  }
}

class FavorsPage extends StatefulWidget {
  FavorsPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FavorsPageState();
}

class FavorsPageState extends State<FavorsPage> {
  // using mock values from mock_favors dart file for now
  List<Favor> pendingAnswerFavors;
  List<Favor> acceptedFavors;
  List<Favor> completedFavors;
  List<Favor> refusedFavors;

  @override  void initState() {
    super.initState();
    pendingAnswerFavors = List();
    acceptedFavors = List();
    completedFavors = List();
    refusedFavors = List();
    loadFavors();
  }

  void loadFavors() {
    pendingAnswerFavors.addAll(mockPendingFavors);
    acceptedFavors.addAll(mockDoingFavors);
    completedFavors.addAll(mockCompletedFavors);
    refusedFavors.addAll(mockRefusedFavors);
  }

  // part of FavorsPageState class
  static FavorsPageState of(BuildContext context) {
    return context.findAncestorStateOfType<FavorsPageState>();
  }

  void refuseToDo(Favor favor) {
    setState(() {
      pendingAnswerFavors.remove(favor);
      refusedFavors.add(favor.copyWith(accepted: false));
    });
  }

  void acceptToDo(Favor favor) {
      setState(() {
        pendingAnswerFavors.remove(favor);

        acceptedFavors.add(favor.copyWith(accepted: true));
      });
  }

  Widget _buildCategoryTab(String title) {
      return Tab(
        child: Text(title),
      );
    }

    Row _itemHeader(Favor favor) {
      return Row(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
              favor.friend.photoURL,
            ),
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text("${favor.friend.name} asked you to...")
            ),
          ),
        ],
      );
    }

    Widget _itemFooter(Favor favor) {
      if (favor.isCompleted) {
        final format = DateFormat();
        return Container(
          margin: EdgeInsets.only(top: 8.0),
          alignment: Alignment.centerRight,
          child: Chip(
            label: Text("Completed at: ${format.format(favor.completed)}"),
          ),
        );
      }
      if (favor.isRequested) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text("Refuse"),
              onPressed: () {
                FavorsPageState.of(context).refuseToDo(favor);
                // we have changed _itemFooter to get the context so we
                // can use it to fetch the favors page state
              },
            ),
            FlatButton(
              child: Text("Do"),
              onPressed: () {
                FavorsPageState.of(context).acceptToDo(favor);
              },
            )
          ],
        );
      }
      if (favor.isDoing) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text("give up"),
              onPressed: () {},
            ),
            FlatButton(
              child: Text("complete"),
              onPressed: () {},
            )
          ],
        );
      }
      return Container();
    }

    Widget _favorsList(String title, List<Favor> favors) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            child: Text(title),
            padding: EdgeInsets.only(top: 16.0),
          ),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: favors.length,
              itemBuilder: (BuildContext context, int index) {
                final favor = favors[index];
                return Card(
                  key: ValueKey(favor.uuid),
                  margin: EdgeInsets.symmetric(vertical: 10.0,
                      horizontal: 25.0),
                  child: Padding(
                    child: Column(
                      children: <Widget>[
                        _itemHeader(favor),
                        Text(favor.description),
                        _itemFooter(favor)
                      ],
                    ),
                    padding: EdgeInsets.all(8.0),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    @override Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your favors"),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              _buildCategoryTab("Requests"),
              _buildCategoryTab("Doing"),
              _buildCategoryTab("Completed"),
              _buildCategoryTab("Refused"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _favorsList("Pending Requests", pendingAnswerFavors),
            _favorsList("Doing", acceptedFavors),
            _favorsList("Completed", completedFavors),
            _favorsList("Refused", refusedFavors),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RequestFavorPage(
                  friends: mockFriends,
                ),
              ),
            );
          },
          tooltip: 'Ask a favor',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}


class RequestFavorPage extends StatefulWidget {
  List<Friend> friends;

  RequestFavorPage({Key key, this.friends}) : super(key: key);

  @override
  RequestFavorPageState createState() {
    return new RequestFavorPageState();
  }
}

class RequestFavorPageState extends State<RequestFavorPage> {
  final _formKey = GlobalKey<FormState>();
  Friend _selectedFriend = null;

  static RequestFavorPageState of(BuildContext context) {
    return context.findAncestorStateOfType<RequestFavorPageState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requesting a favor"),
        leading: CloseButton(),
        actions: <Widget>[
          Builder(
            builder: (context) => FlatButton(
              child: Text("SAVE"),
              textColor: Colors.white,
              onPressed: () {
                RequestFavorPageState.of(context).save();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<Friend>(
                value: _selectedFriend,
                onChanged: (friend) {
                  setState(() {
                    _selectedFriend = friend;
                  });
                },
                items: widget.friends
                    .map(
                      (f) => DropdownMenuItem<Friend>(
                    value: f,
                    child: Text(f.name),
                  ),
                )
                    .toList(),
                validator: (friend) {
                  if (friend == null) {
                    return "You must select a friend to ask the favor";
                  }
                  return null;
                },
              ),
              Container(
                height: 16.0,
              ),
              Text("Favor description:"),
              TextFormField(
                maxLines: 5,
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                validator: (value) {
                  if (value.isEmpty) {
                    return "You must detail the favor";
                  }
                  return null;
                },
              ),
              Container(
                height: 16.0,
              ),
              Text("Due Date:"),
              DateTimePickerFormField(
                inputType: InputType.both,
                format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                editable: false,
                decoration: InputDecoration(
                    labelText: 'Date/Time', hasFloatingPlaceholder: false),
                validator: (dateTime) {
                  if (dateTime == null) {
                    return "You must select a due date time for the favor";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void save() {
    if (_formKey.currentState.validate()) {
      // store the favor request on firebase
      Navigator.pop(context);
    }
  }
}
