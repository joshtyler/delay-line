// Gui which user uses to interact with appliacation
// Based on GTKMM3 and Glade

#ifndef MAINGUI_HPP
#define MAINGUI_HPP

#include <gtkmm.h>
#include <uart_manager.hpp>
#include <array>
#include "../status_manager/status_manager.hpp"
#include "../memory_manager/memory_manager.hpp"
#include "../mem_gui.hpp"

class MainGui : public Gtk::Window
{
    public:
        MainGui(UartManager& uartManagerin, StatusManager& statusManagerIn, std::vector<MemoryManager*>& memArrIn);

    protected:
        bool onIdle(void); //Processing to perform on GTK idle
        UartManager& uartManager;
        StatusManager& statusManager;
        std::vector<MemoryManager*>&  memArr;

        Gtk::Button start;
        void on_start_clicked();
};


#endif
