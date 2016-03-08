/*
 * Copyright (c) 2016 TI-Viewer Developers
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Marcus Wichelmann <marcus.wichelmann@hotmail.de>
 */

public class Viewer.Backend.ServiceProvider : Object {
    private static const string SERVICE_TYPE = "_tiviewer._tcp";

    public Avahi.Client client;

    private uint16 port;

    private Avahi.EntryGroup entry_group;
    private Avahi.EntryGroupService? service = null;

    public ServiceProvider (uint16 port) {
        this.port = port;

        client = new Avahi.Client ();
        entry_group = new Avahi.EntryGroup ();

        connect_signals ();
        start_client ();
    }

    private void connect_signals () {
        client.state_changed.connect ((state) => {
            switch (state) {
                case Avahi.ClientState.S_RUNNING :
                    try {
                        entry_group.attach (client);
                    } catch (Error e) {
                        warning ("Configuring Avahi service failed: %s", e.message);
                    }

                    break;
            }
        });

        entry_group.state_changed.connect ((state) => {
            switch (state) {
                case Avahi.EntryGroupState.UNCOMMITED:
                    try {
                        service = entry_group.add_service (Environment.get_host_name (), SERVICE_TYPE, port);

                        entry_group.commit ();
                    } catch (Error e) {
                        critical ("Registering service failed: %s", e.message);
                    }

                    break;
                case Avahi.EntryGroupState.ESTABLISHED:
                    debug ("Avahi-Service registered.");

                    break;
            }
        });
    }

    private void start_client () {
        try {
            client.start ();
        } catch (Error e) {
            warning ("Connecting to Avahi failed: %s", e.message);
        }
    }
}