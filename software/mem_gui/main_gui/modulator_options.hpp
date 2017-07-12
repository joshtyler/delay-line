//
// Created by josh on 10/07/17.
//

#ifndef MODULATOR_OPTIONS_HPP
#define MODULATOR_OPTIONS_HPP

#include <generic_classes.hpp>
#include <gtkmm/spinbutton.h>
#include <gtkmm/button.h>
#include "../status_manager/status_manager.hpp"
#include "system_options.hpp"

class ModulatorOptionsException : public GenericException
{
    public:
        ModulatorOptionsException(std::string str) :GenericException("System options exception: ", str) {};
};


class ModulatorOptions : public GuiSection
{
    public:
        ModulatorOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                                 StatusManager &statusManagerIn);
        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void);
        void setDefaultValues(void);

    private:
        StatusManager &statusManager;
        Gtk::SpinButton *cyclesPerHalfPeriod;
        Gtk::Label *cyclesPerHalfPeriodConversion;
        Gtk::Label *freqConversion;
        Gtk::Button *modSend;
        void onSend(void);
        void updateExplanatoryText(void);
};


#endif
