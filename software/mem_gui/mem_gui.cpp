// Program to handle talking to test harne

#include <iostream>
#include <memory>
#include <gtkmm.h>
#include "uart_manager.hpp"
#include "status_manager/status_manager.hpp"
#include "memory_manager/memory_manager.hpp"
#include "main_gui/main_gui.hpp"


int main(int argc, char **argv)
{


	try{

        //Setup GUI
        auto app = Gtk::Main(argc, argv);

        auto refBuilder = Gtk::Builder::create();
        try
        {
            refBuilder->add_from_file("../mem_gui.glade");
        }
        catch(const Glib::FileError& ex)
        {
            std::cerr << "FileError: " << ex.what() << std::endl;
            return 1;
        }
        catch(const Glib::MarkupError& ex)
        {
            std::cerr << "MarkupError: " << ex.what() << std::endl;
            return 1;
        }
        catch(const Gtk::BuilderError& ex)
        {
            std::cerr << "BuilderError: " << ex.what() << std::endl;
            return 1;
        }

        MainGui *gui = nullptr;
        refBuilder->get_widget_derived("mem_gui", gui);

        app.run(*gui);

        delete gui;


	} catch (const std::exception& exc) {
        std::cerr << exc.what() << std::endl;
	}



	return 0;
}
