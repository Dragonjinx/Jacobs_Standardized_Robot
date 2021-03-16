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
int q_final[5];
int j=0;
int k=0;
char* q_split=NULL;
bool newq;

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
    newq=true;
  }
  q_split=strtok(const_cast<char*>(q.c_str()),"q");
  
  q_final[i]=atoi(q_split);
  if (newq){Serial.println(q_final[i]);}
  while (q_split!= NULL && newq)
  {
    i++;
    q_split=strtok(NULL,"q");
    q_final[i]=atoi(q_split);
  }
  i=0;
  q="";
}
