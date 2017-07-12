//
// Created by josh on 10/07/17.
//

#include "run_options.hpp"

RunOptions::RunOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                       StatusManager &statusManagerIn)
        :GuiSection(builderIn, systemOptionsIn), statusManager(statusManagerIn),resetRequest(false)
{
    addWidget("run",run);
    addWidget("reset_parameters", resetParameters);

    //Setup reset parameters callback
    resetParameters->signal_clicked().connect(sigc::mem_fun(*this, &RunOptions::resetParamsCallback));
    run->signal_clicked().connect(sigc::mem_fun(*this, &RunOptions::runCallback));
}

void RunOptions::setWidgetVisibility(SystemStatus status)
{
    bool visible = false;
    switch(status)
    {
        case SystemStatus::disconnected :
            visible = false;
            break;
        case SystemStatus::stopped: case SystemStatus::running:
            visible = true;
            break;
    }

    setAllWidgetSensitivity(visible);
}

void RunOptions::resetParamsCallback(void)
{
    resetRequest = true;
}

bool RunOptions::resetRequested(void)
{
    if(resetRequest)
    {
        resetRequest = false;
        return true;
    }

    return false;
}

void RunOptions::runCallback(void)
{
    StatusManager::sysStatus newStatus;
    newStatus.run = getRun() ? 1 : 0;
    statusManager.setSysStatus(newStatus);
}

