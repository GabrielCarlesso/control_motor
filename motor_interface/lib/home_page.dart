import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'usb_serial.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> comandos = [];
  int _selectedOptionWay = 1;
  late String _selectedPorta;
  SerialCommunication serialCommunication = SerialCommunication();
  final TextEditingController _speedmmperminController =
      TextEditingController();
  final TextEditingController _speedmmpersecController =
      TextEditingController();
  late String nomeArquivo;

  void sendGoInstruction() {
    DateTime now = DateTime.now();
    if (_speedmmperminController.text.isNotEmpty) {
      serialCommunication
          .writeData("1;$_selectedOptionWay;${_speedmmperminController.text};");
      debugPrint(
          "Comando: 1;$_selectedOptionWay;${_speedmmperminController.text};");
      String novoComando =
          "${now.day}/${now.month} at ${now.hour}:${now.minute}   Speed: ${_speedmmperminController.text} mm/min Way: ${_selectedOptionWay == 1 ? "Up" : "Down"}";

      setState(() {
        comandos.add(novoComando);
        salvarListaEmArquivo(comandos);
      });
    }
  }

  void sendStopInstruction() {
    serialCommunication.writeData("\n0;0;0;\n");
    debugPrint("Comando: Stop");
    DateTime now = DateTime.now();
    String novoComando =
        "${now.day}/${now.month} at ${now.hour}:${now.minute}  Stopped ";
    setState(() {
      comandos.add(novoComando);
      salvarListaEmArquivo(comandos);
    });
  }

  @override
  void initState() {
    serialCommunication.attPortas();
    _selectedPorta = serialCommunication.availablePorts.first;
    serialCommunication.openPort(_selectedPorta);
    nomeArquivo =
        "my_comand_list_${DateTime.now().month}_${DateTime.now().day}_${DateTime.now().hour}_${DateTime.now().minute}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            _buildDropDownPortas(),
            const Spacer(flex: 1),
            SizedBox(
              width: screenWidth * 0.75,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(flex: 1),
                  const Flexible(
                    flex: 1,
                    child: Text("Speed: "),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      controller: _speedmmperminController,
                      onChanged: (value) {
                        double conversao;
                        try {
                          conversao = double.parse(value);
                          conversao = conversao / 60;
                          _speedmmpersecController.text =
                              conversao.toStringAsFixed(5);
                        } catch (e) {
                          debugPrint("Erro ao converter para double: $e");
                        }
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,5}'))
                      ],
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const Text("mm/min"),
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 4,
                    child: TextField(
                      onChanged: (value) {
                        double conversao;
                        try {
                          conversao = double.parse(value);
                          conversao = conversao * 60;
                          _speedmmperminController.text =
                              conversao.toStringAsFixed(5);
                        } catch (e) {
                          debugPrint("Erro ao converter para double: $e");
                        }
                      },
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      controller: _speedmmpersecController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,5}'))
                      ],
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  const Text("mm/s"),
                  const Spacer(flex: 1),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth * 0.75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Spacer(),
                  _buildRadioTile(Icons.arrow_upward, 'Up', 1),
                  _buildRadioTile(Icons.arrow_downward, 'Down', 0),
                  const Spacer(),
                ],
              ),
            ),
            const Spacer(flex: 1),
            SizedBox(
              width: screenWidth * 0.75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton('Stop', Colors.red, sendStopInstruction),
                  const Spacer(flex: 1),
                  _buildButton('Go', Colors.green, sendGoInstruction),
                ],
              ),
            ),
            const Spacer(flex: 2),
            _buildListaComandos(comandos),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            serialCommunication.availablePorts.clear();
            serialCommunication.attPortas();
          });
        },
        tooltip: 'GetPorts',
        child: const Icon(Icons.search),
      ),
    );
  }

  // Função auxiliar para criar RadioListTile
  Widget _buildRadioTile(IconData icon, String text, int value) {
    return Expanded(
      child: RadioListTile<int>(
        title: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 6.0),
            Text(text),
          ],
        ),
        value: value,
        groupValue: _selectedOptionWay,
        onChanged: (selectedValue) {
          setState(() {
            _selectedOptionWay = selectedValue!;
          });
        },
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return Flexible(
      flex: 3,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDropDownPortas() {
    if (!serialCommunication.port.isOpened) {
      serialCommunication.openPort(_selectedPorta);
    }
    List<String> listaPortas = serialCommunication.availablePorts;

    // Ensure _selectedPorta is a valid value or reset it
    if (!_selectedPortaValid(listaPortas, _selectedPorta)) {
      _selectedPorta = listaPortas.isNotEmpty ? listaPortas.first : " ";
      // Optionally, you can handle this case (e.g., disable dropdown or show a message)
    }

    return DropdownButton<String>(
        value: _selectedPorta,
        onChanged: (String? value) {
          if (value != null && listaPortas.contains(value)) {
            serialCommunication.openPort(value);
            setState(() {
              _selectedPorta = value;
            });
          }
        },
        items: listaPortas.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList());
  }

// Helper method to check if _selectedPorta is a valid option
  bool _selectedPortaValid(List<String> ports, String? selectedPort) {
    return selectedPort != null && ports.contains(selectedPort);
  }

  Widget _buildListaComandos(List<String> listaComandos) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: const Color.fromARGB(255, 238, 238, 238),
      width: screenWidth * 0.75, // Largura do SizedBox
      height: 300.0, // Altura do SizedBox
      child: ListView(
        children: listaComandos.map((comando) {
          return ListTile(
            title: Text(comando),
          );
        }).toList(),
      ),
    );
  }

  Future<void> salvarListaEmArquivo(List<String> lista) async {
    try {
      // Obter o diretório de documentos do dispositivo
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/$nomeArquivo.txt';

      // Criar o arquivo
      File file = File(filePath);

      // Escrever no arquivo
      await file.writeAsString(lista.join('\n'));

      debugPrint('Lista salva com sucesso em $filePath');
    } catch (e) {
      debugPrint('Erro ao salvar lista: $e');
    }
  }
}
