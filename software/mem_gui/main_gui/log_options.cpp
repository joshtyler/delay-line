//
// Created by josh on 10/07/17.
//

#include "log_options.hpp"

LogOptions::LogOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn)
        :GuiSection(builderIn, systemOptionsIn)
{
    //Setup log
    addWidget("log", log);
    logBuffer = Gtk::TextBuffer::create();
    log->set_buffer(logBuffer);

    //Setup log formatting
    logTagSend = logBuffer->create_tag("send");
    logTagSend->property_foreground() = "green";
    //Receive tag
    logTagReceive = logBuffer->create_tag("receive");
    logTagReceive->property_foreground() = "blue";
    //Error tag
    logTagError = logBuffer->create_tag("error");
    logTagError->property_foreground() = "red";
}

void LogOptions::updateLog(std::stringstream &toAdd)
{
        std::istringstream temp(toAdd.str()); //getline only appears to work on an istringstream
        toAdd.str(std::string()); //Clear input stringstream

        //Run while we can get a non-zero length line from the string
        for (std::string line; std::getline(temp, line);)
        {
            line +='\n'; //Dont discard newline character
            //Get an iterator at the end of the log
            auto end = logBuffer->get_iter_at_line(logBuffer->get_line_count());

            //Check if the line contains a certain keyword
            //If so add with appropriate formatting
            //If not add as plain text
            if (line.find("Error") <= line.length())
            {
                logBuffer->insert_with_tag(end, line, logTagError);
            } else if (line.find("Sent") <= line.length())
            {
                logBuffer->insert_with_tag(end, line, logTagSend);
            } else if (line.find("Received") <= line.length())
            {
                logBuffer->insert_with_tag(end, line, logTagReceive);
            } else
            {
                logBuffer->insert(end, line);
            }
            // Scroll to end of Buffer
            end = logBuffer->get_iter_at_line(logBuffer->get_line_count());
            log->scroll_to(end);
        }

}

void LogOptions::setWidgetVisibility(SystemStatus status)
{
    bool visible = true;

    setAllWidgetSensitivity(visible);
}
