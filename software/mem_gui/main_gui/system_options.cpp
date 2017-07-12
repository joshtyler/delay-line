// Looks after the system options section of the GUI

#include "system_options.hpp"
#include "main_gui.hpp"

SystemOptions::SystemOptions(Glib::RefPtr<Gtk::Builder> builderIn)
:GuiSection(builderIn, *this)
{
    //Add widgets
    addWidget("no_nums", noNums);
    addWidget("fpga_freq", fpgaFreq);

    noNums->signal_changed().connect(sigc::mem_fun(*this, &SystemOptions::setNoNums));
    fpgaFreq->signal_changed().connect(sigc::mem_fun(*this, &SystemOptions::setFpgaPeriod));
    setNoNums();
    setFpgaPeriod();
}

void SystemOptions::setWidgetVisibility(SystemStatus status)
{
    bool visible = false;
    switch(status)
    {
        case SystemStatus::disconnected :
            visible = true;
            break;
        case SystemStatus::stopped: case SystemStatus::running:
            visible = false;
            break;
    }

    setAllWidgetSensitivity(visible);
}

//We only need to reset the fpgaFreq widget
void SystemOptions::resetWidgetContents(void)
{
    double realFpgaFreq = 1.0/realFpgaPeriod;
    fpgaFreq->set_text(std::to_string(realFpgaFreq/1e6)); //Value in box should be in MHz
}

void SystemOptions::setFpgaPeriod(void)
{
    //Get FPGA frequency
    double realFpgaFreq = entryToDbl(fpgaFreq)*1e6; //Value in text box is in MHz
    realFpgaPeriod = 1.0/realFpgaFreq;
}



