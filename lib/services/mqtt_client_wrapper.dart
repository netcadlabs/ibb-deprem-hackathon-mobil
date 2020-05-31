import 'dart:convert';

import 'package:undisaster/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}
enum MqttSubscriptionState { IDLE, SUBSCRIBED }

class MQTTClientWrapper {
  MqttClient client;
  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  Function(String) onMessageReceived;
  VoidCallback onConnectedCallback;
  VoidCallback onConnectedCallback2;
  VoidCallback onDisConnectedCallback2;

  void prepareMqttClient(Function(String) onMessageReceived,
      VoidCallback onConnectedCallbac) async {
    if (onMessageReceived != null) {
      this.onMessageReceived = onMessageReceived;
    }
    if (onConnectedCallback != null) {
      this.onConnectedCallback = onConnectedCallback;
    }
    _setupMqttClient();
    await _connectClient();
  }

//    _subscribeToTopic('Dart/Mqtt_client/testtopic');

  void setClientId(String id) {
    if (client != null) client.clientIdentifier = id;
  }

  void reConnect() async {
    if (client.connectionStatus.state == MqttConnectionState.disconnected ||
        client.connectionStatus.state == MqttConnectionState.faulted)
      await _connectClient();
  }

  void _setupMqttClient() {
    client = MqttServerClient.withPort(Constants.MQTT_HOST, '#', 1883);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Mosquitto client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect(Constants.GATEWAY_CREDENTIAL);
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('MQTTClientWrapper::Mosquitto client connected');
    } else {
      print(
          'MQTTClientWrapper::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void publishMessage(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('MQTTClientWrapper::Publishing message $message to topic $topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      print("MQTTClientWrapper::Yeni mesaj topic: ${c[0].topic}");
      final MqttPublishMessage recMess = c[0].payload;
      final String newData =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print("MQTTClientWrapper::GOT A NEW MESSAGE $newData");
    });
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    if (onConnectedCallback != null) onConnectedCallback();
    if (onConnectedCallback2 != null) onConnectedCallback2();
  }

  void _onDisconnected() {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode ==
        MqttConnectReturnCode.brokerUnavailable) {
      print(
          'MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    }
    connectionState = MqttCurrentConnectionState.DISCONNECTED;

    if (onDisConnectedCallback2 != null) onDisConnectedCallback2();
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void registerUserAsDevice(String deviceName, String type,
      {String capabilities = "", String desc = ""}) {
    var data = {
      "device": deviceName,
      "type": type,
      "capabilities": capabilities,
      "desc": desc
    };

    String message = jsonEncode(data);
    publishMessage("v1/gateway/connect", message);
  }

  void sendAttribure(String deviceName, String name, dynamic value) {
    var data = {};

    data[deviceName] = {name: value};

    String message = jsonEncode(data);
    publishMessage("v1/gateway/attributes", message);
  }

  void addConnectionListener(Function() onConnected) {
    this.onConnectedCallback2 = onConnected;
  }

  void addDisConnectionListener(Function() onDisConnected) {
    this.onDisConnectedCallback2 = onDisConnected;
  }
}
