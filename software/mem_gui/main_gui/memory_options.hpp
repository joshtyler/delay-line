//
// Created by josh on 10/07/17.
//

#ifndef MEMORY_OPTIONS_HPP
#define MEMORY_OPTIONS_HPP


#include <generic_classes.hpp>
#include <gtkmm/spinbutton.h>
#include <gtkmm/button.h>
#include <gtkmm/treeview.h>
#include <gtkmm/liststore.h>
#include "../status_manager/status_manager.hpp"
#include "../memory_manager/memory_manager.hpp"
#include "system_options.hpp"

class MemoryOptions : public GuiSection
{
    public:
        MemoryOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn,
                              StatusManager &statusManagerIn, std::vector<MemoryManager *> &memArrIn);
        void setWidgetVisibility(SystemStatus status);
        void resetWidgetContents(void) {}; //Nothing to do!
        void updateMemViewer(void);
        void createMemViewer(void);
        void setDefaultValues(void) {}; //Do nothing - this is because setDefaultValues is intended for reset type behaviour, which doesn't apply to us

    private:
        StatusManager &statusManager;
        std::vector<MemoryManager*> &memArr;


        Gtk::SpinButton *addr;
        Gtk::Entry *value;
        Gtk::Button *memRequestSend, *fillZeros, *fillOnes, *fillRand;
        void onMemRequestSend(void);

        //Memory viewer
        class MemViewerModel : public Gtk::TreeModel::ColumnRecord
        {
            public:

                MemViewerModel()
                { add(addr); add(val);};

                Gtk::TreeModelColumn<unsigned int> addr;
                Gtk::TreeModelColumn<unsigned int> val;
        };
        MemViewerModel memViewerModel;
        Gtk::TreeView* memViewer;
        Glib::RefPtr<Gtk::ListStore> memViewerTreeModel;

        enum class FillTypes
        {
                zeros,
                ones,
                random
        };

        void fillMem(FillTypes f);
};


#endif //MEM_GUI_MEMORY_OPTIONS_HPP
