//
// Created by josh on 10/07/17.
//

#include "modulator_options.hpp"

void ModulatorOptions::resetWidgetContents(void)
{
    cyclesPerHalfPeriod->set_value(statusManager.getModParams().cyclesPerHalfPeriod);
}

ModulatorOptions::ModulatorOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                                   StatusManager &statusManagerIn)
:GuiSection(builderIn,systemOptionsIn), statusManager(statusManagerIn)
{
    addWidget("cycles_per_half_period",cyclesPerHalfPeriod);
    addWidget("cycles_per_half_period_conversion",cyclesPerHalfPeriodConversion);
    addWidget("mod_freq_conversion",freqConversion);
    addWidget("mod_send", modSend);
    modSend->signal_clicked().connect(sigc::mem_fun(*this, &ModulatorOptions::onSend));
    cyclesPerHalfPeriod->signal_changed().connect(sigc::mem_fun(*this, &ModulatorOptions::updateExplanatoryText));
}

void ModulatorOptions::onSend(void)
{
    StatusManager::modParams newParams;
    newParams.cyclesPerHalfPeriod = (unsigned int) cyclesPerHalfPeriod->get_value_as_int();
    statusManager.setModParams(newParams);
}

//This runs in a callback whenever any of the modulator parameters change
void ModulatorOptions::updateExplanatoryText(void)
{
    double valUs = cyclesToTime((unsigned int)cyclesPerHalfPeriod->get_value_as_int())*1e6; //Value in microseconds
    cyclesPerHalfPeriodConversion->set_text("= "+std::to_string(valUs)+"us");
    freqConversion->set_text("The signal will be modulated with "+std::to_string(1.0/(2.0*valUs))+"MHz");
}

void ModulatorOptions::setWidgetVisibility(SystemStatus status)
{
    bool visible = false;
    switch(status)
    {
        case SystemStatus::disconnected: case SystemStatus::running:
            visible = false;
            break;
        case SystemStatus::stopped:
            visible = true;
            break;
    }

    setAllWidgetSensitivity(visible);
}

void ModulatorOptions::setDefaultValues(void)
{
    cyclesPerHalfPeriod->set_value(timeToCycles(0.5*(1/(13.5e6))));
    onSend();
}
