// Program to handle talking to test harness

#include <iostream>
#include <typeinfo>
#include "ftdi_wrapper.h"

using namespace std;

int main(int argc, char **argv)
{
	try{
		FtdiWrapper serial(0x0403, 0x6010);

		cout << "Number of devices found: " << serial.getNoDevs() << endl;

		serial.listDevs();

		cout << "Choose a device to connnect to: ";
		int idx;
		cin >> idx;

		serial.open(idx, 9600);

		cout << "Connected at baud " << serial.getBaud();
	} catch (const std::exception& exc) {
		cerr << exc.what() << endl;
	}

	return 0;
}
