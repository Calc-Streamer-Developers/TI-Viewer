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

/* Use GLib.Application to make it running on headless systems */
public class Viewer.Application : GLib.Application {
    private static const uint16 SERVER_PORT = 3790;
    private static const OptionEntry[] OPTIONS = {
        { "server", 's', 0, OptionArg.NONE, null, "Start as server without loading the user interface", null },
        { null }
    };

    private Backend.Server server;
    private Backend.ServiceProvider service_provider;

    private MainWindow? main_window = null;

    construct {
        flags |= ApplicationFlags.HANDLES_COMMAND_LINE;

        add_main_option_entries (OPTIONS);
    }

    protected override int command_line (ApplicationCommandLine command_line) {
        if (main_window != null) {
            main_window.present ();

            return 1;
        }

        if (!Thread.supported ()) {
            critical ("Threading is not supported by this system.");

            return 1;
        }

        VariantDict options = command_line.get_options_dict ();

        if (options.contains ("server")) {
            start_server ();
        } else {
            show_main_window ();
        }

        return 0;
    }

    private void start_server () {
        server = new Backend.Server (SERVER_PORT);
        service_provider = new Backend.ServiceProvider (SERVER_PORT);

        /* Keep the application running */
        this.hold ();
    }

    private void show_main_window () {
        if (main_window == null) {
            main_window = new MainWindow ();
            main_window.destroy.connect (Gtk.main_quit);
            main_window.show_all ();

            Gtk.main ();
        } else {
            main_window.present ();
        }
    }

    public static void main (string[] args) {
        Gtk.init (ref args);

        var application = new Viewer.Application ();
        application.run (args);
    }
}