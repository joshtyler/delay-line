// Class to handle Serial comms
// Uses CPP FTDI handles

#include <iostream>
#include "serial.hpp"

Serial::Serial(int vidIn, int pidIn)
:vid(vidIn), pid(pidIn)
{
//	std::cout << "Set interface ret: " << context.set_interface(INTERFACE_A) << std::endl;
//	std::cout << "Open ret: " << context.open(vid, pid) << std::endl;

}

//This does not work!
void Serial::listDevices(void)
{
	List* list = List::find_all(context, vid, pid);

	for(List::iterator it = list->begin(); it != list->end(); it++)
	{
		std::cout << it->vendor() << ", " <<  it->description() << ", " <<  it->serial() << ", ";

		if(it->open())
		{
			std::cout <<"Open Fails";	
		} else {
			std::cout <<"Open OK";
		}

		it->close();

		std::cout << std::endl;
	}

	delete list;
}
