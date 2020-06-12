--============================================================================--
-- Design unit  : AMBA (Package declaration)
--
-- File name    : amba.vhd
--
-- Purpose      : This package declares types to be used with the
--                Advanced Microcontroller Bus Architecture (AMBA).
--
-- Reference    : AMBA(TM) Specification (Rev 2.0), ARM IHI 0011A,
--                13th May 1999, issue A, first release, ARM Limited
--
--                The document can be retrieved from http://www.arm.com
--
--                AMBA is a trademark of ARM Limited.
--                ARM is a registered trademark of ARM Limited.
--
-- Note         : Naming convention according to AMBA(TM) Specification:
--                Signal names are in upper case, except for the following:
--                A lower case n in the name indicates that the signal is
--                active low. A lower case x in the name suffix indicates that
--                the signal is unique to a module. Constant names are in upper
--                case.
--
--                The least significant bit of an array is located to the right,
--                carrying the index number zero.
--
-- Library      : AMBA_Lib {recommended}
--
-- Author       : European Space Agency (ESA)
--                P.O. Box 299
--                NL-2200 AG Noordwijk ZH
--                The Netherlands
--
-- Contact      : mailto:microelectronics@estec.esa.nl
--                http://www.estec.esa.nl/microelectronics
--
-- Copyright (C): European Space Agency (ESA) 2000. This source code may be
--                redistributed provided that the source code and this notice
--                remain intact. This source code may not under any
--                circumstances be resold or redistributed for compensation
--                of any kind without prior written permission.
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit. This information does not
--                necessarily reflect the policy of the European Space Agency.
--------------------------------------------------------------------------------
-- Version  Author   Date           Changes
--
-- 0.2      ESA       5 Jul 2000    Package created
-- 0.3      ESA      10 Jul 2000    Additional HREADY slave input,
--                                  Std_ULogic usage for non-array signals,
--                                  Additional comments on casing and addressing
-- 0.4      ESA      14 Jul 2000    HRESETn removed from AHB Slave input record
--                                  Additional comments on clocking and reset
--                                  Additional comments on AHB endianness
--                                  Additional comments on APB addressing
-- 0.5      ESA      18 Jul 2000    Re-defined vector types for AHB arbiter
--                                  and APB master
--------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;

package AMBA is
   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) Advanced High-performance Bus (AHB)
   -----------------------------------------------------------------------------
   -- Records are defined for the input and output of an AHB Master, as well as
   -- for an AHB Slave. These records are grouped in arrays, for scalability,
   -- and new records using these arrays are defined for the input and output of
   -- an AHB Arbiter/Decoder.
   --
   -- The routing of the clock and reset signals defined in the AMBA(TM)
   -- Specification is not covered in this package, since being dependent on 
   -- the clock and reset conventions defined at system level.
   --
   -- The HCLK and HRESETn signals are routed separately:
   --    HCLK:       Std_ULogic;                         -- rising edge
   --    HRESETn:    Std_ULogic;                         -- active low reset
   --
   -- The address bus HADDR contains byte addresses. The relation between the 
   -- byte address and the n-byte data bus HDATA can either be little-endian or 
   -- big-endian according to the AMBA(TM) Specification.
   -- 
   -- It is recommended that only big-endian modules are implemented using
   -- this package.
   --
   -----------------------------------------------------------------------------
   -- Constant definitions for AMBA(TM) AHB
   -----------------------------------------------------------------------------
   constant HDMAX:   Positive range 32 to 1024 := 32;    -- data width
   constant HAMAX:   Positive range 32 to 32   := 32;    -- address width
--   constant HMMAX:   Positive range 1 to 16    := 16;    -- number of masters
--   constant HSMAX:   Positive                  := 16;    -- number of slaves

   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) AHB Masters
   -----------------------------------------------------------------------------
   -- AHB master inputs (HCLK and HRESETn routed separately)
   type AHB_Mst_In_Type is
      record
         HGRANT:     Std_ULogic;                         -- bus grant
         HREADY:     Std_ULogic;                         -- transfer done
         HRESP:      Std_Logic_Vector(1       downto 0); -- response type
         HRDATA:     Std_Logic_Vector(HDMAX-1 downto 0); -- read data bus
         HCACHE:     Std_ULogic;                         -- cacheable data
      end record;

   -- AHB master outputs
   type AHB_Mst_Out_Type is
      record
         HBUSREQ:    Std_ULogic;                         -- bus request
         HLOCK:      Std_ULogic;                         -- lock request
         HTRANS:     Std_Logic_Vector(1       downto 0); -- transfer type
         HADDR:      Std_Logic_Vector(HAMAX-1 downto 0); -- address bus (byte)
         HWRITE:     Std_ULogic;                         -- read/write
         HSIZE:      Std_Logic_Vector(2       downto 0); -- transfer size
         HBURST:     Std_Logic_Vector(2       downto 0); -- burst type
         HPROT:      Std_Logic_Vector(3       downto 0); -- protection control
         HWDATA:     Std_Logic_Vector(HDMAX-1 downto 0); -- write data bus
      end record;

   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) AHB Slaves
   -----------------------------------------------------------------------------
   -- AHB slave inputs (HCLK and HRESETn routed separately)
   type AHB_Slv_In_Type is
      record
         HSEL:       Std_ULogic;                         -- slave select
         HADDR:      Std_Logic_Vector(HAMAX-1 downto 0); -- address bus (byte)
         HWRITE:     Std_ULogic;                         -- read/write
         HTRANS:     Std_Logic_Vector(1       downto 0); -- transfer type
         HSIZE:      Std_Logic_Vector(2       downto 0); -- transfer size
         HBURST:     Std_Logic_Vector(2       downto 0); -- burst type
         HWDATA:     Std_Logic_Vector(HDMAX-1 downto 0); -- write data bus
         HPROT:      Std_Logic_Vector(3       downto 0); -- protection control
         HREADY:     Std_ULogic;                         -- transfer done
         HMASTER:    Std_Logic_Vector(3       downto 0); -- current master
         HMASTLOCK:  Std_ULogic;                         -- locked access
      end record;

   -- AHB slave outputs
   type AHB_Slv_Out_Type is
      record
         HREADY:     Std_ULogic;                         -- transfer done
         HRESP:      Std_Logic_Vector(1       downto 0); -- response type
         HRDATA:     Std_Logic_Vector(HDMAX-1 downto 0); -- read data bus
         HSPLIT:     Std_Logic_Vector(15      downto 0); -- split completion
      end record;

   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) AHB Arbiter/Decoder
   -----------------------------------------------------------------------------
   -- supporting array types
   type AHB_Mst_In_Vector  is array (Natural Range <> ) of AHB_Mst_In_Type;
   type AHB_Mst_Out_Vector is array (Natural Range <> ) of AHB_Mst_Out_Type;
   type AHB_Slv_In_Vector  is array (Natural Range <> ) of AHB_Slv_In_Type;
   type AHB_Slv_Out_Vector is array (Natural Range <> ) of AHB_Slv_Out_Type;

   -- An AHB arbiter could be defined as follows:

   --  entity AHBarbiter is
   --  generic (
   --    masters : integer := 2;		-- number of masters
   --    slaves  : integer := 2;		-- number of slaves
   --  );
   --  port (
   --    clk     : in  std_ulogic;
   --    rst     : in  std_ulogic;
   --    msti    : out ahb_mst_in_vector(0 to masters-1);
   --    msto    : in  ahb_mst_out_vector(0 to masters-1);
   --    slvi    : out ahb_slv_in_vector(0 to slaves-1);
   --    slvo    : in  ahb_slv_out_vector(0 to slaves-1)
   --  );
   --  end;


   -----------------------------------------------------------------------------
   -- Auxiliary constant definitions for AMBA(TM) AHB
   -----------------------------------------------------------------------------
   -- constants for HTRANS (transition type, slave output)
   constant HTRANS_IDLE:   Std_Logic_Vector(1 downto 0) := "00";
   constant HTRANS_BUSY:   Std_Logic_Vector(1 downto 0) := "01";
   constant HTRANS_NONSEQ: Std_Logic_Vector(1 downto 0) := "10";
   constant HTRANS_SEQ:    Std_Logic_Vector(1 downto 0) := "11";

   -- constants for HBURST (burst type, master output)
   constant HBURST_SINGLE: Std_Logic_Vector(2 downto 0) := "000";
   constant HBURST_INCR:   Std_Logic_Vector(2 downto 0) := "001";
   constant HBURST_WRAP4:  Std_Logic_Vector(2 downto 0) := "010";
   constant HBURST_INCR4:  Std_Logic_Vector(2 downto 0) := "011";
   constant HBURST_WRAP8:  Std_Logic_Vector(2 downto 0) := "100";
   constant HBURST_INCR8:  Std_Logic_Vector(2 downto 0) := "101";
   constant HBURST_WRAP16: Std_Logic_Vector(2 downto 0) := "110";
   constant HBURST_INCR16: Std_Logic_Vector(2 downto 0) := "111";

   -- constants for HSIZE (transfer size, master output)
   constant HSIZE_BYTE:    Std_Logic_Vector(2 downto 0) := "000";
   constant HSIZE_HWORD:   Std_Logic_Vector(2 downto 0) := "001";
   constant HSIZE_WORD:    Std_Logic_Vector(2 downto 0) := "010";
   constant HSIZE_DWORD:   Std_Logic_Vector(2 downto 0) := "011";
   constant HSIZE_4WORD:   Std_Logic_Vector(2 downto 0) := "100";
   constant HSIZE_8WORD:   Std_Logic_Vector(2 downto 0) := "101";
   constant HSIZE_16WORD:  Std_Logic_Vector(2 downto 0) := "110";
   constant HSIZE_32WORD:  Std_Logic_Vector(2 downto 0) := "111";

   -- constants for HRESP (response, slave output)
   constant HRESP_OKAY:    Std_Logic_Vector(1 downto 0) := "00";
   constant HRESP_ERROR:   Std_Logic_Vector(1 downto 0) := "01";
   constant HRESP_RETRY:   Std_Logic_Vector(1 downto 0) := "10";
   constant HRESP_SPLIT:   Std_Logic_Vector(1 downto 0) := "11";

   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) Advanced Peripheral Bus (APB)
   -----------------------------------------------------------------------------
   -- Records are defined for the input and output of an APB Slave. These
   -- records are grouped in arrays, for scalability, and new records using
   -- these arrays are defined for the input and output of an APB Bridge.
   --
   -- The routing of the clock and reset signals defined in the AMBA(TM)
   -- Specification is not covered in this package, since being dependent on 
   -- the clock and reset conventions defined at system level.
   --
   -- The PCLK and PRESETn signals are routed separately:
   --    PCLK:       Std_ULogic;                         -- rising edge
   --    PRESETn:    Std_ULogic;                         -- active low reset
   --
   -- The characteristics of the address bus PADDR are undefined in the 
   -- AMBA(TM) Specification.
   --
   -- When implementing modules with this package, it is recommended that the
   -- information on the address bus PADDR is interpreted as byte addresses, but
   -- it should only be used for 32-bit word addressing, i.e. the value of 
   -- address bits 0 and 1 should always be logical 0. For modules not 
   -- supporting full 32-bit words on the data bus PDATA, e.g. only supporting 
   -- 16-bit halfwords or 8-bit bytes, the addressing will still be word based.
   -- Consequently, one halfword or byte will be accessed for each word address.
   -- Modules only supporting byte sized data should exchange data on bit 7 to 0 
   -- on the PDATA data bus. Modules only supporting halfword sized data should 
   -- exchange data on bit 15 to 0 on the PDATA data bus. Modules supporting 
   -- word sized data should exchange data on bit 31 to 0 on the PDATA data bus.
   --
   -----------------------------------------------------------------------------
   -- Constant definitions for AMBA(TM) APB
   -----------------------------------------------------------------------------
   constant PDMAX:   Positive range 8 to 32 := 32;       -- data width
   constant PAMAX:   Positive range 8 to 32 := 32;       -- address width

   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) APB Slaves
   -----------------------------------------------------------------------------
   -- APB slave inputs (PCLK and PRESETn routed separately)
   type APB_Slv_In_Type is
      record
         PSEL:       Std_ULogic;                         -- slave select
         PENABLE:    Std_ULogic;                         -- strobe
         PADDR:      Std_Logic_Vector(PAMAX-1 downto 0); -- address bus (byte)
         PWRITE:     Std_ULogic;                         -- write
         PWDATA:     Std_Logic_Vector(PDMAX-1 downto 0); -- write data bus
      end record;

   -- APB slave outputs
   type APB_Slv_Out_Type is
      record
         PRDATA:     Std_Logic_Vector(PDMAX-1 downto 0); -- read data bus
      end record;

   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) APB Bridge
   -----------------------------------------------------------------------------
   -- supporting array types
   type APB_Slv_In_Vector  is array (Natural Range <> ) of APB_Slv_In_Type;
   type APB_Slv_Out_Vector is array (Natural Range <> ) of APB_Slv_Out_Type;

   -- An AHB/APB bridge could be defined as follows:

   -- entity apbmst is
   --   generic (slaves : natural := 32);
   --   port (
   --     clk     : in  std_ulogic;
   --     rst     : in  std_ulogic;
   --     ahbi    : in  ahb_slv_in_type;
   --     ahbo    : out ahb_slv_out_type;
   --     apbi    : in  apb_slv_out_vector(0 to slaves-1);
   --     apbo    : out apb_slv_in_vector(0 to slaves-1)
   --   );
   -- end;


end AMBA; --==================================================================--
