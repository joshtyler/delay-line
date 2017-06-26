// Program to handle talking to test harne

#include <iostream>
#include <memory>
#include <gtkmm.h>
#include "uart_manager.hpp"
#include "status_manager/status_manager.hpp"
#include "memory_manager/memory_manager.hpp"
#include "main_gui/main_gui.hpp"


int main(int argc, char **argv)
{

	FtdiWrapper serial(0,0); //Our device is 0x0403, 0x6010. But 0,0 searches all common FTDI devices

	//Setup memory manager array
	std::vector<MemoryManager*> memArr;

	//Create memory managers
	//We use dynamic memory allocation here, we free it at the end of the program
	for(int i = 0; i < memSize; i++)
	{
		memArr.push_back(new MemoryManager(i));
	}

	try{

		//Setup and search for devices
		std::cout << "Number of devices found: " << serial.getNoDevs() << std::endl;
		serial.listDevs();

		//Choose a device and connect
        std::cout << "Choose a device to connnect to: ";
		int idx;
        std::cin >> idx;

        std::cout << "Choose baud: ";
		int baud;
        std::cin >> baud;
		serial.open(idx, baud);
        std::cout << "Connected at baud " << serial.getBaud() << std::endl;

		//Setup uart manager
		UartManager uartManager(serial,1.0,std::cerr);

		//Setup status manager
		StatusManager statusManager;

		//Send some initial parameters
		StatusManager::sysStatus initialSysStatus;
		initialSysStatus.run = 0;
		statusManager.setSysStatus(initialSysStatus);

		StatusManager::memParams initialMemParams;
		initialMemParams.testMode = 0;
		initialMemParams.noNums = memSize;
		initialMemParams.pulseGap = 10;
		initialMemParams.pulseWidth = 10;
		statusManager.setMemParams(initialMemParams);

		StatusManager::modParams initialModParams;
		initialModParams.cyclesPerHalfPeriod = 5;
		statusManager.setModParams(initialModParams);

		initialSysStatus.run = 1;
		statusManager.setSysStatus(initialSysStatus);

        //Setup GUI
        auto app = Gtk::Main(argc, argv);
        MainGui gui(uartManager, statusManager, memArr);

        app.run(gui);


	} catch (const std::exception& exc) {
        std::cerr << exc.what() << std::endl;
	}

	//Close
	serial.close();

    for(auto it = memArr.begin(); it != memArr.end(); it++)
	{
		delete *it;
	}

	return 0;
}
