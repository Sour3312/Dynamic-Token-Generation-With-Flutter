// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, unused_label, unnecessary_brace_in_string_interps, non_constant_identifier_names, unused_local_variable
//last wala yehi hai

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var userInput, AT, request, myToken, sorted, acc_tok, SortedData, ApiData;

// 1st Function for token generation
  getToken() async {
    request = https.Request(
        'POST',
        Uri.parse(
            'https://outpost.mapmyindia.com/api/security/oauth/token?grant_type=client_credentials&client_id=33OkryzDZsIGK9G3_WHFl8XTYLtqIgYh9kRECAhCLNPOFsP6OUvE32EyLCzy9ABln_n9_H1lybhr0DfhqKCRmQ==&client_secret=lrFxI-iSEg_qd-T6n9as4_7fk2WPyKtFb2UomHe1n3bYmHVYbOjX-LONO_lj7mnSudXW433Iq-VywW8fVlDXFc6_2xIeyyww'));
    https.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var statusOfRespnse = response.reasonPhrase;
      print("Your current status is : $statusOfRespnse");

      AT = await response.stream.bytesToString();
      myToken = json.decode(AT);
      // print("MyToken: ${myToken}");

      acc_tok = myToken["access_token"];
      print("Your access token is: ${acc_tok}");
    } else {
      print(response.reasonPhrase);
    }
    getApi(userInput);
  }

//2nd  Function for calling API
  getApi(value) async {
    final respon = await https.get(
        Uri.parse(
            'https://atlas.mappls.com/api/places/search/json?query=${userInput}'),
        headers: {
          'Access-Control-Allow-Origin': "*",
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS',
          'cors': '*',
          HttpHeaders.authorizationHeader: "bearer ${acc_tok}",
        });
    ApiData = await json.decode(respon.body);

    return ApiData;
  }

//main
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      //AppBar
      appBar: AppBar(
          titleSpacing: 40.0,
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: TextField(
                onChanged: (value) {
                  userInput = value;
                  print("userInput is: $userInput");
                  setState(() {
                    // getApi(value);
                    getToken();
                  });
                  // print(value);
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          userInput = Null;
                          print("pressed");
                        });
                      },
                    ),
                    hintText: 'Search here...',
                    border: InputBorder.none),
              ),
            ),
          )),

      //body
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
                future: getApi(userInput), //jaha se data load hoga
                builder: (context, dynamic snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data['suggestedLocations'].length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                  "${snapshot.data["suggestedLocations"][index]["placeAddress"]}"),
                              subtitle: Text(
                                  "${snapshot.data["suggestedLocations"][index]["placeName"]}"),
                            ),
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })
          ],
        ),
      ),
    ));
  }
}
