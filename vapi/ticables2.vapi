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

[CCode (cheader_filename = "ticables.h")]
namespace TiCables {
    [CCode (cname = "CableHandle", free_function = "ticables_handle_del")]
    [Compact]
    public class CableHandle {
        [CCode (cname = "ticables_handle_new")]
        public CableHandle (CableModel cable_model, CablePort cable_port);
    }

    [CCode (cname = "UsbPid")]
    public enum UsbPid {
        [CCode (cname = "PID_UNKNOWN")]
        PID_UNKNOWN = 0,

        [CCode (cname = "PID_TIGLUSB")]
        PID_TIGLUSB = 0xE001,

        [CCode (cname = "PID_TI89TM")]
        PID_TI89TM = 0xE004,

        [CCode (cname = "PID_TI84P")]
        PID_TI84P = 0xE003,

        [CCode (cname = "PID_TI84P_SE")]
        PID_TI84P_SE = 0xE008,

        [CCode (cname = "PID_NSPIRE")]
        PID_NSPIRE = 0xE012
    }

    [CCode (cname = "CableModel")]
    public enum CableModel {
        [CCode (cname = "CABLE_NUL")]
        CABLE_NUL = 0,

        [CCode (cname = "CABLE_GRY")]
        CABLE_GRY,

        [CCode (cname = "CABLE_BLK")]
        CABLE_BLK,

        [CCode (cname = "CABLE_PAR")]
        CABLE_PAR,

        [CCode (cname = "CABLE_SLV")]
        CABLE_SLV,

        [CCode (cname = "CABLE_USB")]
        CABLE_USB,

        [CCode (cname = "CABLE_VTI")]
        CABLE_VTI,

        [CCode (cname = "CABLE_TIE")]
        CABLE_TIE,

        [CCode (cname = "CABLE_ILP")]
        CABLE_ILP,

        [CCode (cname = "CABLE_DEV")]
        CABLE_DEV,

        [CCode (cname = "CABLE_MAX")]
        CABLE_MAX
    }

    [CCode (cname = "CablePort")]
    public enum CablePort {
        [CCode (cname = "PORT_0")]
        PORT_0 = 0,

        [CCode (cname = "PORT_1")]
        PORT_1,

        [CCode (cname = "PORT_2")]
        PORT_2,

        [CCode (cname = "PORT_3")]
        PORT_3,

        [CCode (cname = "PORT_4")]
        PORT_4
    }

    [CCode (cname = "ticables_library_init")]
    public int init ();

    [CCode (cname = "ticables_get_usb_devices")]
    public int get_usb_devices (out int[] pids);
}