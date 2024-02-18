import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class SerialCommunication {
  late SerialPort port;
  late List<String> availablePorts = [''];

  SerialCommunication() {
    attPortas();
  }

  Future<void> attPortas() async {
    availablePorts = SerialPort.getAvailablePorts();
  }

  Future<void> openPort(String portName) async {
    try {
      port = SerialPort(portName,
          openNow: false,
          ReadIntervalTimeout: 1,
          ReadTotalTimeoutConstant: 2,
          BaudRate: 9600);
      port.open();
      debugPrint('debug: Porta selecionada ($portName) aberta');
      //setState(() {});
    } catch (e) {
      // Exibe um SnackBar em caso de erro
      debugPrint('debug: Erro ao abrir ($portName)');
    }
  }

  void closePort() async {
    port.close();
  }

  void writeData(String data) {
    port.writeBytesFromString(data);
  }

  List<String> getPortList() {
    return availablePorts;
  }
}
