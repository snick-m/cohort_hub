// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(
      title: "IELTS Cohort",
      home: WebViewExample(),
      theme: ThemeData(
        accentColor: Colors.white,
        primaryColor: Colors.red.shade400,
      ),
    ));

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: InternetAddress.lookup('example.com'),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data.isNotEmpty &&
              snapshot.data[0].rawAddress.isNotEmpty) {
            return Scaffold(
              bottomNavigationBar: BottomAppBar(
                color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[],
                ),
              ),
              // We're using a Builder here so we have a context that is below the Scaffold
              // to allow calling Scaffold.of(context) so we can show a snackbar.
              body: Builder(builder: (BuildContext context) {
                return WebView(
                  initialUrl: 'https://cohort.edvive.com',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                  },
                  // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                  // ignore: prefer_collection_literals
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                  navigationDelegate: (NavigationRequest request) {
                    launch(request.url);
                    return NavigationDecision.prevent;
                    // if (request.url.startsWith('https://www.youtube.com/')) {
                    //   print('blocking navigation to $request}');
                    //   return NavigationDecision.prevent;
                    // }
                    // print('allowing navigation to $request');
                    // return NavigationDecision.navigate;
                  },
                  onPageStarted: (String url) {
                    print('Page started loading: $url');
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                  },
                  gestureNavigationEnabled: true,
                );
              }),
            );
          } else {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                      size: 120,
                      color: Colors.red.shade400,
                    ),
                    Text(
                      "Connect to Internet Please :(",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.refresh_rounded),
                  onPressed: () => setState(() => {})),
            );
          }
        },
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            backgroundBlendMode: BlendMode.multiply,
            color: Colors.black12,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                color: Colors.white,
                onPressed: !webViewReady
                    ? null
                    : () async {
                        if (await controller.canGoBack()) {
                          await controller.goBack();
                        } else {
                          Scaffold.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("No back history item")),
                          );
                          return;
                        }
                      },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                color: Colors.white,
                onPressed: !webViewReady
                    ? null
                    : () {
                        controller.loadUrl("https://www.edvive.com");
                      },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                color: Colors.white,
                onPressed: !webViewReady
                    ? null
                    : () {
                        controller.loadUrl("https://www.edvive.com/aboutus");
                      },
              ),
              IconButton(
                icon: const Icon(Icons.settings_applications_rounded),
                color: Colors.white,
                onPressed: !webViewReady
                    ? null
                    : () {
                        controller.loadUrl("https://www.edvive.com/services");
                      },
              ),
              IconButton(
                icon: const Icon(Icons.event_available_rounded),
                color: Colors.white,
                onPressed: !webViewReady
                    ? null
                    : () {
                        controller.loadUrl("https://www.edvive.com/events");
                      },
              ),
              IconButton(
                icon: const Icon(Icons.person_pin_circle_rounded),
                color: Colors.white,
                onPressed: !webViewReady
                    ? null
                    : () {
                        controller.loadUrl("https://www.edvive.com/producers");
                      },
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                color: Colors.white,
                onPressed: !webViewReady
                    ? null
                    : () {
                        controller.loadUrl("https://www.edvive.com/apply");
                      },
              ),
            ],
          ),
        );
      },
    );
  }
}
