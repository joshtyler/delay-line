// Program to handle talking to test harness

#include <iostream>
#include "ftdi.hpp"

using namespace std;
using namespace Ftdi;

int main(int argc, char **argv)
{

	Ftdi find_all(0x0403, 0x6010);

//	cout << serial.getNoDevs() << " devices found" << endl;

	return 0;
}
