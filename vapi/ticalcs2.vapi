/*
 * Copyright (c) 2016 Marcus Wichelmann (marcus.wichelmann@hotmail.de)
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
 */

[CCode (cheader_filename = "ticalcs.h")]
namespace TiCalcs {
    [CCode (cname = "CalcHandle", free_function = "ticalcs_handle_del")]
    [Compact]
    public class CalcHandle {
        [CCode (cname = "ticalcs_handle_new")]
        public CalcHandle (TiFiles.CalcModel calc_model);

        [CCode (cname = "ticalcs_cable_attach")]
        public int attach_cable_handle (TiCables.CableHandle cable_handle);

        [CCode (cname = "ticalcs_calc_isready")]
        public int is_ready ();

        [CCode (cname = "ticalcs_calc_recv_screen")]
        public int receive_screen (out CalcScreenCoord screen_coord, [CCode (array_length = false)] out uint8[] bitmap);
    }

    [CCode (cname = "CalcScreenCoord")]
    public struct CalcScreenCoord {
        int format;

        uint width;
        uint height;

        uint clipped_width;
        uint clipped_height;
    }

    [CCode (cname = "ticalcs_library_init")]
    public int init ();
}