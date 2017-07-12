//
// Created by josh on 10/07/17.
//

#ifndef MEMORY_MANAGER_OPTIONS_HPP
#define MEMORY_MANAGER_OPTIONS_HPP


#include <generic_classes.hpp>
#include "../status_manager/status_manager.hpp"
#include "system_options.hpp"
#include "../memory_manager/memory_manager.hpp"

class MemoryManagerOptions : public GuiSection
{
    public:
        MemoryManagerOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                             StatusManager &statusManagerIn, const std::vector<MemoryManager*> &memArrIn);
        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void);
        void setDefaultValues(void);


    private:
        StatusManager &statusManager;
        const std::vector<MemoryManager*> &memArr;
        Gtk::ToggleButton *testMode;
        Gtk::SpinButton *pulseWidth, *pulseGap;
        Gtk::Button *memSend;
        Gtk::Label *pulseWidthConvserion, *pulseGapConversion, *freqConversion;

        void onSend(void);
        void updateExplanatoryText(void);

};


#endif
