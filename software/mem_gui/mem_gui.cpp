// Program to handle talking to test harne

#include <iostream>
#include <typeinfo>
#include <memory>
#include <uart_manager.hpp>
#include "ftdi_wrapper.hpp"
#include "uart_msg.hpp"
#include "status_manager/status_manager.hpp"
#include "memory_manager/memory_manager.hpp"

using namespace std;



int main(int argc, char **argv)
{

	FtdiWrapper serial(0,0); //Our device is 0x0403, 0x6010. But 0,0 searches all common FTDI devices

	const int memSize = 16;

	//Setup memory manager array
	array<MemoryManager*,memSize> memArr;

	//Create memory managers
	//We use dynamic memory allocation here, we free it at the end of the program
	for(int i = 0; i < memSize; i++)
	{
		memArr[i] = new MemoryManager(i);
	}

	try{

		//Setup and search for devices
		cout << "Number of devices found: " << serial.getNoDevs() << endl;
		serial.listDevs();

		//Choose a device and connect
		cout << "Choose a device to connnect to: ";
		int idx;
		cin >> idx;

		cout << "Choose baud: ";
		int baud;
		cin >> baud;
		serial.open(idx, baud);
		cout << "Connected at baud " << serial.getBaud() << endl;

		//Setup uart manager
		UartManager uartManager(serial,1.0,cerr);

		//Setup status manager
		StatusManager statusManager;

		StatusManager::memParams initialMemParams;
		initialMemParams.testMode = 0;
		initialMemParams.noNums = memSize;
		initialMemParams.pulseGap = 10;
		initialMemParams.pulseWidth = 10;
		statusManager.setMemParams(initialMemParams);

		StatusManager::modParams initialModParams;
		initialModParams.cyclesPerHalfPeriod = 5;
		statusManager.setModParams(initialModParams);

		StatusManager::sysStatus initialSysStatus;
		initialSysStatus.run = 1;
		statusManager.setSysStatus(initialSysStatus);

		//Run main loop
		while(true)
		{
			uartManager.update();

			if(uartManager.receiveQueueSize() > 0)
			{
				UartMessage curMsg = uartManager.receive();

				switch(curMsg.getHeader())
				{
					case UartMessage::REPLACE_NUM_DONE:
					{
						ReplaceNumDone repMsg(curMsg);
						memArr[repMsg.getAddr()]->processMessage(curMsg);
					} break;
					case UartMessage::ACK:
					{
                        UartMessage::messageHeaders head = Ack(curMsg).getUnderlyingMsg().getHeader();
                        if(head == UartMessage::MOD_PARAMS || head == UartMessage::MEM_PARAMS || head == UartMessage::SYS_STATUS)
                        {
                            statusManager.processMessage(curMsg);
                        }
                        //We do not need to process other types
					}
					default:
						break; //We do not need to handle these message types
				}
			}
            //Get messages from status manager
            if(statusManager.messageWaiting())
            {
                uartManager.send(statusManager.getMessage());
            }
            //Get messages from memory managers
            for(auto it = memArr.begin(); it != memArr.end(); it++)
            {
                if((**it).messageWaiting())
                {
                    uartManager.send((**it).getMessage());
                }
            }

		}

	} catch (const std::exception& exc) {
		cerr << exc.what() << endl;
	}

	//Close
	serial.close();

    for(auto it = memArr.begin(); it != memArr.end(); it++)
	{
		delete *it;
	}

	return 0;
}
