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

    protected:
        //GTK stuff
        Glib::RefPtr<Gtk::Builder> builder;
        bool onIdle(void); //Processing to perform on GTK idle

        //Local classes and parameters
        FtdiWrapper serial;
        UartManager uartManager;
        StatusManager statusManager;
        std::vector<MemoryManager*>  memArr;

        //System options
        Gtk::Entry *noNums;
        Gtk::Button *resetParameters;

        //Method to update the GUI numbers
        void onResetParameters(void);

        //Port parameters
        Gtk::Button* connect;
        Gtk::Entry* baud;
        void onConnectClicked();
        //Model for port select combobox
        class PortColumnModel : public Gtk::TreeModel::ColumnRecord
        {
            public:

                PortColumnModel()
                { add(id); add(manufacturer); add(description);};

                Gtk::TreeModelColumn<unsigned int> id;
                Gtk::TreeModelColumn<Glib::ustring> manufacturer;
                Gtk::TreeModelColumn<Glib::ustring> description;
        };
        PortColumnModel portColumnModel;
        Gtk::ComboBox* portComboBox;
        Glib::RefPtr<Gtk::ListStore> portComboBoxRefTreeModel;
        void updatePortComboBox(void); //Poll FTDI driver and upate contents of UART box

        //Modulator parameters
        Gtk::SpinButton *cyclesPerHalfPeriod;
        Gtk::Button *modSend;
        void onModSend(void);

        //memory manager parameters
        Gtk::ToggleButton *testMode;
        Gtk::SpinButton *pulseWidth, *pulseGap;
        Gtk::Button *memSend;
        void onMemSend(void);

        //run button
        Gtk::ToggleButton *run;
        void onRun(void);

        //memory updater
        Gtk::SpinButton *addr;
        Gtk::Entry *value;
        Gtk::Button *memRequestSend;
        void onMemRequestSend(void);


        //Log
        Gtk::TextView *log;
        Glib::RefPtr<Gtk::TextBuffer> logBuffer;
        std::stringstream logStream;



};


#endif
