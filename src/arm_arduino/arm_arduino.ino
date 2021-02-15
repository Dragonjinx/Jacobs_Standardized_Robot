#include <Servo.h>
#define r1 1
#define r2 2
#define r3 3
#define r4 4
#define r5 5

/**Servo r_1;
Servo r_2;
Servo r_3;
Servo r_4;
Servo r_5;**/

String q="";
int i=0;
double q_final[5];
int j=0;
int k=0;
String q_part="";

void setup() {
  Serial.begin(9600);
  /**r_1.attach(r1);
  r_2.attach(r2);
  r_3.attach(r3);
  r_4.attach(r4);
  r_5.attach(r5);**/
}

void loop() {
  if (Serial.available()){
    q=Serial.readStringUntil('\n');
    Serial.println(q);
  } else{
    Serial.println(1);
  }
  while(q[i]!='\n'){
    if(q[i]=='q'){
      q_final[k]=q_part.toDouble();
      k+=1;
      j=0;
      q_part="";
    }
    else{
      q_part[j]=q[i];
      j+=1;
    }
    i+=1;
  }
  for(int index = 0; index < 5; index++){
    Serial.println(q_final[index]);
  }

}
