//
// Created by josh on 10/07/17.
//

#include <random>
#include <iomanip>
#include "memory_options.hpp"

MemoryOptions::MemoryOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                             StatusManager &statusManagerIn, std::vector<MemoryManager *> &memArrIn)
        :GuiSection(builderIn, systemOptionsIn), statusManager(statusManagerIn), memArr(memArrIn)
{
    //Setup memory updater
    addWidget("addr", addr);
    addWidget("value", value);
    addWidget("mem_request_send", memRequestSend);
    memRequestSend->signal_clicked().connect(sigc::mem_fun(*this, &MemoryOptions::onMemRequestSend));


    //Setup memory viewer
    addWidget("mem_viewer", memViewer);
    memViewerTreeModel = Gtk::ListStore::create(memViewerModel);
    memViewer->set_model(memViewerTreeModel);
    memViewer->append_column_numeric("Address", memViewerModel.addr, "%0d");
    memViewer->append_column("Data (hex)", memViewerModel.val);

    addWidget("fill_zeros",fillZeros);
    addWidget("fill_ones",fillOnes);
    addWidget("fill_rand",fillRand);
    fillZeros->signal_clicked().connect(sigc::bind<FillTypes>(sigc::mem_fun(*this, &MemoryOptions::fillMem),FillTypes::zeros));
    fillOnes->signal_clicked().connect(sigc::bind<FillTypes>(sigc::mem_fun(*this, &MemoryOptions::fillMem),FillTypes::ones));
    fillRand->signal_clicked().connect(sigc::bind<FillTypes>(sigc::mem_fun(*this, &MemoryOptions::fillMem),FillTypes::random));
}

void MemoryOptions::setWidgetVisibility(SystemStatus status)
{
    bool visible = false;
    switch(status)
    {
        case SystemStatus::disconnected: case SystemStatus::stopped:
            visible = false;
            break;
        case SystemStatus::running:
            visible = true;
            break;
    }

    setAllWidgetSensitivity(visible);
}

void MemoryOptions::createMemViewer(void)
{
    for(auto it = memArr.begin(); it != memArr.end(); it++)
    {
        auto addr = std::distance(memArr.begin(),it);
        Gtk::TreeModel::Row row = *(memViewerTreeModel->append());
        row[memViewerModel.addr] = addr;
        row[memViewerModel.val] = formatHexNum(0);
    }

}

void MemoryOptions::updateMemViewer(void)
{
    for(auto it = memViewerTreeModel->children().begin(); it != memViewerTreeModel->children().end(); it++)
    {
        auto addr = std::distance(memViewerTreeModel->children().begin(),it);
        (*it)[memViewerModel.val] = formatHexNum(memArr[addr]->getCurVal());
    }

}

//What to do if someone wants to update a memory location
void MemoryOptions::onMemRequestSend(void)
{
    unsigned int reqAddr = (unsigned int) addr->get_value_as_int();
    std::string valText = value->get_text();
    memArr[reqAddr]->setVal((unsigned long) stol(valText,0,16)); //Get value in base 16
}

//Fill the memory with either 0s, 1s, or random data, as instructed
void MemoryOptions::fillMem(MemoryOptions::FillTypes f)
{
    const ParamType maxNum = 0x7FFFFFFFF; //Don't set MSB as this is a spacer

    //Random number logic from https://stackoverflow.com/questions/7560114/random-number-c-in-some-range
    std::random_device rd; // obtain a random number from hardware
    std::mt19937 eng(rd()); // seed the generator
    std::uniform_int_distribution<unsigned long> distr(0, maxNum); // define the range


    for(auto it =memArr.begin(); it!= memArr.end(); it++)
    {
        unsigned int addr = std::distance(memArr.begin(),it); //Get index of current memory location
        ParamType newVal;

        switch(f)
        {
            case FillTypes::zeros:
                newVal = 0;
                break;

            case FillTypes::ones:
                newVal = maxNum;
                break;

            case FillTypes::random:
                newVal = distr(eng);
                break;

        }

        memArr[addr]->setVal(newVal);
    }
}

std::string MemoryOptions::formatHexNum(ParamType num)
{
    std::ostringstream ss;
    ss << std::hex << std::setfill ('0') << std::setw (9) << num;
    return ss.str();
}
