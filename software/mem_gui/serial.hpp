// Class to handle Serial comms
// Uses CPP FTDI handles

#ifndef SERIAL_HPP
#define SERIAL_HPP

#include <iostream>
#include "ftdi.hpp"

using namespace Ftdi;

class Serial
{
	public:
		Serial(int vidIn, int pidIn);
		~Serial() {};
		void listDevices(void);
		bool isOpen(void) {return context.is_open();};
		char * getError(void) {return context.error_string();};

	private:
		int vid, pid;
		Context context;

};

#endif
