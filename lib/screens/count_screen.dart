import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/model/exercise_data.dart';
import 'package:gym_app/model/message.dart';
import 'package:gym_app/model/rep_data.dart';
import 'package:gym_app/model/user_model.dart';
import 'package:gym_app/screens/home_screen.dart';
import 'package:gym_app/screens/login_screen.dart';
import 'package:gym_app/tabs/current_tab.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:scoped_model/scoped_model.dart';

class CountScreen extends StatefulWidget {

  @override
  _CountScreenState createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {

  // Leitor QR-Code
  String barcode = "";

  // MQTT
  String broker = 'test.mosquitto.org';
  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;

  StreamSubscription subscription;

  TextEditingController topicController = TextEditingController();
  Set<String> topics = Set<String>();

  List<Message> messages = <Message>[];
  ScrollController messageController = ScrollController();

  bool isConnectiong = false;

  @override
  initState() {
    super.initState();
    _connect();

    scan();
  }

  @override
  Widget build(BuildContext context) {
    if(isConnectiong)
      return Center(child: CircularProgressIndicator(),);
    else return ScopedModelDescendant<UserModel>(
        builder: (context, child, model){
          return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 70.0,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text("Counter", style: TextStyle(fontSize: 30.0),textAlign: TextAlign.center,),
                      )
                    ],
                  ),
                  SizedBox(height: 60.0,),
                  Container(
                    child: Text(client?.connectionState == mqtt.MqttConnectionState.connected
                        ? (messages.length == 0 || messages.last.message == "START" || messages.last.message == "STOP") ? '-' : messages.last.message
                        : 'E', style: TextStyle(fontSize: 200.0),),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                              color: Colors.white,
                              child: Text("Start", style: TextStyle(fontSize: 15.0, color: Colors.red),),
                              onPressed: (){
                                model.startRep();
                                _sendMessage("START", "testePaulo");
                              }
                          ),
                        ),
                        Expanded(
                          child: RaisedButton(
                              color: Colors.white,
                              child: Text("Stop", style: TextStyle(fontSize: 15.0, color: Colors.red),),
                              onPressed: (){
                                model.saveRep({"times": messages.last.message, "weight": 120});
                                _sendMessage("STOP", "testePaulo");
                              }
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Container(
                          height: 300.0,
                          child: FutureBuilder<QuerySnapshot>(
                            future: Firestore.instance.collection("users").document(model.firebaseUser.uid).collection("trainings").document(model.trainingID).collection("exercises").document(model.exerciseID).collection("rep").getDocuments(),
                            builder: (context, snapshot){
                              return ListView.builder(
                                  padding: EdgeInsets.all(4.0),
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index){
                                    return _buildExerciseList(RepData.fromDocument(snapshot.data.documents[index]));
                                  }

                              );
                            },
                          ))
                  ),
                  SizedBox(height: 15.0,),
                  SizedBox(
                    height: 40.0,
                    child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        child: Text("Save Exercise", style: TextStyle(fontSize: 20.0, color: Colors.white),),
                        onPressed: (){
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context)=> CurrentTab())
                          );
                          _unsubscribeFromTopic("testePaulo");
                          _disconnect();

                        }
                    ),
                  ),

                ],
              )

          );
        }
    );



  }

  Widget _buildExerciseList(RepData data) {
    return Card(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Text("${data.times}x", style: TextStyle(color: Colors.red, fontSize: 10.0),),
                  Text("${data.weight.toString()}kg", style: TextStyle(color: Colors.red, fontSize: 10.0),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    }
  }

  void _connect() async {

    isConnectiong = true;
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    client = mqtt.MqttClient(broker, '');

    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    // client.useWebSocket = true;

    /// This flag causes the mqtt client to use an alternate method to perform the WebSocket handshake. This is needed for certain
    /// matt clients (Particularly Amazon Web Services IOT) that will not tolerate additional message headers in their get request
    // client.useAlternateWebSocketImplementation = true;
    // client.port = 443; // ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.

    /// Set logging on if needed, defaults to off
    client.logging(on: true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId2')
    // Must agree with the keep alive set above or not set
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
    // If you set this you must set a will message
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
    } catch (e) {
      print(e);
      print("FALHO");
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionState;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);

    isConnectiong = false;

    _subscribeToTopic("testePaulo");

  }

  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      topics.clear();
      connectionState = client.connectionState;
      client = null;
      subscription.cancel();

      subscription = null;
    });
    print('MQTT client disconnected');
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
    event[0].payload as mqtt.MqttPublishMessage;
    final String message =
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);
    setState(() {
      messages.add(Message(
        topic: event[0].topic,
        message: message,
        qos: recMess.payload.header.qos,
      ));
      try {
        messageController.animateTo(
          0.0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // ScrollController not attached to any scroll views.
      }
    });
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      setState(() {
        if (topics.add(topic.trim())) {
          print('Subscribing to ${topic.trim()}');
          client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
        }
      });
    }
  }

  void _unsubscribeFromTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      setState(() {
        if (topics.remove(topic.trim())) {
          print('Unsubscribing from ${topic.trim()}');
          client.unsubscribe(topic);
        }
      });
    }
  }

  void _sendMessage(String message, String topic) {

    if (connectionState == mqtt.MqttConnectionState.connected) {
      final mqtt.MqttClientPayloadBuilder builder =
      mqtt.MqttClientPayloadBuilder();
      setState(() {
        print("dentro funcao");
        builder.addString(message);
        client.publishMessage(
          topic,
          mqtt.MqttQos.values[0],
          builder.payload,
          retain: false,
        );
      });
    }

  }

}