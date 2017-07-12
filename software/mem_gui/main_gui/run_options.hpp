//
// Created by josh on 10/07/17.
//

#ifndef RUN_OPTIONS_HPP
#define RUN_OPTIONS_HPP


#include <generic_classes.hpp>
#include <gtkmm/togglebutton.h>
#include <gtkmm/button.h>
#include "../status_manager/status_manager.hpp"

class RunOptions : public GuiSection
{
    public:
        RunOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                           StatusManager &statusManagerIn);
        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void) {}; //Nothing to do!
        bool getRun(void) const {return run->get_active();};
        void setRun(bool status) {run->set_active(status);};
        bool resetRequested(void);
        void setDefaultValues(void) {runCallback();};

    private:
        StatusManager &statusManager;

        Gtk::ToggleButton *run;
        Gtk::Button *resetParameters;

        void resetParamsCallback(void);
        void runCallback(void);
        bool resetRequest; //Function to check if the user has requested a reset.
};


#endif
