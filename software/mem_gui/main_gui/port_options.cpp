//
// Created by josh on 10/07/17.
//

#include "port_options.hpp"


PortOptions::PortOptions(Glib::RefPtr<Gtk::Builder> builderIn, const SystemOptions &systemOptionsIn, FtdiWrapper &SerialIn, std::vector<MemoryManager *> &memArrIn)
        :GuiSection(builderIn, systemOptionsIn), serial(SerialIn), memArr(memArrIn)
{
    //Connect button
    addWidget("connect", connect);
    connect->signal_clicked().connect(sigc::mem_fun(*this, &PortOptions::onConnectClicked));

    //Baud entry
    addWidget("baud", baud);

    //Combo box
    addWidget("port", portComboBox);
    portComboBoxRefTreeModel = Gtk::ListStore::create(portColumnModel);
    portComboBox->set_model(portComboBoxRefTreeModel);
    updatePortComboBox();
    portComboBox->pack_start(portColumnModel.id);
    portComboBox->pack_start(portColumnModel.manufacturer);
    portComboBox->pack_start(portColumnModel.description);
}

void PortOptions::setWidgetVisibility(SystemStatus status)
{
    bool visible = false;
    switch(status)
    {
        case SystemStatus::disconnected :
            visible = true;
            break;
        case SystemStatus::stopped: case SystemStatus::running:
            visible = false;
            break;
    }
    setAllWidgetSensitivity(visible);
}

void PortOptions::updatePortComboBox(void)
{
    portComboBoxRefTreeModel->clear();
    std::list<FtdiWrapper::devType> list = serial.listDevs();
    for(auto it = list.begin(); it != list.end(); it++)
    {
        Gtk::TreeModel::Row row = *(portComboBoxRefTreeModel->append());
        row[portColumnModel.id] = it->id;
        row[portColumnModel.manufacturer] = it->manufacturer;
        row[portColumnModel.description] = it->description;
        //Make the first child active
        if(it == list.begin())
        {
            portComboBox->set_active(row);
        }
    }

}

void PortOptions::onConnectClicked()
{
    //Get ID from combo box
    unsigned int id;
    auto iter = portComboBox->get_active();
    if (iter)
    {
        auto row = *iter;
        if (row)
        {
            id = row[portColumnModel.id];
        } else
        {
            throw PortOptionsException("Port combo box active row pointee invalid");
        }
    } else
    {
        throw PortOptionsException("Port combo box active row pointer invalid");
    }

    //Get baud rate
    std::string baudText = baud->get_text();
    serial.open(id, stoi(baudText));
}


void PortOptions::resetWidgetContents(void)
{
    baud->set_text(std::to_string(serial.getBaud())); //Set true baud rate
}

