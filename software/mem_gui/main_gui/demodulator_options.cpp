//
// Created by josh on 10/07/17.
//

#include <generic_classes.hpp>
#include "demodulator_options.hpp"

void DemodulatorOptions::resetWidgetContents(void)
{
    demodPulseWidth->set_value(statusManager.getDemodParams().pulseWidth);
}

DemodulatorOptions::DemodulatorOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                                       StatusManager &statusManagerIn)
        :GuiSection(builderIn, systemOptionsIn), statusManager(statusManagerIn)
{
    addWidget("demod_pulse_width",demodPulseWidth);
    addWidget("demod_send", demodSend);
    addWidget("demod_pulse_width_conversion",demodPulseWidthConversion);
    demodSend->signal_clicked().connect(sigc::mem_fun(*this, &DemodulatorOptions::onSend));
    demodPulseWidth->signal_changed().connect(sigc::mem_fun(*this, &DemodulatorOptions::updateExplanatoryText));
}

void DemodulatorOptions::setWidgetVisibility(SystemStatus status)
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

void DemodulatorOptions::onSend(void)
{
    StatusManager::demodParams newParams;
    newParams.pulseWidth = (unsigned int) demodPulseWidth->get_value_as_int();
    statusManager.setDemodParams(newParams);
}

void DemodulatorOptions::setDefaultValues(void)
{

    demodPulseWidth->set_value(timeToCycles(1.5e-6));
    onSend();
}

void DemodulatorOptions::updateExplanatoryText(void)
{
    double valUs = cyclesToTime((unsigned int)demodPulseWidth->get_value_as_int())*1e6; //Value in microseconds
    demodPulseWidthConversion->set_text("= "+std::to_string(valUs)+"us");
}