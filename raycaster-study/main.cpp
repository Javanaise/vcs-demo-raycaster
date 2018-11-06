#include <cmath>
#include <string>
#include <vector>
#include <iostream>
#include <iomanip>

#include "quickcg.h"
using namespace QuickCG;
using namespace std;


//#define START_POSX 0x304
//#define START_POSY 0x304
//#define START_ANG 0x60

#define START_POSX 0xD14
#define START_POSY 0x32E
#define START_ANG 0x20

//#define START_POSX 0x584
//#define START_POSY 0x710
//#define START_ANG 0x52

/*
g++ *.cpp -lSDL -O3 -W -Wall -ansi -pedantic
g++ *.cpp -lSDL
*/

//place the example code below here:

#define mapWidth 16
#define mapHeight 16
#include <iostream>
#include <fstream>
#include <string>


int map[mapWidth][mapHeight]=
{
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,1,0,1,0,1,0,1,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,1,0,0,0,0,0,0,0,0,0,1,0,1},
  {1,0,1,1,1,0,1,0,1,0,1,0,0,0,0,1},
  {1,0,0,1,0,0,0,0,0,0,0,0,0,1,0,1},
  {1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
  {1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,1},
  {1,0,0,0,1,0,0,0,0,0,0,0,0,1,0,1},
  {1,1,0,0,1,1,1,1,1,1,1,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
};
/*
int map[mapWidth][mapHeight]=
{
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,1},
  {1,0,0,0,0,1,0,0,0,0,1,0,0,0,1,1},
  {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1},
  {1,0,0,0,0,1,0,0,1,0,1,0,0,0,1,1},
  {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1},
  {1,0,0,0,0,1,0,0,0,0,1,0,0,0,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
};
*/

int mapDist[256] = {
         0x0F,0x0F,0x0F,0x0F,0x0F,0x0F,0x0F,0x0F, 0x0F,0x0F,0x0F,0x0F,0x0F,0x0F,0x0F,0x0F,
         0x0F,0x0F,0x0F,0x0F,0x0F,0x0F,0x0F,0x0F, 0x0F,0x0F,0x0F,0x0F,0x0F,0x0E,0x0E,0x0D,
         0x0D,0x0D,0x0C,0x0C,0x0C,0x0B,0x0B,0x0B, 0x0A,0x0A,0x0A,0x0A,0x09,0x09,0x09,0x09,
         0x09,0x08,0x08,0x08,0x08,0x08,0x08,0x07, 0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x06,
         0x06,0x06,0x06,0x06,0x06,0x06,0x06,0x06, 0x06,0x05,0x05,0x05,0x05,0x05,0x05,0x05,
         0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x04, 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,
         0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04, 0x04,0x04,0x04,0x04,0x04,0x03,0x03,0x03,
         0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03, 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,
         0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03, 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,
         0x03,0x02,0x02,0x02,0x02,0x02,0x02,0x02, 0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
         0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02, 0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
         0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02, 0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
         0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02, 0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,
         0x02,0x02,0x02,0x02,0x02,0x02,0x01,0x01, 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
         0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01, 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,
         0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01, 0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01
};

enum {
  flipx = 1,
  negx = 2,
  flipy = 4,
  negy = 8
};

unsigned int degcon[4] = {
  flipx | negy,
  negx | negy | flipy,
  negx | flipx,
  flipy 
};

//Dimension of the Projection Plane = 128 pix * 64 pix (blocs 4pix horz, 8pix vert, en pixratio 2:1) //;32 x 32 units
//Center of the Projection Plane = (64,32)
//Distance to the Projection Plane = 277 units
//Angle between subsequent rays = 64/256 degrees , FOV = 90 deg

// FOV 64 deg au lieu de 60
// 60 deg en base 256 -> 42
// en base 1024 -> 170

#define PI 3.141592653589793
#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) > (b) ? (a) : (b))

double RAD(double x) {
  return ((double)x * 2.0 * PI / 256.0);
}

double RAD(int x) {
  return ((double)x * 2.0 * PI / 256.0);
}

enum {
  JGE = 0,
  JLE = 1
};

int finetangent[65];
int sinus[256];
int cosinus[256];


//cout << i << ": " << finetangent[i] << endl;
void InitTangent() {
  for (int i = 0; i <= 64; i++) {
//    double tangent = i < 64 ? tan(RAD(i)) : tan(RAD((double)i - 0.0001));  // si t'enleves le 0.001 t'exploses mec;
    double tangent = tan(RAD((double)i * 63.999999 / 64.0));  // si t'enleves le 0.001 t'exploses mec;
    double scaledTangent = MIN(round(tangent * 256.0), 32000.0);
    finetangent[i] = (int)scaledTangent;
//    if (i >= 32) finetangent[i]+=2;
  }

  for (int i = 1; i < 32; i++) {
    int xstep = finetangent[64 - i];  // how much x advance when y advances 256 
    int saveTangent = xstep;
    int ystep = finetangent[i];       // how much y advance when x advances 256 
    double xAlpha = (double)256.0 / (double)xstep;
    double yAlpha = (double)ystep / (double)256.0;
//    cout << "i:" << i << " " << xAlpha << " " << yAlpha << endl;
    // on cherche la valeur de la tangente telle que xAlpha > yAlpha et xAlpha as low as possible
    if (xAlpha > yAlpha) {
      while (((double)256.0 / (double)(finetangent[64 - i] + 1)) > yAlpha) {
        finetangent[64 - i]++; 
      }
    } else {
      do {
        finetangent[64 - i]--;  
      }
      while (((double)256.0 / (double)finetangent[64 - i]) < yAlpha);
    }
    double angBefore = atan((double)256.0 / (double)(finetangent[64 - i] + 1));
    double angAfter = atan((double)256.0 / (double)(finetangent[64 - i]));
    double angTarget = atan(yAlpha);
    if (abs(angTarget - angBefore) < abs(angTarget - angAfter)) {
      finetangent[64 - i]++;
    }
    cout << "i:" << i << " " << xAlpha << " " << yAlpha << " . " << "tangent[" << (64 -i) 
         << "] was " << saveTangent << ", now " << finetangent[64 - i] << endl;

  }
  
  cout << "tangent(32) = " << dec << finetangent[32] << endl;
//          xstep = MyTan((int)ALPHA256 - 192); //tan(RAD(ALPHA256 - 192.0));
//          ystep = MyTan(256 - (int)ALPHA256); //tan(RAD(256.0  - 0.01- ALPHA256)); //    - 1




  /*
  for (int i = 0; i <= 64; i++) {
//    double tangent = i < 64 ? tan(RAD(i)) : tan(RAD((double)i - 0.0001));  // si t'enleves le 0.001 t'exploses mec;
//    double tangent = tan(RAD((double)i * 63.999999 / 64.0));  // si t'enleves le 0.001 t'exploses mec;
//    double scaledTangent = MIN(floor(tangent * 258.0), 30000.0);
//    int al = 
    if (i < 64) {
      finetangent[i] = wilson[256 + i * 4 + 2] * 256 + wilson[i * 4 + 2];
    } else {
      finetangent[i] = wilson[511] * 256 + wilson[255];
    }
//    if (i >= 32) finetangent[i]+=3;
  }
*/
  cout << "TangentHi" << endl;
  for (int i = 0; i <= 64; i++) {
//    if (i == 64) {
//      cout << i << ": " << finetangent[i] << endl;
    if (i % 8 == 0) {
      cout << "\t.byte #$" << hex << setw(2) << setfill('0') << (finetangent[i] >> 8) << ",";
    } else if (i % 8 == 7) {
      cout << "#$" << hex << setw(2) << setfill('0') << (finetangent[i] >> 8) << endl;
    } else {
      cout << "#$" << hex << setw(2) << setfill('0') << (finetangent[i] >> 8) << ",";
    }
//    }
  }
  cout << endl;
  cout << "TangentLo" << endl;
  for (int i = 0; i <= 64; i++) {
//    if (i == 64) {
//      cout << i << ": " << finetangent[i] << endl;
    if (i % 8 == 0) {
      cout << "\t.byte #$" << hex << setw(2) << setfill('0') << (finetangent[i] & 255) << ",";
    } else if (i % 8 == 7) {
      cout << "#$" << hex << setw(2) << setfill('0') << (finetangent[i] & 255) << endl;
    } else {
      cout << "#$" << hex << setw(2) << setfill('0') << (finetangent[i] & 255) << ",";
    }
//    }
  }
  cout << endl;
}

void InitSinus() {
  cout << "Sinus256" << endl;
  for (int i = 0; i < 256; i++) {
    sinus[i] = floor(255.5 * sin(RAD(i)));
    cosinus[i] = floor(255.5 * cos(RAD(i)));
/*
    if (i % 16 == 0) {
      cout << "\t.byte #$" << hex << setw(2) << setfill('0') << (sinus[i] & 255) << ",";
    } else if (i % 16 == 15) {
      cout << "#$" << hex << setw(2) << setfill('0') << (sinus[i] & 255) << endl;
    } else {
      cout << "#$" << hex << setw(2) << setfill('0') << (sinus[i] & 255) << ",";
    }
    */
    if (i % 16 == 0) {
      cout << "\t.byte " << dec << sinus[i] << ",";
    } else if (i % 16 == 15) {
      cout << sinus[i] << endl;
    } else {
      cout << sinus[i] << ",";
    }

  }
}

void DisplayMap() {
  for (int i = 0; i < 256; i++) {
    if (i % 16 == 0) {
      cout << "\t.byte #$" << hex << setw(2) << setfill('0') << (((int*)map)[i] & 255) << ",";
    } else if (i % 16 == 15) {
      cout << "#$" << hex << setw(2) << setfill('0') << (((int*)map)[i] & 255) << endl;
    } else {
      cout << "#$" << hex << setw(2) << setfill('0') << (((int*)map)[i] & 255) << ",";
    }
  }
}

int MyTan(int i) {
  if (i < 0 || i > 64) {
    cout << "Exception in MyTan : " << i << endl;
  }
  return finetangent[i];
}

int MySin(int i) {
  if (i < 0 || i > 255) {
    cout << "Exception in MySin : " << i << endl;
  }
  return sinus[i];
}

int MyCos(int i) {
  if (i < 0 || i > 255) {
    cout << "Exception in MyCos : " << i << endl;
  }
  return cosinus[i];
}

int dist[17];

void InitDiv() {
  cout << "divtable" << endl;
  for (int h = 0; h <= 16; h++) {
    dist[h] = 384 * 384 / (21 * h + 1);
//    cout << "height h : " << (h) << " , dist = " << dist[h] << endl;
    if (h) cout << "\t.word #$" << hex << setw(4) << setfill('0') << dist[h] << endl;
  }
  cout << dec;

  cout << "DivTableHi" << endl;
  for (int i = 1; i <= 16; i++) {
//    if (i == 64) {
//      cout << i << ": " << finetangent[i] << endl;
    if (i % 17 == 1) {
      cout << "\t.byte #$" << hex << setw(2) << setfill('0') << (dist[i] >> 8) << ",";
    } else if (i % 17 == 16) {
      cout << "#$" << hex << setw(2) << setfill('0') << (dist[i] >> 8) << endl;
    } else {
      cout << "#$" << hex << setw(2) << setfill('0') << (dist[i] >> 8) << ",";
    }
  }
  cout << "DivTableLo" << endl;
  for (int i = 1; i <= 16; i++) {
//    if (i == 64) {
//      cout << i << ": " << finetangent[i] << endl;
    if (i % 17 == 1) {
      cout << "\t.byte #$" << hex << setw(2) << setfill('0') << (dist[i] & 255) << ",";
    } else if (i % 17 == 16) {
      cout << "#$" << hex << setw(2) << setfill('0') << (dist[i] & 255) << endl;
    } else {
      cout << "#$" << hex << setw(2) << setfill('0') << (dist[i] & 255) << ",";
    }
  }

}

int MyDiv(int d) {
  int h = 0;
  while (dist[17 - h - 1] < d) h++;
  return 16 - h;
}

int toByte(int val) {
  int result = val & 255;
  while (result < 0) result += 256;
  while (result > 255) result -= 256;
  return result;
}


  int sposX = START_POSX; //3 * 256 + 4;
  int sposY = START_POSY;
  int previousAng = -1; // 224; //220;
//  int ang = 192 + 32; // 224; //220;
  int ang = START_ANG; // 224; //220;
//  double FOV = 42.0;
  double FOV = 32.0;
//  int focaltx = 57;
//  double fdist = 0.0;

  double oldTime = 0; //time of previous frame


  int debugged = 1;

int compteur = 0;

#define nbs 256


int angs[nbs];
int xs[nbs];
int ys[nbs];

void cuckLand(int x) {
        cout << "#$" << hex << setw(2) << setfill('0') << (x & 255) << ",#$" << hex << setw(2) << setfill('0') << (x >> 8);
}

void play() {
  ang++;
  angs[compteur]=ang;
  xs[compteur]=sposX;
  ys[compteur]=sposY;

  compteur++;
  if (compteur == nbs) {
    std::ofstream out("map1.asm");
    std::streambuf *coutbuf = std::cout.rdbuf(); //save old buf
    std::cout.rdbuf(out.rdbuf()); //redirect std::cout to out.txt!

cout << "nbsPts1 equ $ff" << endl;

cout << "Ang1" << endl;
  for (int i = 0; i < nbs; i++) {
    if (i % 16 == 0) {
      cout << "\t.byte #$" << hex << setw(2) << setfill('0') << (((int*)angs)[i] & 255) << ",";
    } else if (i % 16 == 15) {
      cout << "#$" << hex << setw(2) << setfill('0') << (((int*)angs)[i] & 255) << endl;
    } else {
      cout << "#$" << hex << setw(2) << setfill('0') << (((int*)angs)[i] & 255) << ",";
    }
  }

cout << "X1" << endl;
  for (int i = 0; i < nbs; i++) {
    if (i % 8 == 0) {
      cout << "\t.byte ";
      cuckLand(((int*)xs)[i]);
      cout << ",";
    } else if (i % 8 == 7) {
      cuckLand(((int*)xs)[i]);
      cout << endl;
    } else {
      cuckLand(((int*)xs)[i]);
      cout << ",";
    }
  }

  cout << "Y1" << endl;
  for (int i = 0; i < nbs; i++) {
    if (i % 8 == 0) {
      cout << "\t.byte ";
      cuckLand(((int*)ys)[i]);
      cout << ",";
    } else if (i % 8 == 7) {
      cuckLand(((int*)ys)[i]);
      cout << endl;
    } else {
      cuckLand(((int*)ys)[i]);
      cout << ",";
    }
  }


  cout << "Map1" << endl;


    DisplayMap();
    exit(1);
  }
}

int main(int /*argc*/, char */*argv*/[])
{
  InitTangent();
//  return 0;

  InitSinus();
  InitDiv();
  DisplayMap();

  screen(512, 384, 0, "Raycaster"); // defines w = 512 and h = 384

  double time = 0; //time of current frame

  while(!done())
  {
    int a = -50000;
//    cout << a << " " << ((unsigned)a >> 8) << endl;
    int viewx = sposX; // / 256.0;
    int viewy = sposY; // / 256.0;
    int angCalcDist;
//    double viewx = sposX / 256.0; // / 256.0;
//    double viewy = sposY / 256.0; // / 256.0;


    int ALPHA256 = (int)ang; //(ang + 2560) & 255;
//    int midangle = ALPHA256 * 4;
    int debug = w / 2;
//    for(int x = 0; x < w; x++)
    verLine(256, 0, 20, RGB_Red);
    int previousALPHA256 = -1;
    int cols[4];
    int heights[32];
    for(int x = 0; x < w; x++)
    {
      int xx = (x >> 4) << 4;
      int BETA256 = toByte((int)(-(- (FOV / 2.0) + (double)xx * FOV / (double)w)));
      ALPHA256 = toByte(ang + BETA256); // + 256) & 255;

      if (previousALPHA256 != ALPHA256 && previousAng != ang) {
        debug = x; 
        debugged = 0;
        previousALPHA256 = ALPHA256;
        if (x == 0) {
          cout << "New Frame , midAng = #$" << hex << setw(2) << setfill('0') << ang << endl;
          for (int i = 0; i < 4; i++) {
            cols[i] = 0;
          }
          for (int i = 0; i < 32; i++) {
            heights[i] = 0;
          }
        }
      }

      int ALPHA256P180 = toByte(ALPHA256 + 128); //(ang + 128) & 255;
/*      if (ALPHA256 == 0.0 || ALPHA256 == 64.0 || ALPHA256 == 128.0 || ALPHA256 == 192.0) {
        continue;
      }
*/
      int focaltx = viewx >> 8; //floor(viewx);
      int focalty = viewy >> 8; //floor(viewy);

//      ALPHA256 = (ang + BETA256); // + 256) & 255;
//      while (ALPHA256 < 0.0) ALPHA256 += 256.0;
//      while (ALPHA256 >= 256.0) ALPHA256 -= 256.0;

      int quart = ALPHA256 >> 6;
  // variables dependant de l'orientation
      int xtilestep, ytilestep, horzop, vertop;
      int xstep, ystep;
      int xpartial, ypartial;
//      cout << "ALPHA256: " << ALPHA256 << endl;
      switch (quart) {
        case 0:
        {
          xtilestep = 1;
          ytilestep = -1;
          horzop = JGE;
          vertop = JLE;
          xstep = MyTan(64 - (int)ALPHA256); //tan(RAD(64.0 - 0.001 - ALPHA256)); //64 - 1 - ALPHA256));  // - 1 ?
          ystep = -MyTan((int)ALPHA256); //-tan(RAD(ALPHA256));
          xpartial = ((viewx & 255) ^ 255) + 1; // + 1 ? //1.0 - MAX(viewx - floor(viewx), 0.000); //xpartialup;
          ypartial = (viewy & 255); //MAX(viewy - floor(viewy), 0.000);       //ypartialdown;
          break;
        }
        case 1:
        {
          xtilestep = -1;
          ytilestep = -1;
          horzop = JLE;
          vertop = JLE;
          xstep = - MyTan((int)ALPHA256 - 64); //-tan(RAD(ALPHA256 - 64.0));
          ystep = -MyTan(128 - (int)ALPHA256); //-tan(RAD(128.0  - 0.01 - ALPHA256)); // - 1
          xpartial = (viewx & 255); //MAX(viewx - floor(viewx), 0.000);       //xpartialdown;
          ypartial = (viewy & 255); //MAX(viewy - floor(viewy), 0.000);       //ypartialdown;
          angCalcDist = 128 - ALPHA256;
          break;
        }
        case 2:
        {
          xtilestep = -1;
          ytilestep = 1;
          horzop = JLE;
          vertop = JGE;
          xstep = -MyTan(192-(int)ALPHA256); //-tan(RAD(192.0  - 0.01- ALPHA256));  //       - 1
          ystep = MyTan((int)ALPHA256 - 128); //tan(RAD(ALPHA256 - 128.0));
          xpartial = (viewx & 255); //MAX(viewx - floor(viewx), 0.000);       //xpartialdown;
          ypartial = ((viewy & 255) ^ 255) + 1; // + 1 ? //1.0 - (MAX(viewy - floor(viewy), 0.000));       //ypartialup;
          break;
        }
        case 3:
        {
          xtilestep = 1;
          ytilestep = 1;
          horzop = JGE;
          vertop = JGE;
          xstep = MyTan((int)ALPHA256 - 192); //tan(RAD(ALPHA256 - 192.0));
          ystep = MyTan(256 - (int)ALPHA256); //tan(RAD(256.0  - 0.01- ALPHA256)); //    - 1
          // Le +1 c pour le bug en 304,304 et angle E0
          xpartial = ((viewx & 255) ^ 255) + 1; //+ 1; // +1 ? // 1.0 - MAX(viewx - floor(viewx), 0.000);       //xpartialup;
          ypartial = ((viewy & 255) ^ 255) + 1; //+ 1; // +1 ? // 1.0 - MAX(viewy - floor(viewy), 0.000);       //ypartialup;
          if (xpartial == 0) xpartial = 1;
          if (ypartial == 0) ypartial = 1;
          angCalcDist = 256 - ALPHA256;
          break;
        }
      }
/*      if (xpartial == 0) xpartial = 1;
      if (xpartial == 256) xpartial = 255;
      if (ypartial == 0) ypartial = 1;*/
//      if (ypartial == 256) ypartial = 255;  // si je mets ca, je me prends une ligne noire au lieu d'un edge


//      cout << "OK" << endl;

    // initialise variables for intersection testing

// partials are unsigned, step are signed, both 8bit fixed 
    int yintercept = viewy + ((ystep * xpartial) >> 8);
    int xtile = focaltx + xtilestep;  // in Z80 focaltx = round(viewx);
    
    int xintercept = viewx + ((xstep * ypartial) >> 8);
    int ytile = focalty + ytilestep;

/*    if (x == debug && debugged == 0) {
      printf("Current position: %.3f, %.3f\n", viewx, viewy);
      printf("ang = %.2f\n", ALPHA256);
      printf("partial position: %.3f, %.3f\n", xpartial, ypartial);
      printf("stepping: %.3f, %.3f\n", xstep, ystep);

      printf("first intersect axe Y = %.3f, %.3f\n", (double)xtile, yintercept);
      printf("first intersect axe X = %.3f, %.3f\n", xintercept, (double)ytile);
    }    */
    if (x == debug && debugged == 0) {
      printf("Current position: #$%.4x, #$%.4x\n", viewx, viewy);
      printf("ang = #$%.2x\n", ALPHA256);
      printf("partial position: #$%.2x, #$%.2x\n", xpartial, ypartial);
      if (quart == 1) {
        printf("stepping: -%.4x, -%.4x\n", -xstep, -ystep);
      } else {
        printf("stepping: %.4x, %.4x\n", xstep, ystep);
      }

      printf("first intersect axe Y = %.2x, %.4x\n", xtile, yintercept);
      printf("first intersect axe X = %.4x, %.2x\n", xintercept, ytile);
    }

    // core loop
    bool vHit = false, hHit = false;
    int distance = 0; //, playerx = 0.0, playery = 0.0;
    int diffx = 0, diffy = 0;
/*    if (x == debug && debugged == 0) {
      printf("CoreLoop\n");
    }*/
    // check intersection with vertical wall
vertCheck:
/*    if (x == debug && debugged == 0) {
      printf("vertCheck\n");
      if (vertop == JLE) {
        printf("is floor(yIntercept) <= ytile ? %.3f <= %i)\n", yintercept, ytile);
      } else {
        printf("is floor(yIntercept) >= ytile ? %.3f <= %i)\n", yintercept, ytile);
      }
    }*/
//       ((((unsigned)yintercept & (255 << 8)) >> 8) & 0xF0 == 0) && 
    if ((vertop == JLE ? (yintercept >> 8) <= ytile : (yintercept >> 8) >= ytile)) goto horzEntry;
vertEntry:
/*    if (x == debug && debugged == 0) {
      printf("vertEntry\n");
      printf("Check map[%i, %i]\n", xtile, (int)floor(yintercept));
    }*/
    if (x == debug && debugged == 0) {
      printf("vertEntry\n");
      printf("Check map[%i, %i] (yintercept = #$%.4x)\n", xtile, yintercept >> 8, yintercept);
    }

    if (map[yintercept >> 8][xtile] == 0) {
        xtile = xtile + xtilestep;
        yintercept += ystep;
/*        if (x == debug && debugged == 0) {
          printf("no vert hit\n");
          printf("next vert check hit position will be at: (%.3f, %.3f)\n", (double)(xtile + (xtilestep == -1 ? 1 : 0)), yintercept);
        }*/
        goto vertCheck;
    }
hitVert:
    if (xtilestep == -1) xtile++;
    if (x == debug && debugged == 0) {
      printf("hitVert !\n");
      printf("hit point: (%.2x, %.4x)\n", xtile, yintercept);
    }
/*    if (x == debug && debugged == 0) {
      printf("hitVert !\n");
      printf("hit point: (%.3f, %.3f)\n", (double)(xtile), yintercept);
    }*/
    vHit = true;
//    distance = ((double)(xtile) - ((double)viewx / 256.0))  * cos(RAD(ALPHA256)) + ((double)(yintercept - viewy) / 256.0) * sin(RAD(ALPHA256 + 128.0));
    if (quart == 3) {
      diffx = (xtile << 8) - viewx;
      if (x == debug && debugged == 0) printf("diffx = %.4x\n", diffx);
      diffx = (diffx * MyCos(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffx * %.2x) >> 8 = %.4x\n", MyCos(angCalcDist), diffx);
      diffy = yintercept - viewy;
      if (x == debug && debugged == 0) printf("diffy = %.4x\n", diffy);
      diffy = (diffy * MySin(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffy * %.2x) >> 8 = %.4x\n", MySin(angCalcDist), diffy);
      distance = diffx + diffy;
      if (x == debug && debugged == 0) printf("distance = %.4x\n", distance);

    } else if (quart == 1) {
      diffx = viewx - (xtile << 8);
      if (x == debug && debugged == 0) printf("diffx = %.4x\n", diffx);
      diffx = (diffx * MyCos(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffx * %.2x) >> 8 = %.4x\n", MyCos(angCalcDist), diffx);
      diffy = viewy - yintercept;
      if (x == debug && debugged == 0) printf("diffy = %.4x\n", diffy);
      diffy = (diffy * MySin(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffy * %.2x) >> 8 = %.4x\n", MySin(angCalcDist), diffy);
      distance = diffx + diffy;
      if (x == debug && debugged == 0) printf("distance = %.4x\n", distance);

    } else {   

      diffx = (xtile << 8) - viewx;
      if (x == debug && debugged == 0) printf("diffx = %.4x\n", diffx);
      diffx = (diffx * MyCos(ALPHA256)) >> 8;
      if (x == debug && debugged == 0) printf("(diffx * %.2x) >> 8 = %.4x\n", MyCos(ALPHA256), diffx);
      diffy = yintercept - viewy;
      if (x == debug && debugged == 0) printf("diffy = %.4x\n", diffy);
      diffy = (diffy * MySin(ALPHA256P180)) >> 8;
      if (x == debug && debugged == 0) printf("(diffy * %.2x) >> 8 = %.4x\n", MySin(ALPHA256P180), diffy);
      distance = diffx + diffy;
      if (x == debug && debugged == 0) printf("distance = %.4x\n", distance);
    }

//    distance = (((xtile << 8) - viewx) * MyCos(ALPHA256) + (yintercept - viewy) * MySin(ALPHA256P180)) >> 8;
//    distance = sqrt(((double)xtile - viewx) * ((double)xtile - viewx) + (yintercept - viewy) * (yintercept - viewy));
    goto finCheck;
    
horzCheck:
/*    if (x == debug && debugged == 0) {
      printf("horzCheck\n");
      if (vertop == JLE) {
        printf("is floor(xIntercept) <= xtile ? %.3f <= %i)\n", xintercept, xtile);
      } else {
        printf("is floor(xIntercept) >= xtile ? %.3f <= %i)\n", xintercept, xtile);
      }
    }*/
    if (horzop == JLE ? (xintercept >> 8) <= xtile : (xintercept >> 8) >= xtile) goto vertEntry;
horzEntry:
    if (x == debug && debugged == 0) {
      printf("horzEntry\n");
      printf("Check map[%i, %i] (xintercept = #$%.4x)\n", xintercept >> 8, ytile, xintercept);
    }
/*    if (x == debug && debugged == 0) {
      printf("horzEntry\n");
      printf("Check map[%i, %i]\n", (int)floor(xintercept), ytile);
    }*/
    if (map[ytile][xintercept >> 8] == 0) {
        xintercept += xstep;
        ytile = ytile + ytilestep;
/*        if (x == debug && debugged == 0) {
          printf("no horz hit\n");
          printf("next horz check hit position will be at: (%.3f, %.3f)\n", xintercept, (double)(ytile + (ytilestep == -1 ? 1 : 0)));
        }*/
        goto horzCheck;
    }
hitHorz:
    hHit = true;
    if (ytilestep == -1) ytile++;
    if (x == debug && debugged == 0) {
      printf("hitHorz !\n");
      printf("hit point: (%.4x, %.2x)\n", xintercept, ytile);
      cols[x >> 7] = cols[x >> 7] | (1 << (7 - ((x >> 4) & 7)));
    }
/*    if (x == debug && debugged == 0) {
      printf("hitHorz !\n");
      printf("hit point: (%.3f, %.3f)\n", xintercept, (double)(ytile));
    }*/
    if (quart == 3) {
      diffx = xintercept - viewx;
      if (x == debug && debugged == 0) printf("diffx = %.4x\n", diffx);
      diffx = (diffx * MyCos(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffx * %.2x) >> 8 = %.4x\n", MyCos(angCalcDist), diffx);
      diffy = (ytile << 8) - viewy;
      if (x == debug && debugged == 0) printf("diffy = %.4x\n", diffy);
      diffy = (diffy * MySin(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffy * %.2x) >> 8 = %.4x\n", MySin(angCalcDist), diffy);
      distance = diffx + diffy;
      if (x == debug && debugged == 0) printf("distance = %.4x\n", distance);
    } else if (quart == 1) {
      diffx = viewx - xintercept;
      if (x == debug && debugged == 0) printf("diffx = %.4x\n", diffx);
      diffx = (diffx * MyCos(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffx * %.2x) >> 8 = %.4x\n", MyCos(angCalcDist), diffx);
      diffy = viewy - (ytile << 8);
      if (x == debug && debugged == 0) printf("diffy = %.4x\n", diffy);
      diffy = (diffy * MySin(angCalcDist)) >> 8;
      if (x == debug && debugged == 0) printf("(diffy * %.2x) >> 8 = %.4x\n", MySin(angCalcDist), diffy);
      distance = diffx + diffy;
      if (x == debug && debugged == 0) printf("distance = %.4x\n", distance);
    } else {
      diffx = xintercept - viewx;
      if (x == debug && debugged == 0) printf("diffx = %.4x\n", diffx);
      diffx = (diffx * MyCos(ALPHA256)) >> 8;
      if (x == debug && debugged == 0) printf("(diffx * %.2x) >> 8 = %.4x\n", MyCos(ALPHA256), diffx);
      diffy = (ytile << 8) - viewy;
      if (x == debug && debugged == 0) printf("diffy = %.4x\n", diffy);
      diffy = (diffy * MySin(ALPHA256P180)) >> 8;
      if (x == debug && debugged == 0) printf("(diffy * %.2x) >> 8 = %.4x\n", MySin(ALPHA256P180), diffy);
      distance = diffx + diffy;
      if (x == debug && debugged == 0) printf("distance = %.4x\n", distance);      
    }

//    distance = ((xintercept - viewx) * MyCos(ALPHA256) + ((ytile << 8) - viewy) * MySin(ALPHA256P180)) >> 8;
//    distance = ((double)(xintercept - viewx) / 256.0) * cos(RAD(ALPHA256)) + ((double)(ytile) - ((double)viewy / 256.0)) * sin(RAD(ALPHA256 + 128.0));
//    distance = sqrt((xintercept - viewx) * (xintercept - viewx) + ((double)ytile - viewy) * ((double)ytile - viewy));
    
finCheck:

  // correction fisheye    
//    distance = (distance * MyCos(BETA256)) >> 6;

    int side = vHit ? 1 : 0;
    if (x == debug && debugged == 0) 
      printf("int. axe %s (%.3f, %.3f) - dist %i\n", side ? "vert" : "horz", side ? (double)xtile : (double)xintercept / 256.0, side ? (double)yintercept / 256.0 : (double)ytile, distance);
    
    //Calculate height of line to draw on screen
//    int lineHeight = MIN((h / 2) * 3.0 / ((double)distance / 256.0), h); //(int)(h / perpWallDist);

//        lineHeight = 21 + (lineHeight / 21 ) * 21;  // 8 (1-9)
//    int lineHeight = 14 + MyDiv(distance) * 14;
    int lineHeight = 14 + mapDist[distance >> 4] * 14;
    if (x == debug && debugged == 0) {
      printf("index hauteur ligne projetee: %i\n", MyDiv(distance));
      heights[x >> 4] = mapDist[distance >> 4];
    }

//    lineHeight = (lineHeight / 24 ) * 24;     //16 hauteurs -> 
//        lineHeight = (lineHeight / 12 ) * 12;  // 32
//        lineHeight = 42 + (lineHeight / 42 ) * 42;  // 8 (1-9)
// 384 / 8 = 48

      //calculate lowest and highest pixel to fill in current stripe
      int drawStart = -lineHeight / 2 + h / 2;
      if(drawStart < 0)drawStart = 0;
      int drawEnd = lineHeight / 2 + h / 2;
      if(drawEnd >= h)drawEnd = h - 1;

      //draw the pixels of the stripe as a vertical line
      verLine(x, drawStart, drawEnd, RGB_Blue / (side ? 2: 1));

      if (x == debug && debugged == 0) {
        debugged = 1;
        printf("\n");
      }
    }
    if (ang != previousAng) {
      cout << "cols" << endl << "\t.byte ";
      for (int i = 0; i < 4; i++) {
        cout << "#$" << hex << setw(2) << setfill('0') << cols[i];
        if (i < 3) cout << ",";
      } 
      cout << endl;
      cout << "RaycastOutput" << endl << "\t.byte ";
      for (int i = 0; i < 32; i++) {
        if (i % 2 == 0) {
          cout << "#$" << hex << setw(1) << heights[i];
        } else {          
          cout << hex << setw(1) << heights[i];
          if (i < 31) cout << ",";
        }
      }
      cout << endl;
    }
    previousAng = ang;

    for (int height = 0; height < 16; height++) {
      int lineHeight = 14 + height * 14 + 1;
      int drawEnd =  - lineHeight / 2 + h / 2 - 1;
      if (height > 0) 
        horLine(drawEnd, 0, 512, RGB_Black);
      else {
        horLine(drawEnd, 0, 128, RGB_Black);
        horLine(drawEnd, 256, 384, RGB_Black);
        horLine(drawEnd, 128, 256, RGB_Yellow);
        horLine(drawEnd, 384, 512, RGB_Yellow);
      }
    }
    for (int width = 0; width < 32; width++) {
      verLine(width * w / 32, 0, h, RGB_Black);
    }

    //timing for input and FPS counter
    oldTime = time;
    time = getTicks();
    double frameTime = (time - oldTime) / 1000.0; //frameTime is the time this frame has taken, in seconds
    print(1.0 / frameTime); //FPS counter
    redraw();
    cls();

    //speed modifiers
    double moveSpeed = frameTime * 5.0; //the constant value is in squares/second
    double rotSpeed = frameTime * 3.0; //the constant value is in radians/second
    readKeys();

    double ALPHA = RAD(ang);
    double sdirX = cos(ALPHA);
    double sdirY = -sin(ALPHA);

    //move forward if no wall in front of you
    if (keyDown(SDLK_UP))
    {
//      if(worldMap[int(sposX + sdirX * moveSpeed) >> 8][int(sposY >> 8)] == 0) sposX += sdirX * moveSpeed;
      sposX += sdirX * 256.0 * moveSpeed;
//      if(worldMap[int(sposX >> 8)][int(sposY + sdirY * moveSpeed) >> 8] == 0) sposY += sdirY * moveSpeed;
      sposY += sdirY * 256.0 * moveSpeed;
      printf("%.2f,%.2f, dir = %.2f, %.2f\n", sposX / 256.0, sposY / 256.0, sdirX, sdirY);
      debugged = 0;
    }
    //move backwards if no wall behind you
    if (keyDown(SDLK_DOWN))
    {
//      if(worldMap[int(sposX - sdirX * moveSpeed) >> 8][int(sposY >> 8)] == false) sposX -= sdirX * moveSpeed;
//      if(worldMap[int(sposX) >> 8][int(sposY - sdirY * moveSpeed) >> 8] == false) sposY -= sdirY * moveSpeed;
      sposX -= sdirX * 256.0 * moveSpeed;
      sposY -= sdirY * 256.0 * moveSpeed;
      printf("%.2f,%.2f, dir = %.2f, %.2f\n", sposX / 256.0, sposY / 256.0, sdirX, sdirY);
      debugged = 0;
    }
    //rotate to the right
    if (keyDown(SDLK_RIGHT))
    {
      //both camera direction and camera plane must be rotated
      ang = (ang - 2.0); // % 256;
      if (ang >= 256.0) ang -= 256.0;
      printf("ang = %.2f\n", ang);
      debugged = 0;
    }
    //rotate to the left
    if (keyDown(SDLK_LEFT))
    {
      ang = (ang + 2.0); // % 256;
      if (ang < 0.0) ang += 256.0;
      printf("ang = %.2f\n", ang);
      debugged = 0;
    }
    while (ang < 0.0) ang += 256.0;
    while (ang >= 256.0) ang -= 256.0;

//    play();

  }
}

/*

11.43,11.76, dir = 0.56, -0.83
Current position: 11.429, 11.759
ang = 40.00

*/

