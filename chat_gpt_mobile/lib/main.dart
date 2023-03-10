import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'openai/completions_api.dart';
import 'openai/completions_response.dart';
 
void main() {
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
 
class MyAppState extends ChangeNotifier {
  final user1 = 'Sev';
  final user2 = 'Marc';
 
  var user = '';
 
  void signIn(name) {
    switch(name) {
      case 'Sev':
      user = user1;
      break;
      case 'Marc':
      user = user2;
      break;
      default:
      user = '';
      break;
    }
  }
}
 
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
 
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
 
  @override
  Widget build(BuildContext context) {
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = ProfilePage();
          break;
        case 1:
          page = GeneratorPage();
          break;
        case 2:
          page = const Placeholder();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('My account'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.monetization_on),
                      label: Text('Subscription'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
 
class GeneratorPage extends StatefulWidget {

  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _focusNode = FocusNode();

  var displayText;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OpenaiText(textReq: displayText),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: _formKey,
                    reverse: true,
                    child: Container(
                      margin: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      child: TextFormField(
                        focusNode: _focusNode,
                        onFieldSubmitted: (value) {
                        displayText = value;
                        _controller.clear();
                        setState((){});
                        },
                        controller: _controller,
                        minLines: 1,
                        maxLines: 8,
                        decoration: const InputDecoration(
                        hintText: "Ask me a question",
                        ),
                        textInputAction: TextInputAction.go
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 30),
                  child: ElevatedButton(
                    onPressed: () => {
                      TextInputAction.go,
                      _controller.clear(),
                      displayText = CompletionsApi.getNewForecast(_controller.value.toString()),
                    },
                    child: const Icon(Icons.send),
                  ),
                  
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class OpenaiText extends StatelessWidget {
  final textReq;
  const OpenaiText({super.key, required this.textReq});

  @override
  Widget build(BuildContext context) {  
  if(textReq != null) {
  return FutureBuilder(
  future: CompletionsApi.getNewForecast("Write a reply to the following: $textReq"),
  builder: (BuildContext context, AsyncSnapshot<CompletionsResponse> forecast) {
    if (forecast.hasData) {
      return Text(forecast.data?.choices![0]["text"]);     
    } else {
      // Display a loading indicator while waiting for the forecast
      return const CircularProgressIndicator();
    }
  }
  );
  } else {
    return Container();
  }
  }
}
 
class ProfilePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  ProfilePage({super.key});
 
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(30),
            child: TextField(
              controller: _controller,
              onSubmitted: (value) => {
                appState.signIn(value),
                // ignore: avoid_print
                print(appState.user),
                _controller.clear(),
              },
              decoration: const InputDecoration(
                hintText: 'Sign in with Google',
              ),
            ),
          ),
        ]
      )
    );
  }
}