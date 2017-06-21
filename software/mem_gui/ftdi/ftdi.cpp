// C++ wrapper for libftdi
// Initialise serial port and read data

#include <iostream>
#include "ftdi.h"

Ftdi::Ftdi(int pidIn, int vidIn) :pid(pidIn), vid(vidIn)
{
	//Allocate and init FTDI context
	context = ftdi_new();
	if(!context)
	{
		FtdiLibException e("Failed to allocate/init FTDI context");
		throw e;
	}

	//Try and find devices
	self.noDevs = ftdi_usb_find_all(self.context, &self.devlist, self.vid, self.pid);

	if(self.noDevs < 0)
	{
		self.noDevs = 0;
		FtdiLibException e(self.context);
		throw e;
	}
}
