//Generic classes used by the project

#ifndef GENERIC_TYPES_HPP
#define GENERIC_TYPES_HPP

#include <uart_msg.hpp>
#include <queue>
#include <gtkmm/widget.h>
#include <gtkmm/builder.h>
#include <gtkmm/entry.h>
#include <gtkmm/button.h>
#include <gtkmm/togglebutton.h>
#include <gtkmm/spinbutton.h>
#include <gtkmm/textview.h>
#include <gtkmm/treeview.h>
#include <gtkmm/combobox.h>

class SystemOptions; //Forward declaration

// An exception class that takes a std::string detailing the error.
// The error type is also given by string
class GenericException : public std::runtime_error
{
    public:
        GenericException(std::string source, std::string str) :std::runtime_error("") {message = source+str;};
        virtual const char* what(void) const noexcept {return message.c_str();};
    private:
        std::string message;
};

class MessageCreatorException : public GenericException
{
    public:
        MessageCreatorException(std::string str) :GenericException("Message creator exception: ", str) {};
};

//A class which produces messages and should be polled for their transmit over UART
class MessageCreator
{

    public:
        virtual void processMessage(UartMessage msg) = 0; //Process a status message from FPGA
        bool messageWaiting(void) const {return (messageQueue.size() > 0);}; //Indicate if a message is waiting
        UartMessage getMessage(void); //Get a message from the message queue
        virtual ~MessageCreator() {};

    protected:
        std::queue<UartMessage> messageQueue;


};

enum class SystemStatus {disconnected, stopped, running};

class GuiSectionException : public GenericException
{
    public:
        GuiSectionException(std::string str) :GenericException("Gui Section exception: ", str) {};
};

//A base class for each of the GUI sections to inherit from
//Includes generic widget based functionality
class GuiSection
{
    public:
        virtual void setWidgetVisibility(SystemStatus status) =0; //Set visibility of widgets
        virtual void resetWidgetContents(void) =0; //Reset widgets to current values
        virtual void setDefaultValues(void) =0; //Send widgets to default values, and send as if the user had requested
    protected:
        GuiSection(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn) :systemOptions(systemOptionsIn), builder(builderIn) {};
        void setAllWidgetSensitivity(bool visible);

        //Overload function to accept all different widget types
        void addWidget(std::string gladeName, Gtk::Button *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};
        void addWidget(std::string gladeName, Gtk::SpinButton *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};
        void addWidget(std::string gladeName, Gtk::Entry *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};
        void addWidget(std::string gladeName, Gtk::ToggleButton *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};
        void addWidget(std::string gladeName, Gtk::TextView *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};
        void addWidget(std::string gladeName, Gtk::TreeView *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};
        void addWidget(std::string gladeName, Gtk::ComboBox *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};
        void addWidget(std::string gladeName, Gtk::Label *& widget) {addWidget(gladeName, (Gtk::Widget *&) widget);};

        //Convert from time to cycles and vice versa
        unsigned int timeToCycles(double time);
        double cyclesToTime(unsigned int cycles);

        const SystemOptions &systemOptions;
        unsigned long  entryToUl(Gtk::Entry *widget) const;
        double entryToDbl(Gtk::Entry *widget) const;
        std::vector<Gtk::Widget*> widgets;
    private:
        Glib::RefPtr<Gtk::Builder> builder;
        void addWidget(std::string gladeName, Gtk::Widget *& widget);


};

#endif
