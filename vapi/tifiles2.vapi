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

[CCode (cheader_filename = "tifiles.h")]
namespace TiFiles {
    [CCode (cname = "CalcModel")]
    public enum CalcModel {
        [CCode (cname = "CALC_NONE")]
        CALC_NONE = 0,

        [CCode (cname = "CALC_TI73")]
        CALC_TI73,

        [CCode (cname = "CALC_TI82")]
        CALC_TI82,

        [CCode (cname = "CALC_TI83")]
        CALC_TI83,

        [CCode (cname = "CALC_TI83P")]
        CALC_TI83P,

        [CCode (cname = "CALC_TI84P")]
        CALC_TI84P,

        [CCode (cname = "CALC_TI85")]
        CALC_TI85,

        [CCode (cname = "CALC_TI86")]
        CALC_TI86,

        [CCode (cname = "CALC_TI89")]
        CALC_TI89,

        [CCode (cname = "CALC_TI89T")]
        CALC_TI89T,

        [CCode (cname = "CALC_TI92")]
        CALC_TI92,

        [CCode (cname = "CALC_TI92P")]
        CALC_TI92P,

        [CCode (cname = "CALC_V200")]
        CALC_V200,

        [CCode (cname = "CALC_TI84P_USB")]
        CALC_TI84P_USB,

        [CCode (cname = "CALC_TI89T_USB")]
        CALC_TI89T_USB,

        [CCode (cname = "CALC_NSPIRE")]
        CALC_NSPIRE,

        [CCode (cname = "CALC_TI80")]
        CALC_TI80,

        [CCode (cname = "CALC_MAX")]
        CALC_MAX;
    }

    [CCode (cname = "tifiles_model_to_string")]
    public static unowned string calc_model_to_string (CalcModel calc_model);
}