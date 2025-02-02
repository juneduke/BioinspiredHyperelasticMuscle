#include <elapsedMillis.h>
#include <Stepper.h>
const int stepsPerRevolution = 200;


int DIRpin2 = 5;
int stoppin2 = 6;
int speedpin2 = 7;

int DIRpin = 8;
int stoppin = 9;
int speedpin = 10;
int mswitchpin = 2;
int mdirpin = 3;
int mstpin = 4;
Stepper myStepper(stepsPerRevolution, 10, 8);
Stepper myStepper2(stepsPerRevolution, 7, 5);

unsigned long stepsize = 250;
unsigned long stopt = 50; 
unsigned long interval = 5000;
int sp = 1500; 

void setup() {
  pinMode(DIRpin, OUTPUT);
  pinMode(stoppin, OUTPUT);
  pinMode(speedpin, OUTPUT);

  pinMode(DIRpin2, OUTPUT);
  pinMode(stoppin2, OUTPUT);
  pinMode(speedpin2, OUTPUT);

  delay(200);

  Serial.begin(9600);
  Serial.println("s");

  while (Serial.available() == 0) {
  }

  digitalWrite(DIRpin, LOW);
  digitalWrite(speedpin, HIGH);
  digitalWrite(stoppin, HIGH);

  digitalWrite(DIRpin2, LOW);
  digitalWrite(speedpin2, HIGH);
  digitalWrite(stoppin2, HIGH);
  delay(5000);
//  movestep(myStepper, -5000, 1000);
//  delay(10);
//  movestep(myStepper, 5000, 1000);
//  delay(10);
  //delay(10000);


}
void loop() {
  if (digitalRead(mswitchpin)) {

        movestep(myStepper2, -1060, 100);
        delay(1000);
        movestep(myStepper2, 1066, 100);
        delay(1000);
    
  }
  else {
    manual();
  }
}


void manual()
{

  if (digitalRead(mstpin)) {
    movestep(myStepper2, 5 * (digitalRead(mdirpin) * 2 - 1), 200);
  }
  else
  {
  }


}

void autorun(int spds, unsigned long steps)
{
  movestep(myStepper, -steps, spds);
  elapsedMillis timeElapsed;

  while (timeElapsed < interval) {
  }
  movestep(myStepper, steps, spds);

  elapsedMillis timeElapsed3;

  while (timeElapsed3 < interval) {
  }

}

void movestep(Stepper motor, unsigned long step_size, int s) {

  motor.setSpeed(s);
  motor.step(step_size);
  elapsedMillis timeElapsed2;
  while (timeElapsed2 < stopt) {
  }

}
