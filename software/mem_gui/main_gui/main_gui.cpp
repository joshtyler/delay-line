// Gui which user uses to interact with appliacation
// Based on GTKMM3 and Glade

#include "main_gui.hpp"
#include <string>
#include <sstream>
#include <cassert>


MainGui::MainGui(BaseObjectType* cobject, const Glib::RefPtr<Gtk::Builder>& refGlade)
        : Gtk::Window(cobject), builder(refGlade),  serial(0, 0), uartManager(serial, 1.0, logStream),
          systemOptions(refGlade),
          portOptions(refGlade, systemOptions, serial, memArr),
          modulatorOptions(refGlade, systemOptions, statusManager),
          demodulatorOptions(refGlade, systemOptions, statusManager),
          memoryManagerOptions(refGlade, systemOptions, statusManager, memArr),
          runOptions(refGlade, systemOptions, statusManager),
          memoryOptions(refGlade, systemOptions, statusManager, memArr),
          logOptions(refGlade, systemOptions)
{

    //Set Idle function to be main loop
    Glib::signal_idle().connect( sigc::mem_fun(*this, &MainGui::onIdle) );
}

MainGui::~MainGui()
{
    if(serial.isOpen())
    {
        serial.close();
    }

    //Free Memory manager array
    for(auto it = memArr.begin(); it != memArr.end(); it++)
    {
        delete *it;
    }

}


bool MainGui::onIdle(void)
{
    static SystemStatus state = SystemStatus::disconnected;

    switch(state)
    {
        case(SystemStatus::disconnected):
        {
            if(serial.isOpen()) //If we have just connected
            {
                //Setup memory manager now we know how big the memory is
                //Create memory managers
                //We use dynamic memory allocation here, we free it in the destructor
                unsigned long memSize = systemOptions.getNoNums();
                for (unsigned int i = 0; i < memSize; i++)
                {
                    memArr.push_back(new MemoryManager(i));
                }
                    assert(memSize == memArr.size()); //Check that we have set up the array correctly

                    memoryOptions.createMemViewer();

                    //Ensure the system is not running
                    runOptions.setRun(false);


                    //Set default values for parameters
                    for(auto it = guiOptionsArr.begin(); it != guiOptionsArr.end(); it++)
                    {
                        (*it)->setDefaultValues();
                    }

                state = SystemStatus::stopped;
            }
        } break;


        case(SystemStatus::stopped): case(SystemStatus::running):
        {
            if(serial.isOpen()) //If we have just connected
            {
                //Handle UART messages
                uartManager.update();

                if (uartManager.receiveQueueSize() > 0)
                {
                    UartMessage curMsg = uartManager.receive();

                    switch (curMsg.getHeader())
                    {
                        case UartMessage::REPLACE_NUM_DONE:
                        {
                            ReplaceNumDone repMsg(curMsg);
                            memArr[repMsg.getAddr()]->processMessage(curMsg);
                        }
                            break;
                        case UartMessage::ACK:
                        {
                            UartMessage::messageHeaders head = Ack(curMsg).getUnderlyingMsg().getHeader();
                            if (head == UartMessage::MOD_PARAMS || head == UartMessage::MEM_PARAMS ||
                                head == UartMessage::SYS_STATUS)
                            {
                                statusManager.processMessage(curMsg);
                            }
                            //We do not need to process other types
                        }
                            break;
                        case UartMessage::RECEIVED_WRONG_NUM:
                        {
                            //Stop and clear memory
                            runOptions.setRun(false);
                            for (auto it = memArr.begin(); it != memArr.end(); it++)
                            {
                                (*it)->clear();
                            }
                        }
                            break;
                        default:
                            break; //We do not need to handle these message types
                    }
                }

                //Get messages from status manager
                if (statusManager.messageWaiting())
                {
                    uartManager.send(statusManager.getMessage());
                }

                //Get messages from memory managers
                for (auto it = memArr.begin(); it != memArr.end(); it++)
                {
                    if ((**it).messageWaiting())
                    {
                        uartManager.send((**it).getMessage());
                    }
                }

                //Update memory gui
                memoryOptions.updateMemViewer();

                //Reset the values of the options boxes, if the user has requested
                if(runOptions.resetRequested())
                {
                    for(auto it = guiOptionsArr.begin(); it != guiOptionsArr.end(); it++)
                    {
                        (*it)->resetWidgetContents();
                    }
                }

                //Update status
                if(statusManager.getSysParams().run)
                {
                    state = SystemStatus::running;
                } else {
                    state = SystemStatus::stopped;
                }
            } else {
                throw MainGuiException("Serial port unexpectedly closed");
            }

        }break;

    }

    //Set visibility correctly
    for(auto it = guiOptionsArr.begin(); it != guiOptionsArr.end(); it++)
    {
        (*it)->setWidgetVisibility(state);
    }

    //Update log
    logOptions.updateLog(logStream);


    return true; //Idle task not complete
}
