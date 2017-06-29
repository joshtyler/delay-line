// Gui which user uses to interact with appliacation
// Based on GTKMM3 and Glade

#include "main_gui.hpp"
#include <string>
#include <sstream>
#include <cassert>


MainGui::MainGui(BaseObjectType* cobject, const Glib::RefPtr<Gtk::Builder>& refGlade)
        :Gtk::Window(cobject), builder(refGlade), serial(0,0), uartManager(serial,1.0,logStream) //Our device is 0x0403, 0x6010. But 0,0 searches all common FTDI devices
{

    //SETUP GUI

    //Setup system options
    builder->get_widget("no_nums", noNums);
    builder->get_widget("reset_parameters", resetParameters);
    resetParameters->signal_clicked().connect(sigc::mem_fun(*this, &MainGui::onResetParameters));

    //Setup port parameters
    //Connect button
    builder->get_widget("connect", connect);
    connect->signal_clicked().connect(sigc::mem_fun(*this, &MainGui::onConnectClicked));

    //Baud entry
    builder->get_widget("baud", baud);

    //Combo box
    builder->get_widget("port", portComboBox);
    portComboBoxRefTreeModel = Gtk::ListStore::create(portColumnModel);
    portComboBox->set_model(portComboBoxRefTreeModel);
    updatePortComboBox();
    portComboBox->pack_start(portColumnModel.id);
    portComboBox->pack_start(portColumnModel.manufacturer);
    portComboBox->pack_start(portColumnModel.description);

    //Setup modulator parameters
    builder->get_widget("cycles_per_half_period",cyclesPerHalfPeriod);
    builder->get_widget("mod_send", modSend);
    modSend->signal_clicked().connect(sigc::mem_fun(*this, &MainGui::onModSend));

    //Setup memory manager parameters
    builder->get_widget("test_mode", testMode);
    builder->get_widget("pulse_width", pulseWidth);
    builder->get_widget("pulse_gap", pulseGap);
    builder->get_widget("mem_manager_send", memSend);
    memSend->signal_clicked().connect(sigc::mem_fun(*this, &MainGui::onMemSend));

    //Setup run button
    builder->get_widget("run", run);
    run->signal_clicked().connect(sigc::mem_fun(*this, &MainGui::onRun));

    //Setup memory updater
    builder->get_widget("addr", addr);
    builder->get_widget("value", value);
    builder->get_widget("mem_request_send", memRequestSend);
    memRequestSend->signal_clicked().connect(sigc::mem_fun(*this, &MainGui::onMemRequestSend));


    //Setup memory viewer
    builder->get_widget("mem_viewer", memViewer);
    memViewerTreeModel = Gtk::ListStore::create(memViewerModel);
    memViewer->set_model(memViewerTreeModel);
    memViewer->append_column_numeric("Address", memViewerModel.addr, "%0d");
    memViewer->append_column_numeric("Data (hex)", memViewerModel.val, "%09x");


    //Setup log
    builder->get_widget("log", log);
    logBuffer = Gtk::TextBuffer::create();
    log->set_buffer(logBuffer);

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
    if(serial.isOpen()) //Only run this if the serial port is open
    {
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

        //Update the memory viewer
        updateMemViewer();
    }

    //Only update the text view when we have something to update it with
    //Replacing the entire contents on every iteration causes jagged scrollbar behaviour
    if(logStream.str() != logBuffer->get_text())
    {
        logBuffer->set_text(logStream.str());
    }

    return true; //Idle task not complete
}


void MainGui::onConnectClicked()
{
    //Get ID from combo box
    unsigned int id;
    auto iter = portComboBox->get_active();
    if(iter)
    {
        auto row = *iter;
        if(row)
        {
            id = row[portColumnModel.id];
        } else {
            throw MainGuiException("Port combo box active row pointee invalid");
        }
    } else {
        throw MainGuiException("Port combo box active row pointer invalid");
    }

    //Get baud rate
    std::string baudText = baud->get_text();

    serial.open(id,stoi(baudText));

    //Disable port widgets (and number of numbers widget) now port is open
    noNums->set_sensitive(false);
    baud->set_sensitive(false);
    connect->set_sensitive(false);
    portComboBox->set_sensitive(false);
    baud->set_text(std::to_string(serial.getBaud())); //Set true baud rate

    //Setup memory manager now we know how big the memory is
    //Create memory managers
    //We use dynamic memory allocation here, we free it at the end of the program
    std::string memSizeStr = noNums->get_text();
    unsigned int memSize = (unsigned int) stoi(memSizeStr);

    for(unsigned int i = 0; i < memSize; i++)
    {
        memArr.push_back(new MemoryManager(i));
    }

    assert(memSize == memArr.size()); //Check that we have set up the array correctly

    createMemViewer();

    //Ensure that system is not running before we send initial parameters
    //Don't use onRun for this because we don't want the initial parameters being overwritten
    StatusManager::sysStatus initialSysStatus;
    initialSysStatus.run = 0;
    statusManager.setSysStatus(initialSysStatus);

    onMemSend(); //Write defaults from glade file
    onModSend();
    onRun(); //
}

void MainGui::updatePortComboBox(void)
{
    portComboBoxRefTreeModel->clear();
    std::list<FtdiWrapper::devType> list = serial.listDevs();
    for(auto it = list.begin(); it != list.end(); it++)
    {
        Gtk::TreeModel::Row row = *(portComboBoxRefTreeModel->append());
        row[portColumnModel.id] = it->id;
        row[portColumnModel.manufacturer] = it->manufacturer;
        row[portColumnModel.description] = it->description;
        portComboBox->set_active(row);
    }

}

void MainGui::createMemViewer(void)
{
    for(auto it = memArr.begin(); it != memArr.end(); it++)
    {
        auto addr = std::distance(memArr.begin(),it);
        Gtk::TreeModel::Row row = *(memViewerTreeModel->append());
        row[memViewerModel.addr] = addr;
        row[memViewerModel.val] = 0;
    }

}

void MainGui::updateMemViewer(void)
{
    for(auto it = memViewerTreeModel->children().begin(); it != memViewerTreeModel->children().end(); it++)
    {
        auto addr = std::distance(memViewerTreeModel->children().begin(),it);
        (*it)[memViewerModel.val] = memArr[addr]->getCurVal();
    }

}

//What to do if someone wants to send modulator paramters
void MainGui::onModSend(void)
{
    StatusManager::modParams newParams;
    newParams.cyclesPerHalfPeriod = (unsigned int) cyclesPerHalfPeriod->get_value_as_int();
    statusManager.setModParams(newParams);
}

//What to do if someone wants to send memory paramters
void MainGui::onMemSend(void)
{
    StatusManager::memParams newParams;
    newParams.testMode = testMode->get_active() ? 1 : 0;
    newParams.pulseWidth = (ParamType) pulseWidth->get_value_as_int();
    newParams.pulseGap = (ParamType) pulseGap->get_value_as_int();
    newParams.noNums = memArr.size(); //Don't change no. nums
    statusManager.setMemParams(newParams);
}

//What to do if someone wants to update a memory location
void MainGui::onMemRequestSend(void)
{
    unsigned int reqAddr = (unsigned int) addr->get_value_as_int();
    std::string valText = value->get_text();
    memArr[reqAddr]->setVal((unsigned int) stoi(valText));
}

//What to do on change of run status
void MainGui::onRun(void)
{
    //Update status manager
    StatusManager::sysStatus newStatus;
    newStatus.run = run->get_active()? 1:0;
    statusManager.setSysStatus(newStatus);

    bool newOptionsState = !run->get_active(); //Dont display options if we are running
    bool newMemUpdaterState = run->get_active(); //Only display mem updater if we are running

    //Update modulator active
    cyclesPerHalfPeriod->set_sensitive(newOptionsState);
    modSend->set_sensitive(newOptionsState);

    //Update mem manager active
    testMode->set_sensitive(newOptionsState);
    pulseWidth->set_sensitive(newOptionsState);
    pulseGap->set_sensitive(newOptionsState);
    memSend->set_sensitive(newOptionsState);

    //Update mem updater active
    addr->set_sensitive(newMemUpdaterState);
    value->set_sensitive(newMemUpdaterState);
    memRequestSend->set_sensitive(newMemUpdaterState);
}

void MainGui::onResetParameters(void)
{
    //Update system options
    noNums->set_text(std::to_string(memArr.size()));

    //Update port options
    baud->set_text(std::to_string(serial.getBaud()));

    //Update modulator options
    cyclesPerHalfPeriod->set_value(statusManager.getModParams().cyclesPerHalfPeriod);

    //Update memory manager options
    testMode->set_active((bool)statusManager.getMemParams().testMode);
    pulseWidth->set_value(statusManager.getMemParams().pulseWidth);
    pulseGap->set_value(statusManager.getMemParams().pulseGap);

}
