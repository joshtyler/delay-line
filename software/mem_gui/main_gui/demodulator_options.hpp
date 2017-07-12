//
// Created by josh on 10/07/17.
//

#ifndef DEMODULATOR_OPTIONS_HPP
#define DEMODULATOR_OPTIONS_HPP

#include <gtkmm/builder.h>
#include <gtkmm/spinbutton.h>
#include <gtkmm/label.h>
#include <gtkmm/button.h>
#include <generic_classes.hpp>
#include "../status_manager/status_manager.hpp"
#include "system_options.hpp"

class DemodulatorOptions : public GuiSection
{
    public:
        DemodulatorOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                                   StatusManager &statusManagerIn);
        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void);
        void setDefaultValues(void);

    private:
        StatusManager &statusManager;
        Gtk::SpinButton *demodPulseWidth;
        Gtk::Button *demodSend;
        Gtk::Label *demodPulseWidthConversion;
        void onSend(void);
        void updateExplanatoryText(void);
};


#endif
