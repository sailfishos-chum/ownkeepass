/***************************************************************************
**
** Copyright (C) 2013 Marko Koschak (marko.koschak@tisno.de)
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
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.ownkeepass 1.0
import "../common"
import "../scripts/Global.js" as Global

Page {
    id: showEntryDetailsPage

    // ID of the keepass entry to be shown
    property string entryId: ""

    function copyToClipboard(text, label) {
        Clipboard.text = text
        // trigger cleaning of clipboard after specific time
        applicationWindow.mainPageRef.clipboardTimerStart()
        // applicationWindow.infoPopup.show(Global.info, "", label + " " + qsTr("copied into clipboard"), 2)
    }

    allowedOrientations: applicationWindow.orientationSetting

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        ViewPlaceholder {
            enabled: !entryUrlTextArea.enabled && !entryUsernameTextArea.enabled &&
                     !entryPasswordTextField.enabled && !entryCommentTextArea.enabled &&
                     kdbEntry.isEmpty
            verticalOffset: wallImage.height / 2

            text: qsTr("No content")
            hintText: !ownKeepassDatabase.readOnly ?
                      qsTr("Pull down to add URL, username, password, comment and additional attributes")
                      : ""

            Image {
                id: wallImage
                anchors.bottom: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../wallicons/wall-key.png"
                width: height
                height: implicitHeight * Screen.height / 1920
            }
        }

        PullDownMenu {
            MenuItem {
                enabled: false
                visible: ownKeepassDatabase.readOnly
                text: qsTr("Read only mode")
            }

            MenuItem {
                enabled: !ownKeepassDatabase.readOnly
                visible: !ownKeepassDatabase.readOnly
                text: qsTr("Edit password entry")
                onClicked: {
                    kdbEntry.entryId = entryId
                    kdbEntry.loadEntryData()
                    pageStack.push(editEntryDetailsDialogComponent)
                }
            }

            SilicaMenuLabel {
                text: Global.activeDatabase
                elide: Text.ElideMiddle
            }
        }

        ApplicationMenu {}

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: pageHeader
                title: kdbEntry.title
                description: "ownKeepass"
            }

            EntryTextArea {
                id: entryUrlTextArea
                text: kdbEntry.url
                label: qsTr("URL")
                menuLabel: qsTr("Copy to clipboard")
                onItemClicked: {
                    // Check if url contains http, if not add it so that URL opens in browser
                    if (text.toLowerCase().match(/^http/g) === null) {
                        Qt.openUrlExternally("http://" + text)
                    } else {
                        Qt.openUrlExternally(text)
                    }
                }
                onMenuClicked: copyToClipboard(text, label)
            }

            EntryTextArea {
                id: entryUsernameTextArea
                text: kdbEntry.userName
                label: qsTr("Username")
                menuLabel: qsTr("Copy to clipboard")
                onMenuClicked: copyToClipboard(text, label)
            }

            EntryTextArea {
                id: entryPasswordTextField
                text: kdbEntry.password
                label: qsTr("Password")
                menuLabel: qsTr("Copy to clipboard")
                onMenuClicked: copyToClipboard(text, label)
                passwordMode: true
            }

            // TOTP section
            Item {
                width: parent.width
                height: totpEntryArea.height
                visible: kdbEntry.hasTotp
                enabled: kdbEntry.hasTotp

                EntryTextArea {
                    id: totpEntryArea
                    width: parent.width
                    text: kdbEntry.totpCode
                    label: qsTr("TOTP")
                    menuLabel: qsTr("Copy to clipboard")
                    onMenuClicked: copyToClipboard(text, label)
                }

                // Circular countdown indicator
                ProgressCircle {
                    id: totpCountdown
                    anchors.top: totpEntryArea.top
                    anchors.topMargin: Theme.paddingSmall
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    width: Theme.iconSizeMedium
                    height: width
                    value: kdbEntry.totpPeriod > 0 ?
                        kdbEntry.totpTimeRemaining / kdbEntry.totpPeriod : 0
                    progressColor: value < 0.2 ? Theme.errorColor : Theme.highlightColor
                    backgroundColor: Theme.rgba(Theme.primaryColor, 0.2)

                    Label {
                        anchors.centerIn: parent
                        text: kdbEntry.totpTimeRemaining
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.primaryColor
                    }
                }
            }

            EntryTextArea {
                id: entryCommentTextArea
                text: kdbEntry.notes
                label: qsTr("Comment")
                menuLabel: qsTr("Copy to clipboard")
                onMenuClicked: copyToClipboard(text, label)
            }

            SilicaListView {
                id: additionalAttributesListView
                width: parent.width
                model: kdbEntry

                delegate: Item {
                    width: Screen.width
                    height: additionalAttributesTextArea.height + Theme.paddingLarge

                    EntryTextArea {
                        id: additionalAttributesTextArea
                        anchors.top: parent.top
                        text: model.value
                        label: model.key
                        menuLabel: qsTr("Copy to clipboard")
                        onMenuClicked: copyToClipboard(text, label)
                                      //: Translate "password" with all low letters. It is used in pattern matching to deside to hide additional attributes of Keepass 2 database.
                        passwordMode: String(label.toLowerCase()).indexOf(qsTr("password")) !== -1 ||
                                      //: "pin" like a pin number of your credit card or sim card. Translate "pin" with all low letters. It is used in pattern matching to deside to hide additional attributes of Keepass 2 database.
                                      String(label.toLowerCase()).indexOf(qsTr("pin")) !== -1 ||
                                      //: "tan" like a tan list from your bank account. Translate "tan" with all low letters. It is used in pattern matching to deside to hide additional attributes of Keepass 2 database.
                                      String(label.toLowerCase()).indexOf(qsTr("tan")) !== -1 ||
                                      //: "puk" like the (emergency) puk number of your sim card. Translate "puk" with all low letters. It is used in pattern matching to deside to hide additional attributes of Keepass 2 database.
                                      String(label.toLowerCase()).indexOf(qsTr("puk")) !== -1
                    }

                    Item {
                        height: Theme.paddingLarge
                        width: parent.width
                        anchors.top: additionalAttributesTextArea.bottom
                    }
                }

                Connections {
                    // for breaking the binding loop on height
                    onContentHeightChanged: additionalAttributesListView.height = additionalAttributesListView.contentHeight
                }
            }

            Item {
                height: Theme.itemSizeSmall
                width: parent.width
            }
        }
    }

    Component.onCompleted: {
        // set entry ID and load entry details to show in this page
        kdbEntry.entryId = entryId
        kdbEntry.loadEntryData()
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // set entry ID and load entry details to show in this page
            kdbEntry.entryId = entryId
            kdbEntry.loadEntryData()
            // set cover state and info
            applicationWindow.cover.state = "ENTRY_VIEW"
            applicationWindow.cover.title = pageHeader.title
            applicationWindow.cover.username = kdbEntry.userName
            applicationWindow.cover.password = kdbEntry.password
        }
    }
}
