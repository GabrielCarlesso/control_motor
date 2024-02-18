#include <AccelStepper.h>
#define motorInterfaceType 1  

int PUL=7; //define Pulse pin
int DIR=6; //define Direction pin
int ENA=5; //define Enable Pin

AccelStepper stepper = AccelStepper(motorInterfaceType, 7, 5);
float steps_per_seconds = 133;


int SENTIDO = 0; // 1 -> horário (H) ou 0 -> anti-horário (J)
int state = 1; 
float velocidade = 0; // mm/s

void processarComando(const char *comando) {
  // Copia o comando para uma string modificável
  char comandoCopia[strlen(comando) + 1];
  strcpy(comandoCopia, comando);

  // Extrai o comando e o valor usando strtok
  char *token = strtok(comandoCopia, ";");                          //Esatado ligado ou desligado
  state = atoi(token);
  //Serial.println(state);

  token = strtok(NULL, ";");                                         //SIntido up ou down
  SENTIDO = atoi(token);
  //Serial.println(SENTIDO);
  
  token = strtok(NULL, ";");                                        //Valor interpasso

 
  char *endptr;  // Ponteiro de fim para verificar erros
  velocidade = strtod(token, &endptr);  // Converte a string para um número de ponto flutuante
    if (*endptr != '\0') {
        Serial.println("Erro de conversao: nao e um numero valido.\n");
        velocidade = 0;
        state = 0;
    }
  steps_per_seconds = ((velocidade/60)*3200)/0.05 ;

  Serial.println(steps_per_seconds); 

  if(!SENTIDO){
    stepper.setSpeed(-steps_per_seconds);
  }else{
    stepper.setSpeed(steps_per_seconds);
  }
}

void setup() {
  //pinMode (led,OUTPUT);
  Serial.begin (9600);
  pinMode (PUL, OUTPUT);
  pinMode (DIR, OUTPUT);
  pinMode (ENA, OUTPUT);

  digitalWrite(ENA,LOW);

  stepper.setMaxSpeed(4000);
  stepper.setSpeed(0);
}

void stepFoward(){
  stepper.runSpeed();
}

void stepBackward(){
  stepper.runSpeed();
}

void loop() {

  if (Serial.available() > 0) { // Verifica se há dados disponíveis para leitura
    char buffer[256];
    Serial.readBytesUntil('\n', buffer, sizeof(buffer));
    // Processa o comando
    processarComando(buffer);
  }
  
  if(state){
    digitalWrite(ENA,HIGH);
    stepper.runSpeed();
  }else{
    digitalWrite(ENA,LOW);
  }

}