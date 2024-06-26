import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';
import 'dart:convert';

class CYMqttRequest {
    bool _isConnect = false;
    bool get isConnect => _isConnect;

    late MqttServerClient _client;
    MqttServerClient get mqttClient => _client;

    disConnect() async {
      _client.disconnect();
    }

    connectClient(String address,String client,int port) async {
      print("去连接:$address,$client,$port");
      _client =
          MqttServerClient.withPort(address, client, port);
      // MqttServerClient.withPort("ws://172.16.14.201:8083/mqtt", "mqttx_ff8e58c8776", 8083);
      _client.logging(on: true);
      _client.onConnected = onConnected;
      _client.onDisconnected = onDisconnected;
      // client.onUnsubscribed = onUnsubscribed;
      _client.onSubscribed = onSubscribed;
      _client.onSubscribeFail = onSubscribeFail;
      _client.pongCallback = pong;

      final connMessage = MqttConnectMessage()
          .authenticateAs('', '')
          .keepAliveFor(60)
          .withWillTopic('willtopic')
          .withWillMessage('Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _client.connectionMessage = connMessage;

      try {
        await _client.connect();
      } catch (e) {
        // print('Exception: $e');
        _client.disconnect();
      }

      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        print('XKLOG_MQTT_Received message:${c[0].payload}');
      });
    }
    // connect() async {
    //   // test.mosquitto.org
    //   _client =
    //   MqttServerClient.withPort("broker-cn.emqx.io", "mqttx_ff8e58c8776", 1883);
    //   // MqttServerClient.withPort("ws://172.16.14.201:8083/mqtt", "mqttx_ff8e58c8776", 8083);
    //   _client.logging(on: true);
    //   _client.onConnected = onConnected;
    //   _client.onDisconnected = onDisconnected;
    //   // client.onUnsubscribed = onUnsubscribed;
    //   _client.onSubscribed = onSubscribed;
    //   _client.onSubscribeFail = onSubscribeFail;
    //   _client.pongCallback = pong;
    //
    //   final connMessage = MqttConnectMessage()
    //       .authenticateAs('', '')
    //       .keepAliveFor(60)
    //       .withWillTopic('willtopic')
    //       .withWillMessage('Will message')
    //       .startClean()
    //       .withWillQos(MqttQos.atLeastOnce);
    //   _client.connectionMessage = connMessage;
    //
    //   try {
    //     await _client.connect();
    //   } catch (e) {
    //     // print('Exception: $e');
    //     _client.disconnect();
    //   }
    //
    //   _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    //     print('XKLOG_MQTT_Received message:${c[0].payload}');
    //     // final MqttPublishMessage message = c[0].payload;
    //     // final payload =
    //     // MqttPublishPayload.bytesToStringAsString(message.payload.message);
    //     // print('Received message:$payload from topic: ${c[0].topic}>');
    //     // print('XKLOG_MQTT_Listen');
    //   });
    // }
  // 连接成功
  void onConnected() {
    print('XKLOG_MQTT_Connected');
    _isConnect = true;
  }

// 连接断开
  void onDisconnected() {
    print('XKLOG_MQTT_Disconnected');
    _isConnect = false;
  }

// 订阅主题成功
  void onSubscribed(String topic) {
    print('XKLOG_MQTT_Subscribed topic: $topic');
  }

// 订阅主题失败
  void onSubscribeFail(String topic) {
    print('XKLOG_MQTT_Failed to subscribe $topic');
  }

// 成功取消订阅
  void onUnsubscribed(String topic) {
    print('XKLOG_MQTT_Unsubscribed topic: $topic');
  }

// 收到 PING 响应
  void pong() {
    print('XKLOG_MQTT_Ping response client callback invoked');
  }
}