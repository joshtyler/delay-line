//
// Created by josh on 10/07/17.
//

#ifndef LOG_OPTIONS_HPP
#define LOG_OPTIONS_HPP

#include <gtkmm/builder.h>
#include <gtkmm/textview.h>
#include <gtkmm/texttag.h>
#include <gtkmm/texttagtable.h>
#include <generic_classes.hpp>

class LogOptions : public GuiSection
{
    public:
        LogOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn);
        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void) {}; //Nothing to do!
        void updateLog(std::stringstream &toAdd);
        void setDefaultValues(void) {}; //Do nothing

    private:
        Gtk::TextView *log;
        Glib::RefPtr<Gtk::TextBuffer> logBuffer;
        //Log formatting
        Glib::RefPtr<Gtk::TextBuffer::Tag> logTagSend, logTagReceive, logTagError;

};


#endif
