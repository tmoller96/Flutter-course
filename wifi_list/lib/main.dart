import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wifi_configuration_2/wifi_configuration_2.dart';

WifiConfiguration wifiConfiguration;
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _platformVersion = 'Unknown';
  List<WifiNetwork> wifiNetworkList = List();
  bool isLoaded = false;
  bool isWifiEnabled = true;
  WifiConnectionStatus _connectionStatus;

  @override
  void initState() {
    wifiConfiguration = WifiConfiguration();
    WidgetsBinding.instance.addObserver(this);
    _checkWifiEnabled();
    _getWifiList();
    _checkConnection();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("State: $state");
    if (state == AppLifecycleState.resumed) {
      _checkWifiEnabled();
    }
    super.didChangeAppLifecycleState(state);
  }

  void _getWifiList() async {
    wifiNetworkList = await wifiConfiguration.getWifiList();
    isLoaded = true;
    print('Network list lenght: ${wifiNetworkList.length.toString()}');
    setState(() {});
  }

  Future<WifiConnectionStatus> _connectToWifi(
      String ssid, String password) async {
    _connectionStatus = await wifiConfiguration.connectToWifi(
        ssid, password, "com.example.wifi_list");
    print("is Connected : $_connectionStatus");
    setState(() {});
    return _connectionStatus;
  }

  void _startConnectToWifi(BuildContext ctx, String ssid) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return ConnectToWifi(ssid, _connectToWifi);
        });
  }

  void _checkConnection() async {
    bool isConnected = await wifiConfiguration.checkConnection();
    if (isConnected) {
      _connectionStatus = WifiConnectionStatus.connected;
    } else {
      _connectionStatus = WifiConnectionStatus.notConnected;
    }
    setState(() {});
  }

  void _checkWifiEnabled() async {
    isWifiEnabled = await wifiConfiguration.isWifiEnabled();
    setState(() {});
  }

  String _getConnectionStatus() {
    switch (_connectionStatus) {
      case WifiConnectionStatus.connected:
        return "Connected";
        break;

      case WifiConnectionStatus.alreadyConnected:
        return "Already connected";
        break;

      case WifiConnectionStatus.notConnected:
        return "Not connected";
        break;

      case WifiConnectionStatus.platformNotSupported:
        return "Platform not supported";
        break;

      case WifiConnectionStatus.profileAlreadyInstalled:
        return "Profile already installed";
        break;

      case WifiConnectionStatus.locationNotAllowed:
        return "Location not allowed";
        break;
    }
  }

  Widget _showEnableWifiWidget() {
    return Center(
      child: Text("Please turn on Wifi"),
    );
  }

  Widget _showLoadingWifiListWidget() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        CircularProgressIndicator(),
        Text("Loading available Wifi connections..."),
      ],
    );
  }

  Widget _showWifiList() {
    return Column(children: [
      Expanded(
        child: ListView.builder(
          itemCount: wifiNetworkList.length,
          itemBuilder: (context, index) {
            WifiNetwork wifiNetwork = wifiNetworkList[index];
            return InkWell(
              onTap: () =>
                  _startConnectToWifi(context, wifiNetworkList[index].ssid),
              child: ListTile(
                leading: Text(wifiNetwork.signalLevel),
                title: Text(wifiNetwork.ssid),
                subtitle: Text(wifiNetwork.bssid),
              ),
            );
          },
        ),
      ),
      Text("Status: ${_getConnectionStatus()}"),
      RaisedButton(
        onPressed: _getWifiList,
        child: Text("Refresh"),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: !isWifiEnabled
                ? _showEnableWifiWidget()
                : isLoaded ? _showWifiList() : _showLoadingWifiListWidget()),
      ),
    );
  }
}

class ConnectToWifi extends StatelessWidget {
  final String ssid;
  final Function connectToWifi;

  ConnectToWifi(this.ssid, this.connectToWifi);

  final _passwordController = TextEditingController();

  void _submitPassword(BuildContext context) async {
    final enteredPassword = _passwordController.text;
    WifiConnectionStatus status = await connectToWifi(ssid, enteredPassword);
    if (status == WifiConnectionStatus.connected) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(ssid),
        ),
        Center(
          child: Text("Enter password"),
        ),
        TextField(
          decoration: InputDecoration(labelText: "Password"),
          controller: _passwordController,
          onSubmitted: (_) => _submitPassword(context),
        )
      ],
    );
  }
}
