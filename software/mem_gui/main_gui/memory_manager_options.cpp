//
// Created by josh on 10/07/17.
//

#include "memory_manager_options.hpp"

MemoryManagerOptions::MemoryManagerOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                                           StatusManager &statusManagerIn, const std::vector<MemoryManager*> &memArrIn)
        :GuiSection(builderIn, systemOptionsIn), statusManager(statusManagerIn), memArr(memArrIn)
{
    addWidget("test_mode", testMode);
    addWidget("pulse_width", pulseWidth);
    addWidget("pulse_gap", pulseGap);
    addWidget("mem_manager_send", memSend);
    addWidget("pulse_width_conversion", pulseWidthConvserion);
    addWidget("pulse_gap_conversion", pulseGapConversion);
    addWidget("mem_freq_conversion", freqConversion);

    memSend->signal_clicked().connect(sigc::mem_fun(*this, &MemoryManagerOptions::onSend));

    pulseWidth->signal_changed().connect(sigc::mem_fun(*this, &MemoryManagerOptions::updateExplanatoryText));
    pulseGap->signal_changed().connect(sigc::mem_fun(*this, &MemoryManagerOptions::updateExplanatoryText));

}

void MemoryManagerOptions::setWidgetVisibility(SystemStatus status)
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

void MemoryManagerOptions::onSend(void)
{
    StatusManager::memParams newParams;
    newParams.testMode = testMode->get_active() ? 1 : 0;
    newParams.pulseWidth = (ParamType) pulseWidth->get_value_as_int();
    newParams.pulseGap = (ParamType) pulseGap->get_value_as_int();
    newParams.noNums = memArr.size(); //Don't change no. nums
    statusManager.setMemParams(newParams);
}

void MemoryManagerOptions::resetWidgetContents(void)
{
    //Update memory manager options
    testMode->set_active((bool)statusManager.getMemParams().testMode);
    pulseWidth->set_value(statusManager.getMemParams().pulseWidth);
    pulseGap->set_value(statusManager.getMemParams().pulseGap);

}

void MemoryManagerOptions::setDefaultValues(void)
{
    testMode->set_active(false); //Test mode off by default
    pulseWidth->set_value(timeToCycles(0.9e-6));
    pulseGap->set_value(timeToCycles(1.1e-6));
    onSend();
}

void MemoryManagerOptions::updateExplanatoryText(void)
{
    double pulseUs = cyclesToTime((unsigned int)pulseWidth->get_value_as_int())*1e6;
    double gapUs = cyclesToTime((unsigned int)pulseGap->get_value_as_int())*1e6;
    double bitTimeUs = pulseUs + gapUs;
    double bitTimeKhz = (1.0/bitTimeUs)*1e3; //*1e3 to go from MHz to KHz
    double totalDelay = memArr.size() * bitTimeUs * 36 *1e-3; // *1e-3 to go from us to ms

    pulseWidthConvserion->set_text("= "+std::to_string(pulseUs)+"us");
    pulseGapConversion->set_text("= "+std::to_string(gapUs)+"us");

    freqConversion->set_text(
            "The bit time is "+std::to_string(bitTimeUs)+"us, giving a circulating bit rate of "+std::to_string(bitTimeKhz)+"kHz.\n"
            "The delay time for all bits is therefore "+std::to_string(totalDelay)+"ms."
    );
}

