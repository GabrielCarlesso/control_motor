
##Controle de Motor de Passo com TB6600 e Arduino

O TB6600 é um driver de motor de passo, capaz de suportar motores com correntes até 4.0A e operando em tensões de 9V a 42V DC. Sua compatibilidade com Arduino permite o controle preciso de motores de passo para aplicações CNC, com a possibilidade de ajustar direção, velocidade e passos através de programação. Para tornar o controle ainda mais acessível, a implementação de uma interface gráfica do usuário através de Flutter.


###Esquemático de Conexão com Arduino
Para a correta conexão e funcionamento do sistema, siga o esquemático abaixo:
![alt text](images\image.png)

###Montagem e Configuração do Motor
O motor de passo utilizado neste projeto é acoplado a um redutor de 100, proporcionando maior precisão e torque:
![alt text](images\motor_com_redutor.jpg)

###Comunicação e Controle
A comunicação com o Arduino é realizada via serial, utilizando o seguinte formato de comando:
Liga;Sentido;Velocidade(mm/s);

Por exemplo, para ligar o motor, movendo-o para cima a uma velocidade de 0,15 mm/s, o comando seria:
1;1;0.15;

###Interface Gráfica Flutter
A interface gráfica, desenvolvida em Flutter, torna o controle do motor acessível e intuitivo. Para começar, instale o aplicativo utilizando o arquivo mysetup.exe disponível na pasta installer.



###Utilização da Interface
![alt text](images\interface.png)
Selecione a porta COM em que o Arduino está conectado.
Escolha a direção de movimento.
Envie o comando de movimento ou parada conforme necessário.

###Começando
Para utilizar este projeto, siga os passos de instalação do aplicativo Flutter, conecte seu Arduino conforme o esquemático e inicie a interface gráfica para controlar o motor.

