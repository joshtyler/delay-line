//Looks after serial port

#ifndef PORT_OPTIONS_HPP
#define PORT_OPTIONS_HPP


#include <generic_classes.hpp>
#include <gtkmm/button.h>
#include <gtkmm/entry.h>
#include <gtkmm/combobox.h>
#include <gtkmm/liststore.h>
#include <ftdi_wrapper.hpp>
#include "../memory_manager/memory_manager.hpp"

class PortOptionsException : public GenericException
{
    public:
        PortOptionsException(std::string str) :GenericException("Port options exception: ", str) {};
};

class PortOptions : public GuiSection
{
    public:
        PortOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn, FtdiWrapper &SerialIn, std::vector<MemoryManager *> &memArrIn);

        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void);
        void setDefaultValues(void) {}; //Do nothing


    private:
        FtdiWrapper &serial;
        std::vector<MemoryManager*> &memArr;
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
};


#endif
