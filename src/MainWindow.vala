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

public class Viewer.MainWindow : Gtk.Window {
    private Backend.CalcManager calc_manager;

    private Gtk.HeaderBar header_bar;

    private Gtk.Box main_box;

    private Gtk.InfoBar info_bar;
    private Gtk.Label info_label;

    private Gtk.Overlay viewport_overlay;
    private Gtk.Image viewport;

    private Gdk.Pixbuf? last_frame = null;

    private bool is_fullscreened = false;

    public MainWindow (Backend.CalcManager calc_manager, bool fullscreen) {
        this.calc_manager = calc_manager;

        build_ui ();
        connect_signals ();

        if (fullscreen)
            toggle_fullscreen ();
    }

    private void build_ui () {
        this.set_size_request (600, 500);
        this.set_default_size (800, 700);
        this.override_background_color (Gtk.StateFlags.NORMAL, { 0, 0, 0, 1 });
        this.events |= Gdk.EventMask.KEY_PRESS_MASK |
                       Gdk.EventMask.STRUCTURE_MASK;

        header_bar = new Gtk.HeaderBar ();
        header_bar.show_close_button = true;
        header_bar.title = "TI-Viewer";
        header_bar.subtitle = "Von Marcus W. und Sören B.";

        this.set_titlebar (header_bar);

        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        info_bar = new Gtk.InfoBar ();
        info_bar.message_type = Gtk.MessageType.INFO;

        info_label = new Gtk.Label ("Es wird nach Taschenrechnern gesucht…");
        info_label.ellipsize = Pango.EllipsizeMode.END;

        info_bar.get_content_area ().add (info_label);

        viewport_overlay = new Gtk.Overlay ();

        viewport = new Gtk.Image ();

        viewport_overlay.add_overlay (viewport);

        main_box.pack_start (info_bar, false, true);
        main_box.pack_end (viewport_overlay, true, true);

        this.add (main_box);
    }

    private void connect_signals () {
        this.key_press_event.connect ((event) => {
            if (event.keyval == Gdk.Key.F11) {
                toggle_fullscreen ();

                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });

        this.configure_event.connect ((event) => {
            update_viewport ();

            return Gdk.EVENT_PROPAGATE;
        });

        calc_manager.unsupported_device.connect (() => {
            show_info_bar (Gtk.MessageType.WARNING, "Der verbundene Taschenrechner wird nicht unterstützt. Vielleicht können die Entwickler dieses Programmes da weiterhelfen.");
        });

        calc_manager.device_detected.connect ((model_name) => {
            show_info_bar (Gtk.MessageType.INFO, "Taschenrechner des Typs \"%s\" erkannt. Gerät bitte nicht trennen, während eine Verbindung hergestellt wird…".printf (model_name));
        });

        calc_manager.frame_captured.connect ((frame) => {
            info_bar.hide ();

            display_frame (last_frame = frame);
        });

        calc_manager.device_disconnected.connect (() => {
            show_info_bar (Gtk.MessageType.INFO, "Verbindung beendet. Bitte verbinde einen Taschenrechner mit diesem Computer um dessen Bildschirm hier darzustellen!");
        });
    }

    private void toggle_fullscreen () {
        if (is_fullscreened) {
            base.unfullscreen ();
        } else {
            base.fullscreen ();
        }

        is_fullscreened = !is_fullscreened;

        update_viewport ();
    }

    private void show_info_bar (Gtk.MessageType message_type, string message) {
        info_bar.set_message_type (message_type);
        info_label.set_text (message);

        info_bar.show ();

        Timeout.add (500, () => {
            update_viewport ();

            return false;
        });
    }

    private void update_viewport () {
        if (last_frame != null) {
            display_frame (last_frame);
        }
    }

    private void display_frame (Gdk.Pixbuf frame) {
        int new_width, new_height;

        resize_dimensions (frame.width,
                           frame.height,
                           viewport_overlay.get_allocated_width (),
                           viewport_overlay.get_allocated_height (),
                           out new_width,
                           out new_height);

        Gdk.Pixbuf scaled_frame = frame.scale_simple (new_width, new_height, Gdk.InterpType.NEAREST);

        viewport.set_from_pixbuf (scaled_frame);
    }

    private void resize_dimensions (int frame_width,
                                    int frame_height,
                                    int target_width,
                                    int target_height,
                                    out int new_width,
                                    out int new_height) {
        new_width = target_width;
        new_height = (int)(((float)target_width / frame_width) * frame_height);

        if (new_height > target_height) {
            new_width = (int)(((float)target_height / frame_height) * frame_width);
            new_height = target_height;
        }
    }
}
