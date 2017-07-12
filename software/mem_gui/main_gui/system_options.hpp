// Looks after the system options section of the GUI

#ifndef SYSTEM_OPTIONS_HPP
#define SYSTEM_OPTIONS_HPP

#include <gtkmm.h>
#include <generic_classes.hpp>


class SystemOptions : public GuiSection
{
    public:
        SystemOptions(Glib::RefPtr<Gtk::Builder> builderIn);
        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void);
        double getFgpaPeriod(void) const {return realFpgaPeriod;};
        unsigned long getNoNums(void) const {return realNoNums;};
        void setDefaultValues(void) {}; //Do nothing

    private:
        Gtk::Entry *noNums;
        Gtk::Entry *fpgaFreq;
        double realFpgaPeriod;
        unsigned long realNoNums;
        void setFpgaPeriod(void); //Set the fpga frequency from user input
        void setNoNums(void) {realNoNums = entryToUl(noNums);}; //Set the number of numbers from user input
};


#endif
