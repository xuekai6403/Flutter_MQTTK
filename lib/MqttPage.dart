import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/src/typed_buffer.dart';
import 'MqttRequest.dart';
import 'dart:convert';

class Mqttpage extends StatefulWidget {
  const Mqttpage ({super.key});

  @override
  State<Mqttpage> createState() => _MqttpageState();
}

class _MqttpageState extends State<Mqttpage> {
  late Timer _heartbeatTime;
  final CYMqttRequest mqttRequest = CYMqttRequest();
  var btnStr = "已断开";

  // 输入框内容
  String _addressStr = '';
  String _clientStr = '';
  String _portStr = '';

  void _handleAddressTextChange(String text) {
    setState(() {
      _addressStr = text;
    });
  }

  void _handleClientTextChange(String text) {
    setState(() {
      _clientStr = text;
    });
  }

  void _handlePortTextChange(String text) {
    setState(() {
      _portStr = text;
    });
  }

  // 订阅内容
  String _topicStr = '';
  String _messageStr = '';

  void _handleTopicTextChange(String text) {
    setState(() {
      _topicStr = text;
    });
  }

  void _handleMessageTextChange(String text) {
    setState(() {
      _messageStr = text;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final Duration duration = Duration(seconds: 1);
    _heartbeatTime = Timer.periodic(duration, (timer){
      btnStr = mqttRequest.isConnect ? "已连接" : "发起连接";
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1.配置服务器,客户端ID,端口(input)
      // 2.连接 -connect
      // 3.输入Topic主题(input)
      // 4.订阅主题 -subscribe
      // 5.取消订阅
      // 6.发布主题
      // 7.收到message(output)
      // 8.断开连接

      appBar: AppBar(title:const Text('MQTT测试',style: TextStyle(color: Colors.white),),backgroundColor: Colors.blue,),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
         _getInputAddress(),
          Container(margin:const EdgeInsets.fromLTRB(50, 20, 50, 0),color: (mqttRequest.isConnect ? Colors.lightGreen : Colors.black12),child: RawMaterialButton(onPressed: (){
            _connectMqtt();
          },child: Text(btnStr),),
          ),
          _getInputTopic(),
          _getInputMessage(),
          Container(margin:const EdgeInsets.fromLTRB(50, 20, 50, 0),color: Colors.black26,child: RawMaterialButton(onPressed: (){
            _subscribeTopic();
          },child: Text("2.订阅主题 -subscribe"),),),
          Container(margin:const EdgeInsets.fromLTRB(50, 20, 50, 0),color: Colors.black38,child: RawMaterialButton(onPressed: (){
            _cancelSubscribeTop();
          },child: Text("3.取消订阅"),),),
          Container(margin:const EdgeInsets.fromLTRB(50, 20, 50, 0),color: Colors.black45,child: RawMaterialButton(onPressed: (){
            _publishMessage();
          },child: Text("4.发布主题"),),),
          Container(margin:const EdgeInsets.fromLTRB(50, 20, 50, 0),color: Colors.black87,child: RawMaterialButton(onPressed: (){
            _disConnectMqtt();
          },child: Text("6.断开连接",style: TextStyle(color: Colors.white),),),),
        ],
      ),
    );
  }

  // UI
  _getInputAddress(){
    return Container(color: Colors.black12,
      child:Wrap(
        children: [
          Container(color: Colors.yellow,width: MediaQuery.of(context).size.width/3,height: 40,child:
          TextField(onChanged: _handleAddressTextChange,decoration: InputDecoration(hintText: "服务器地址"),textAlign: TextAlign.center),),
          Container(color: Colors.deepOrangeAccent,width: MediaQuery.of(context).size.width/3,height: 40,child:
          TextField(onChanged: _handleClientTextChange,decoration: InputDecoration(hintText: "客户端ID"),textAlign: TextAlign.center),),
          Container(color: Colors.green,width: MediaQuery.of(context).size.width/3,height: 40,child:
          TextField(onChanged: _handlePortTextChange,decoration: InputDecoration(hintText: "端口"),textAlign: TextAlign.center),),
        ],
      ),
    );
  }
  _getInputTopic(){
    return Container(
      margin:const EdgeInsets.fromLTRB(50, 20, 50, 0),
      color: Colors.white,
      child:TextField(onChanged:_handleTopicTextChange,decoration: InputDecoration(hintText: "请输入订阅Topic")),
    );
  }
  _getInputMessage(){
    return Container(
      margin:const EdgeInsets.fromLTRB(50, 20, 50, 0),
      color: Colors.white,
      child: TextField(onChanged: _handleMessageTextChange,decoration: InputDecoration(hintText: "请输入Message"),),
    );
  }

  // 协议
  _connectMqtt(){
    if (_addressStr.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('提示'),
            content: Text('请输入服务器地址'),
          );
        },
      );
      return;
    }

    if (_clientStr.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('提示'),
            content: Text('请输入客户端ID'),
          );
        },
      );
      return;
    }

    if (_portStr.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('提示'),
            content: Text('请输入端口号'),
          );
        },
      );
      return;
    }

    mqttRequest.connectClient(_addressStr, _clientStr, int.parse(_portStr));
  }

  _disConnectMqtt(){
    mqttRequest.disConnect();
  }

  // 订阅主题
  _subscribeTopic(){
    mqttRequest.mqttClient.subscribe(_topicStr, MqttQos.atLeastOnce);
  }

  // 取消订阅
  _cancelSubscribeTop(){
    mqttRequest.mqttClient.unsubscribe(_topicStr);
  }

  // 发布主题
  _publishMessage(){
    mqttRequest.mqttClient.publishMessage(_topicStr, MqttQos.atLeastOnce, utf8.encode(_messageStr) as Uint8Buffer);
  }
}
