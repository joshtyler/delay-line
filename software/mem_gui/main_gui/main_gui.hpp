// Gui which user uses to interact with appliacation
// Based on GTKMM3 and Glade

#ifndef MAINGUI_HPP
#define MAINGUI_HPP

#include <gtkmm.h>
#include <uart_manager.hpp>
#include <array>

#include "../status_manager/status_manager.hpp"
#include "../memory_manager/memory_manager.hpp"
#include "../generic_classes/generic_classes.hpp"
#include "system_options.hpp"
#include "port_options.hpp"
#include "modulator_options.hpp"
#include "demodulator_options.hpp"
#include "memory_manager_options.hpp"
#include "run_options.hpp"
#include "memory_options.hpp"
#include "log_options.hpp"

class MainGuiException : public GenericException
{
    public:
        MainGuiException(std::string str) :GenericException("Main GUI exception: ", str) {};
};


class MainGui : public Gtk::Window
{
    public:
        MainGui(BaseObjectType* cobject, const Glib::RefPtr<Gtk::Builder>& refGlade);
        ~MainGui();
        Glib::RefPtr<Gtk::Builder> getBuilder(void) const {return builder;};

    protected:
        //GTK stuff
        Glib::RefPtr<Gtk::Builder> builder;
        bool onIdle(void); //Processing to perform on GTK idle

        //Local classes and parameters
        FtdiWrapper serial;
        UartManager uartManager;

        StatusManager statusManager;
        std::vector<MemoryManager*>  memArr;

        //GUI options sections
        SystemOptions systemOptions;
        PortOptions portOptions;
        ModulatorOptions modulatorOptions;
        DemodulatorOptions demodulatorOptions;
        MemoryManagerOptions memoryManagerOptions;
        RunOptions runOptions;
        MemoryOptions memoryOptions;
        LogOptions logOptions;

        //Put run options at the start to ensure that run status changes are added to the queue before others
        std::array<GuiSection*,8> guiOptionsArr = {{&runOptions, &systemOptions, &portOptions, &modulatorOptions, &demodulatorOptions, &memoryManagerOptions, &memoryOptions, &logOptions}};

        //Log
        std::stringstream logStream;



};




#endif
