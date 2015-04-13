/***************************************************************************
**
** Copyright (C) 2012 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of ownKeepass.
**
** ownKeepass is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** ownKeepass is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass.  If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#include "DatabaseClient.h"
#include "Keepass1DatabaseFactory.h"
//#include "Keepass2DatabaseFactory.h"

using namespace kpxPrivate;

#define KEEPASS_1 1
#define KEEPASS_2 2

// Global static pointer used to ensure a single instance of the class
// It is used by KdbDatabase, KdbListModel, KdbGroup and KdbEntry classes to access data of the Keepass database
DatabaseClient* DatabaseClient::m_Instance = new DatabaseClient;

DatabaseClient::DatabaseClient(QObject *parent)
    : QObject(parent),
      m_factory(NULL),
      m_interface(NULL),
      m_workerThread()
{
    // Currently support for Keepass 1 is hardcoded
    initDatabaseInterface(KEEPASS_1);
}

int DatabaseClient::initDatabaseInterface(const int type)
{
    if (m_workerThread.isRunning()) {
        m_workerThread.quit();
        m_workerThread.wait();
        m_workerThread.terminate();
    }

    // Here a interface will be instantiated which operates on a specific Keepass database version
    // To enable other database formats just load here another interface

    switch(type) {
    case KEEPASS_1:
        m_factory = new Keepass1DatabaseFactory();
        m_interface = m_factory->factoryMethod();
        break;
    case KEEPASS_2:
//        m_factory = new Keepass2DatabaseFactory();
//        m_interface = m_factory->factoryMethod();
        break;
    default:
// TODO add error handling
        m_factory = NULL;
        m_interface = NULL;
        break;
    }

    // DatabaseInterface object m_worker is also a QObject, so in order to use functions from it cast it before
    dynamic_cast<QObject*>(m_interface)->moveToThread(&m_workerThread);
    m_workerThread.start();

    return 0;
}

DatabaseClient::~DatabaseClient()
{
    if (m_workerThread.isRunning()) {
        m_workerThread.quit();
        m_workerThread.wait();
        m_workerThread.terminate();
    }
    delete m_interface;
    m_interface = NULL;
    delete m_factory;
    m_factory = NULL;
}

DatabaseClient* DatabaseClient::getInstance()
{
    Q_ASSERT(m_Instance);
    return m_Instance;
}
