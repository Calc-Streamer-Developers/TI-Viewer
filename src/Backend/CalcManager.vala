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

public class Viewer.Backend.CalcManager : Object {
    public signal void unsupported_device ();
    public signal void device_detected (string model_name);

    public signal void frame_captured (Gdk.Pixbuf frame);

    public signal void device_disconnected ();

    public CalcManager () {
        TiCables.init ();
        TiCalcs.init ();

        start_usb_discovery ();

        debug ("CalcManager intialised.");
    }

    private void start_usb_discovery () {
        new Thread<int> (null, () => {
            while (true) {
                int[] pids = {};

                debug ("Searching for devices...");

                while (true) {
                    TiCables.get_usb_devices (out pids);

                    if (pids.length > 0) {
                        break;
                    } else {
                        Thread.usleep (10000);
                    }
                }

                debug ("Device found: %04x", pids[0]);

                TiCables.CableModel cable_model = TiCables.CableModel.CABLE_NUL;
                TiFiles.CalcModel calc_model = TiFiles.CalcModel.CALC_NONE;

                if (pids[0] != TiCables.UsbPid.PID_NSPIRE) {
                    Idle.add (() => {
                        unsupported_device ();

                        return false;
                    });

                    Thread.usleep (1000000);

                    continue;
                }

                /* TODO: Support other models */
                cable_model = TiCables.CableModel.CABLE_USB;
                calc_model = TiFiles.CalcModel.CALC_NSPIRE;

                string model_name = TiFiles.calc_model_to_string (calc_model);

                Idle.add (() => {
                    device_detected (model_name);

                    return false;
                });

                TiCables.CableHandle cable_handle = new TiCables.CableHandle (cable_model, TiCables.CablePort.PORT_1);
                TiCalcs.CalcHandle calc_handle = new TiCalcs.CalcHandle (calc_model);

                if (cable_handle == null || calc_handle == null || calc_handle.attach_cable_handle (cable_handle) != 0) {
                    Idle.add (() => {
                        device_disconnected ();

                        return false;
                    });

                    continue;
                }

                while (calc_handle.is_ready () != 0) {
                    Thread.usleep (10000);
                }

                TiCalcs.CalcScreenCoord screen_coord;
                uint8[] bitmap;

                if (calc_handle.open_session (0x4024) != 0) {
                    warning ("Opening session failed.");
                }

                while (true) {
                    if (capture_screen (calc_handle, out screen_coord, out bitmap) != 0) {
                        debug ("Hand-held disconnected.");

                        Idle.add (() => {
                            device_disconnected ();

                            return false;
                        });

                        break;
                    }

                    uint8[] bytemap = bitmap_to_bytemap (bitmap, screen_coord.width, screen_coord.height);
                    Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_data (bytemap, Gdk.Colorspace.RGB, false, 8, (int)screen_coord.width, (int)screen_coord.height, 3 * (int)screen_coord.width);

                    Idle.add (() => {
                        frame_captured (pixbuf);

                        return false;
                    });
                }
            }
        });
    }

    private int capture_screen (TiCalcs.CalcHandle calc_handle, out TiCalcs.CalcScreenCoord screen_coord, out uint8[] bitmap) {        
        screen_coord = TiCalcs.CalcScreenCoord();
        bitmap = {};

        int ret = calc_handle.send_screen_rle (0);

        if (ret != 0)
            return ret;

        uint8 cmd;
        uint32 size = 0;
        uint8[] data;

        ret = calc_handle.receive_screen_rle (out cmd, out size, out data);

        if (ret != 0)
            return ret;

        screen_coord.width = screen_coord.clipped_width = (((uint16)data[8]) << 8) | data[9];
        screen_coord.height = screen_coord.clipped_height = (((uint16)data[10]) << 8) | data[11];

        size = ((((uint32)data[0]) << 24)
			  | (((uint32)data[1]) << 16)
			  | (((uint32)data[2]) <<  8)
			  | (((uint32)data[3])));

        ret = calc_handle.receive_screen_rle (out cmd, out size, out data);

        if (ret != 0)
            return ret;

        bitmap = uncompress (screen_coord, data, size);

        return 0;
    }

    private uint8[] uncompress (TiCalcs.CalcScreenCoord screen_coord, uint8[] src, uint32 size) {
        uint8[] dst = new uint8[screen_coord.width * screen_coord.height * 2];
        int target = 0;

        for(int i = 0; i < size;) {
            int8 rec = (int8)src[i++];

            if (rec >= 0) {
                uint8 cnt = ((uint8)rec) + 1;
                
                for (int j = 0; j < cnt; j++) {
                    dst[target++] = src[i + 0];
                    dst[target++] = src[i + 1];
                    dst[target++] = src[i + 2];
                    dst[target++] = src[i + 3];
                }

                i += 4;
            } else {
                uint8 cnt = ((uint8)(-rec)) + 1;
                
                for (int j = 0; j < cnt; j++) {
                    dst[target++] = src[i + 0];
                    dst[target++] = src[i + 1];
                    dst[target++] = src[i + 2];
                    dst[target++] = src[i + 3];

                    i += 4;
                }
            }
        }

        return dst;
    }

    private uint8[] bitmap_to_bytemap (uint8[] bitmap, uint width, uint height) {
        uint8[] bytemap = new uint8[3 * width * height];

        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                uint pos = width * y + x;
                uint16 color = ((uint16[])bitmap)[pos];

                bytemap[3 * pos + 0] = ((color & 0xF800) >> 11) << 3;
                bytemap[3 * pos + 1] = ((color & 0x07E0) >> 5) << 2;
                bytemap[3 * pos + 2] = ((color & 0x001F) >> 0) << 3;
            }
        }

        return bytemap;
    }
}
