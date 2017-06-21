// C++ wrapper for libftdi
// Initialise serial port and read data

#include <iostream>
#include <iomanip> //For setw
#include "ftdi.h"
#include "ftdi_wrapper.h"

FtdiWrapper::FtdiWrapper(int vidIn, int pidIn)
:vid(vidIn), pid(pidIn), noDevs(0), state(false)
{
	//Allocate and init FTDI context
	context = ftdi_new();
	if(!context)
	{
		throw FtdiLibException("Failed to allocate/init FTDI context");
	}

	checkRet(ftdi_set_interface(context, INTERFACE_B)); //Always use interface B

	//Try and find devices
	refresh();
}

FtdiWrapper::~FtdiWrapper()
{
	ftdi_free(context);
}


void FtdiWrapper::refresh(void)
{
	checkRet(ftdi_usb_find_all(context, &devList, vid, pid));
}

void FtdiWrapper::listDevs(void)
{
	struct ftdi_device_list *curDev;
	const int bufSize = 30;
	char manufacturer[bufSize];
	char description[bufSize];


	refresh();

	std::cout << "Index\t" << std::left << std::setw(bufSize-1) << "Manufacturer"  << "Description" << std::endl;

	int i;
	for(curDev = devList, i = 0; curDev != NULL; curDev = curDev->next, i++)
	{

		checkRet(ftdi_usb_get_strings(context, curDev->dev, manufacturer, bufSize, description, bufSize, NULL, 0));

		std::cout << i << "\t" << std::left << std::setw(bufSize-1) << manufacturer << description  << std::endl;
	}
}

void FtdiWrapper::open(unsigned int idx, int baud)
{
	checkState(false); //Check closed

	struct ftdi_device_list *curDev = devList;
	
	if(curDev == NULL)
	{
		throw std::out_of_range("Index out of range. No devices are available.");
	}


	//Find device corresponding to index
	unsigned int i=0;
	while(i < idx)
	{
		curDev = curDev->next;
		if(curDev == NULL)
		{
			throw std::out_of_range("Index is greater than number of devices available.");
		}
	}

	//Open
	checkRet(ftdi_usb_open_dev(context, curDev->dev));

	//Set baud rate
	checkRet(ftdi_set_baudrate(context, baud)); 

}

void FtdiWrapper::close(void)
{
	checkState(false); //Check open
	
}

void FtdiWrapper::checkState(bool stateIn)
{
	if(stateIn != state)
	{
		std::string stateStr = state? "open" : "closed";

		throw FtdiWrapperException("Error. Port is "+stateStr);
	}
}

void FtdiWrapper::checkRet(int ret)
{
	if(ret < 0)
	{
		throw FtdiLibException(context);
	}
}



