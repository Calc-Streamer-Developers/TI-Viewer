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

public class Viewer.Backend.Server : ThreadedSocketService {
    /* Limit package size to 2^14 bytes for compatibility reasons */
    private static const uint16 MAX_PACKAGE_LENGTH = 16384;

    private CalcManager calc_manager;

    private List<SocketConnection> connections;

    public Server (uint16 port) {
        calc_manager = new CalcManager ();

        connections = new List<SocketConnection> ();

        try {
            this.add_inet_port (port, new Object ());
        } catch (Error e) {
            error ("Binding to port %u failed.", port);
        }

        this.run.connect (handle_connection);
        this.start ();

        connect_signals ();
    }

    private bool handle_connection (SocketConnection connection, Object source_object) {
        debug ("Incoming server connection.");

        connections.append (connection);

        return true;
    }

    private void connect_signals () {
        calc_manager.unsupported_device.connect (broadcast_unsupported_device);
        calc_manager.device_detected.connect (broadcast_device_detected);
        calc_manager.frame_captured.connect (broadcast_frame_captured);
        calc_manager.device_disconnected.connect (broadcast_device_disconnected);
    }

    private void broadcast_unsupported_device () {
        broadcast_package ({ 1 });
    }

    private void broadcast_device_detected (string model_name) {
        uint8[] package = {};
        package += 2;

        for (int i = 0; i < model_name.data.length; i++) {
            package += model_name.data[i];
        }

        broadcast_package (package);
    }

    private void broadcast_frame_captured (Gdk.Pixbuf frame) {
        uint8[] frame_data;

        try {
            if (!frame.save_to_buffer (out frame_data, "png")) {
                warning ("Encoding frame failed.");

                return;
            }
        } catch (Error e) {
            warning ("Encoding frame failed: %s", e.message);

            return;
        }

        uint32 data_size = frame_data.length;

        broadcast_package ({
            3,
            (uint8)(data_size >> 24) & 0xff,
            (uint8)(data_size >> 16) & 0xff,
            (uint8)(data_size >> 8) & 0xff,
            (uint8)data_size & 0xff
        });

        uint32 bytes_sent = 0;

        while (bytes_sent < data_size) {
            uint32 next_size = (data_size - bytes_sent);

            if (next_size > MAX_PACKAGE_LENGTH) {
                next_size = MAX_PACKAGE_LENGTH;
            }

            broadcast_package (frame_data[bytes_sent: bytes_sent + next_size]);

            bytes_sent += next_size;
        }
    }

    private void broadcast_device_disconnected () {
        broadcast_package ({ 4 });
    }

    private void broadcast_package (uint8[] package) {
        if (connections.length () == 0) {
            return;
        }

        uint16 package_length = (uint16)(package.length);

        foreach (SocketConnection connection in connections) {
            if (!connection.is_connected ()) {
                connections.remove (connection);

                continue;
            }

            try {
                connection.output_stream.write_all ({ (uint8)((package_length >> 8) & 0xff), (uint8)(package_length & 0xff) }, null);
                connection.output_stream.write_all (package, null);
            } catch (Error e) {
                warning ("Error while sending package: %s", e.message);

                connections.remove (connection);
            }
        }
    }
}