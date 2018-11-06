gcc -g -O2 -I./include -I./include/SDL -D_GNU_SOURCE=1 -DTARGET_API_MAC_CARBON -DTARGET_API_MAC_OSX -fvisibility=hidden -I/usr/X11R6/include -DXTHREADS -D_THREAD_SAFE -force_cpusubtype_ALL -fpascal-strings -c ./libexec/SDLMain.m -o ./SDLMain.o

g++ -g -O2 -I./include -I./include/SDL -D_GNU_SOURCE=1 -DTARGET_API_MAC_CARBON -DTARGET_API_MAC_OSX -fvisibility=hidden -I/usr/X11R6/include -DXTHREADS -D_THREAD_SAFE -force_cpusubtype_ALL -fpascal-strings -c ./main.cpp -o ./main.o

g++ -I include -c ./quickcg.cpp -o ./quickcg.o 

g++ *.o -o play -I include -L lib -l SDL-1.2.0 -lobjc  -framework Foundation -framework Cocoa
