//Generic classes used by the project

#include <uart_msg.hpp>
#include <gtkmm/entry.h>
#include "generic_classes.hpp"
#include "../main_gui/system_options.hpp"

UartMessage MessageCreator::getMessage(void)
{
    if(messageQueue.size() == 0)
    {
        throw MessageCreatorException("Attempt to get message when queue is empty.");
    }
    UartMessage msg(messageQueue.front());
    messageQueue.pop();
    return msg;
}

//Iterate over all widgets and set them to the visibiltiy status indicated
void GuiSection::setAllWidgetSensitivity(bool visible)
{
    for(auto i = widgets.begin(); i != widgets.end(); i++)
    {
        (*i)->set_sensitive(visible);
    }
}

void GuiSection::addWidget(std::string gladeName, Gtk::Widget *& widget)
{
    builder->get_widget(gladeName, widget);

    if(widget == nullptr)
    {
        throw GuiSectionException("Attempted to add null widget");
    }

    widgets.push_back(widget);
}

unsigned long GuiSection::entryToUl(Gtk::Entry *widget) const
{
    std::string str = widget->get_text();
    return std::stoul(str);
}

double GuiSection::entryToDbl(Gtk::Entry *widget) const
{
    std::string str = widget->get_text();
    return std::stod(str);
}

unsigned int GuiSection::timeToCycles(double time)
{
    unsigned int cycles = (unsigned int) (time / systemOptions.getFgpaPeriod());

    return cycles;
}

double GuiSection::cyclesToTime(unsigned int cycles)
{
    double time = cycles * systemOptions.getFgpaPeriod();
    return time;
}
