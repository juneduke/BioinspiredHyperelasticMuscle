#include <elapsedMillis.h>
#include <Stepper.h>
const int stepsPerRevolution = 200;

int DIRpin = 8;
int stoppin = 9;
int speedpin = 10;
int mswitchpin = 2;
int mdirpin = 3;
int mstpin = 4;
Stepper myStepper(stepsPerRevolution, 10, 8);

unsigned long stepsize = 250; 
unsigned long stopt = 0; 
unsigned long interval = 5000; 
int sp = 1500; //pump speed calibration

void setup() {
  pinMode(DIRpin, OUTPUT);
  pinMode(stoppin, OUTPUT);
  pinMode(speedpin, OUTPUT);

  delay(200);

  Serial.begin(9600);
  Serial.println("s");

  while (Serial.available() == 0) {
  }

  digitalWrite(DIRpin, LOW);
  digitalWrite(speedpin, HIGH);
  digitalWrite(stoppin, HIGH);

  delay(1000);

}
void loop() {
  if (digitalRead(mswitchpin)) {

    movestep(-4000, 400);
    delay(1000);

    for (int i = 1; i <= 7; i++)
    {

      for (int j = 1; j <= 1; j++)
      {
        if (digitalRead(mswitchpin)) {

          autorun(sp, stepsize);


        }
      }
      delay(1000);
      sp = sp + 100;
    }

    sp = 1500;

    movestep(4000, 400);

    delay(10000);

  }
  else {
    manual();
  }
}


void manual()
{

  if (digitalRead(mstpin)) {
    movestep( 5 * (digitalRead(mdirpin) * 2 - 1), 200);
  }
  else
  {
  }


}

void autorun(int spds, unsigned long steps)
{
  movestep(-steps, spds);
  elapsedMillis timeElapsed;

  while (timeElapsed < interval) {
  }
  movestep(steps, spds);  

  elapsedMillis timeElapsed3;

  while (timeElapsed3 < interval) {
  }

}

void movestep(unsigned long step_size, int s) {

  myStepper.setSpeed(s);
  myStepper.step(step_size);
  elapsedMillis timeElapsed2;
  while (timeElapsed2 < stopt) {
  }

}
