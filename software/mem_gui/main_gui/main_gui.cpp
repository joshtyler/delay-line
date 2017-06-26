// Gui which user uses to interact with appliacation
// Based on GTKMM3 and Glade

#include "main_gui.hpp"

bool MainGui::onIdle(void)
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

    return false; //Idle task not complete
}

MainGui::MainGui(UartManager& uartManagerin, StatusManager& statusManagerIn,
                 std::vector<MemoryManager *>& memArrIn)
:uartManager(uartManagerin), statusManager(statusManagerIn), memArr(memArrIn)
{
    //Setup button
    start.add_label("Start");
    start.signal_clicked().connect(sigc::mem_fun(*this, &MainGui::on_start_clicked));
    add(start);
    show_all_children();

    //Set Idle function to be main loop
    Glib::signal_idle().connect( sigc::mem_fun(*this, &MainGui::onIdle) );
}

void MainGui::on_start_clicked()
{
    std::cout << "Button was clicked." << std::endl;
}
