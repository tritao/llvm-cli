//==- SystemZInstrFormats.td - SystemZ Instruction Formats --*- tablegen -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Basic SystemZ instruction definition
//===----------------------------------------------------------------------===//

class InstSystemZ<int size, dag outs, dag ins, string asmstr,
                  list<dag> pattern> : Instruction {
  let Namespace = "SystemZ";

  dag OutOperandList = outs;
  dag InOperandList = ins;
  let Size = size;
  let Pattern = pattern;
  let AsmString = asmstr;

  // Used to identify a group of related instructions, such as ST and STY.
  string Function = "";

  // "12" for an instruction that has a ...Y equivalent, "20" for that
  // ...Y equivalent.
  string PairType = "none";

  // True if this instruction is a simple D(X,B) load of a register
  // (with no sign or zero extension).
  bit SimpleBDXLoad = 0;

  // True if this instruction is a simple D(X,B) store of a register
  // (with no truncation).
  bit SimpleBDXStore = 0;

  // True if this instruction has a 20-bit displacement field.
  bit Has20BitOffset = 0;

  // True if addresses in this instruction have an index register.
  bit HasIndex = 0;

  // True if this is a 128-bit pseudo instruction that combines two 64-bit
  // operations.
  bit Is128Bit = 0;

  let TSFlags{0} = SimpleBDXLoad;
  let TSFlags{1} = SimpleBDXStore;
  let TSFlags{2} = Has20BitOffset;
  let TSFlags{3} = HasIndex;
  let TSFlags{4} = Is128Bit;
}

//===----------------------------------------------------------------------===//
// Mappings between instructions
//===----------------------------------------------------------------------===//

// Return the version of an instruction that has an unsigned 12-bit
// displacement.
def getDisp12Opcode : InstrMapping {
  let FilterClass = "InstSystemZ";
  let RowFields = ["Function"];
  let ColFields = ["PairType"];
  let KeyCol = ["20"];
  let ValueCols = [["12"]];
}

// Return the version of an instruction that has a signed 20-bit displacement.
def getDisp20Opcode : InstrMapping {
  let FilterClass = "InstSystemZ";
  let RowFields = ["Function"];
  let ColFields = ["PairType"];
  let KeyCol = ["12"];
  let ValueCols = [["20"]];
}

//===----------------------------------------------------------------------===//
// Instruction formats
//===----------------------------------------------------------------------===//
//
// Formats are specified using operand field declarations of the form:
//
//   bits<4> Rn   : register input or output for operand n
//   bits<m> In   : immediate value of width m for operand n
//   bits<4> BDn  : address operand n, which has a base and a displacement
//   bits<m> XBDn : address operand n, which has an index, a base and a
//                  displacement
//   bits<4> Xn   : index register for address operand n
//   bits<4> Mn   : mode value for operand n
//
// The operand numbers ("n" in the list above) follow the architecture manual.
// Assembly operands sometimes have a different order; in particular, R3 often
// is often written between operands 1 and 2.
//
//===----------------------------------------------------------------------===//

class InstRI<bits<12> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<4, outs, ins, asmstr, pattern> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  bits<4> R1;
  bits<16> I2;

  let Inst{31-24} = op{11-4};
  let Inst{23-20} = R1;
  let Inst{19-16} = op{3-0};
  let Inst{15-0}  = I2;
}

class InstRIEb<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<4> R1;
  bits<4> R2;
  bits<4> M3;
  bits<16> RI4;

  let Inst{47-40} = op{15-8};
  let Inst{39-36} = R1;
  let Inst{35-32} = R2;
  let Inst{31-16} = RI4;
  let Inst{15-12} = M3;
  let Inst{11-8}  = 0;
  let Inst{7-0}   = op{7-0};
}

class InstRIEf<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<4> R1;
  bits<4> R2;
  bits<8> I3;
  bits<8> I4;
  bits<8> I5;

  let Inst{47-40} = op{15-8};
  let Inst{39-36} = R1;
  let Inst{35-32} = R2;
  let Inst{31-24} = I3;
  let Inst{23-16} = I4;
  let Inst{15-8}  = I5;
  let Inst{7-0}   = op{7-0};
}

class InstRIL<bits<12> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<4> R1;
  bits<32> I2;

  let Inst{47-40} = op{11-4};
  let Inst{39-36} = R1;
  let Inst{35-32} = op{3-0};
  let Inst{31-0}  = I2;
}

class InstRR<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<2, outs, ins, asmstr, pattern> {
  field bits<16> Inst;
  field bits<16> SoftFail = 0;

  bits<4> R1;
  bits<4> R2;

  let Inst{15-8} = op;
  let Inst{7-4}  = R1;
  let Inst{3-0}  = R2;
}

class InstRRD<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<4, outs, ins, asmstr, pattern> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  bits<4> R1;
  bits<4> R3;
  bits<4> R2;

  let Inst{31-16} = op;
  let Inst{15-12} = R1;
  let Inst{11-8}  = 0;
  let Inst{7-4}   = R3;
  let Inst{3-0}   = R2;
}

class InstRRE<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<4, outs, ins, asmstr, pattern> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  bits<4> R1;
  bits<4> R2;

  let Inst{31-16} = op;
  let Inst{15-8}  = 0;
  let Inst{7-4}   = R1;
  let Inst{3-0}   = R2;
}

class InstRRF<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<4, outs, ins, asmstr, pattern> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  bits<4> R1;
  bits<4> R2;
  bits<4> R3;

  let Inst{31-16} = op;
  let Inst{15-12} = R3;
  let Inst{11-8}  = 0;
  let Inst{7-4}   = R1;
  let Inst{3-0}   = R2;
}

class InstRX<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<4, outs, ins, asmstr, pattern> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  bits<4> R1;
  bits<20> XBD2;

  let Inst{31-24} = op;
  let Inst{23-20} = R1;
  let Inst{19-0}  = XBD2;

  let HasIndex = 1;
}

class InstRXE<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<4> R1;
  bits<20> XBD2;

  let Inst{47-40} = op{15-8};
  let Inst{39-36} = R1;
  let Inst{35-16} = XBD2;
  let Inst{15-8}  = 0;
  let Inst{7-0}   = op{7-0};

  let HasIndex = 1;
}

class InstRXF<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<4> R1;
  bits<4> R3;
  bits<20> XBD2;

  let Inst{47-40} = op{15-8};
  let Inst{39-36} = R3;
  let Inst{35-16} = XBD2;
  let Inst{15-12} = R1;
  let Inst{11-8}  = 0;
  let Inst{7-0}   = op{7-0};

  let HasIndex = 1;
}

class InstRXY<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<4> R1;
  bits<28> XBD2;

  let Inst{47-40} = op{15-8};
  let Inst{39-36} = R1;
  let Inst{35-8}  = XBD2;
  let Inst{7-0}   = op{7-0};

  let Has20BitOffset = 1;
  let HasIndex = 1;
}

class InstRS<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<4, outs, ins, asmstr, pattern> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  bits<4> R1;
  bits<4> R3;
  bits<16> BD2;

  let Inst{31-24} = op;
  let Inst{23-20} = R1;
  let Inst{19-16} = R3;
  let Inst{15-0}  = BD2;
}

class InstRSY<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<4> R1;
  bits<4> R3;
  bits<24> BD2;

  let Inst{47-40} = op{15-8};
  let Inst{39-36} = R1;
  let Inst{35-32} = R3;
  let Inst{31-8}  = BD2;
  let Inst{7-0}   = op{7-0};

  let Has20BitOffset = 1;
}

class InstSI<bits<8> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<4, outs, ins, asmstr, pattern> {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;

  bits<16> BD1;
  bits<8> I2;

  let Inst{31-24} = op;
  let Inst{23-16} = I2;
  let Inst{15-0}  = BD1;
}

class InstSIL<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<16> BD1;
  bits<16> I2;

  let Inst{47-32} = op;
  let Inst{31-16} = BD1;
  let Inst{15-0}  = I2;
}

class InstSIY<bits<16> op, dag outs, dag ins, string asmstr, list<dag> pattern>
  : InstSystemZ<6, outs, ins, asmstr, pattern> {
  field bits<48> Inst;
  field bits<48> SoftFail = 0;

  bits<24> BD1;
  bits<8> I2;

  let Inst{47-40} = op{15-8};
  let Inst{39-32} = I2;
  let Inst{31-8}  = BD1;
  let Inst{7-0}   = op{7-0};

  let Has20BitOffset = 1;
}

//===----------------------------------------------------------------------===//
// Instruction definitions with semantics
//===----------------------------------------------------------------------===//
//
// These classes have the form <Category><Format>, where <Format> is one
// of the formats defined above and where <Category> describes the inputs
// and outputs.  <Category> can be one of:
//
//   Inherent:
//     One register output operand and no input operands.
//
//   Store:
//     One register or immediate input operand and one address input operand.
//     The instruction stores the first operand to the address.
//
//     This category is used for both pure and truncating stores.
//
//   LoadMultiple:
//     One address input operand and two explicit output operands.
//     The instruction loads a range of registers from the address,
//     with the explicit operands giving the first and last register
//     to load.  Other loaded registers are added as implicit definitions.
//
//   StoreMultiple:
//     Two explicit input register operands and an address operand.
//     The instruction stores a range of registers to the address,
//     with the explicit operands giving the first and last register
//     to store.  Other stored registers are added as implicit uses.
//
//   Unary:
//     One register output operand and one input operand.  The input
//     operand may be a register, immediate or memory.
//
//   Binary:
//     One register output operand and two input operands.  The first
//     input operand is always a register and he second may be a register,
//     immediate or memory.
//
//   Shift:
//     One register output operand and two input operands.  The first
//     input operand is a register and the second has the same form as
//     an address (although it isn't actually used to address memory).
//
//   Compare:
//     Two input operands.  The first operand is always a register,
//     the second may be a register, immediate or memory.
//
//   Ternary:
//     One register output operand and three register input operands.
//
//   CmpSwap:
//     One output operand and three input operands.  The first two
//     operands are registers and the third is an address.  The instruction
//     both reads from and writes to the address.
//
//   RotateSelect:
//     One output operand and five input operands.  The first two operands
//     are registers and the other three are immediates.
//
// The format determines which input operands are tied to output operands,
// and also determines the shape of any address operand.
//
// Multiclasses of the form <Category><Format>Pair define two instructions,
// one with <Category><Format> and one with <Category><Format>Y.  The name
// of the first instruction has no suffix, the name of the second has
// an extra "y".
//
//===----------------------------------------------------------------------===//

class InherentRRE<string mnemonic, bits<16> opcode, RegisterOperand cls,
                  dag src>
  : InstRRE<opcode, (outs cls:$R1), (ins),
            mnemonic#"\t$R1",
            [(set cls:$R1, src)]> {
  let R2 = 0;
}

class LoadMultipleRSY<string mnemonic, bits<16> opcode, RegisterOperand cls>
  : InstRSY<opcode, (outs cls:$R1, cls:$R3), (ins bdaddr20only:$BD2),
            mnemonic#"\t$R1, $R3, $BD2", []> {
  let mayLoad = 1;
}

class StoreRILPC<string mnemonic, bits<12> opcode, SDPatternOperator operator,
                 RegisterOperand cls>
  : InstRIL<opcode, (outs), (ins cls:$R1, pcrel32:$I2),
            mnemonic#"\t$R1, $I2",
            [(operator cls:$R1, pcrel32:$I2)]> {
  let mayStore = 1;
  // We want PC-relative addresses to be tried ahead of BD and BDX addresses.
  // However, BDXs have two extra operands and are therefore 6 units more
  // complex.
  let AddedComplexity = 7;
}

class StoreRX<string mnemonic, bits<8> opcode, SDPatternOperator operator,
              RegisterOperand cls, AddressingMode mode = bdxaddr12only>
  : InstRX<opcode, (outs), (ins cls:$R1, mode:$XBD2),
           mnemonic#"\t$R1, $XBD2",
           [(operator cls:$R1, mode:$XBD2)]> {
  let mayStore = 1;
}

class StoreRXY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
               RegisterOperand cls, AddressingMode mode = bdxaddr20only>
  : InstRXY<opcode, (outs), (ins cls:$R1, mode:$XBD2),
            mnemonic#"\t$R1, $XBD2",
            [(operator cls:$R1, mode:$XBD2)]> {
  let mayStore = 1;
}

multiclass StoreRXPair<string mnemonic, bits<8> rxOpcode, bits<16> rxyOpcode,
                       SDPatternOperator operator, RegisterOperand cls> {
  let Function = mnemonic ## #cls in {
    let PairType = "12" in
      def "" : StoreRX<mnemonic, rxOpcode, operator, cls, bdxaddr12pair>;
    let PairType = "20" in
      def Y  : StoreRXY<mnemonic#"y", rxyOpcode, operator, cls, bdxaddr20pair>;
  }
}

class StoreMultipleRSY<string mnemonic, bits<16> opcode, RegisterOperand cls>
  : InstRSY<opcode, (outs), (ins cls:$R1, cls:$R3, bdaddr20only:$BD2),
            mnemonic#"\t$R1, $R3, $BD2", []> {
  let mayStore = 1;
}

class StoreSI<string mnemonic, bits<8> opcode, SDPatternOperator operator,
              Immediate imm, AddressingMode mode = bdaddr12only>
  : InstSI<opcode, (outs), (ins mode:$BD1, imm:$I2),
           mnemonic#"\t$BD1, $I2",
           [(operator imm:$I2, mode:$BD1)]> {
  let mayStore = 1;
}

class StoreSIY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
               Immediate imm, AddressingMode mode = bdaddr20only>
  : InstSIY<opcode, (outs), (ins mode:$BD1, imm:$I2),
            mnemonic#"\t$BD1, $I2",
            [(operator imm:$I2, mode:$BD1)]> {
  let mayStore = 1;
}

class StoreSIL<string mnemonic, bits<16> opcode, SDPatternOperator operator,
               Immediate imm>
  : InstSIL<opcode, (outs), (ins bdaddr12only:$BD1, imm:$I2),
            mnemonic#"\t$BD1, $I2",
            [(operator imm:$I2, bdaddr12only:$BD1)]> {
  let mayStore = 1;
}

multiclass StoreSIPair<string mnemonic, bits<8> siOpcode, bits<16> siyOpcode,
                       SDPatternOperator operator, Immediate imm> {
  let Function = mnemonic in {
    let PairType = "12" in
      def "" : StoreSI<mnemonic, siOpcode, operator, imm, bdaddr12pair>;
    let PairType = "20" in
      def Y  : StoreSIY<mnemonic#"y", siyOpcode, operator, imm, bdaddr20pair>;
  }
}

class UnaryRR<string mnemonic, bits<8> opcode, SDPatternOperator operator,
              RegisterOperand cls1, RegisterOperand cls2>
  : InstRR<opcode, (outs cls1:$R1), (ins cls2:$R2),
           mnemonic#"\t$R1, $R2",
           [(set cls1:$R1, (operator cls2:$R2))]>;

class UnaryRRE<string mnemonic, bits<16> opcode, SDPatternOperator operator,
               RegisterOperand cls1, RegisterOperand cls2>
  : InstRRE<opcode, (outs cls1:$R1), (ins cls2:$R2),
            mnemonic#"\t$R1, $R2",
            [(set cls1:$R1, (operator cls2:$R2))]>;

class UnaryRRF<string mnemonic, bits<16> opcode, RegisterOperand cls1,
               RegisterOperand cls2>
  : InstRRF<opcode, (outs cls1:$R1), (ins uimm8zx4:$R3, cls2:$R2),
            mnemonic#"\t$R1, $R3, $R2", []>;

class UnaryRI<string mnemonic, bits<12> opcode, SDPatternOperator operator,
              RegisterOperand cls, Immediate imm>
  : InstRI<opcode, (outs cls:$R1), (ins imm:$I2),
           mnemonic#"\t$R1, $I2",
           [(set cls:$R1, (operator imm:$I2))]>;

class UnaryRIL<string mnemonic, bits<12> opcode, SDPatternOperator operator,
               RegisterOperand cls, Immediate imm>
  : InstRIL<opcode, (outs cls:$R1), (ins imm:$I2),
            mnemonic#"\t$R1, $I2",
            [(set cls:$R1, (operator imm:$I2))]>;

class UnaryRILPC<string mnemonic, bits<12> opcode, SDPatternOperator operator,
                 RegisterOperand cls>
  : InstRIL<opcode, (outs cls:$R1), (ins pcrel32:$I2),
            mnemonic#"\t$R1, $I2",
            [(set cls:$R1, (operator pcrel32:$I2))]> {
  let mayLoad = 1;
  // We want PC-relative addresses to be tried ahead of BD and BDX addresses.
  // However, BDXs have two extra operands and are therefore 6 units more
  // complex.
  let AddedComplexity = 7;
}

class UnaryRX<string mnemonic, bits<8> opcode, SDPatternOperator operator,
              RegisterOperand cls, AddressingMode mode = bdxaddr12only>
  : InstRX<opcode, (outs cls:$R1), (ins mode:$XBD2),
           mnemonic#"\t$R1, $XBD2",
           [(set cls:$R1, (operator mode:$XBD2))]> {
  let mayLoad = 1;
}

class UnaryRXE<string mnemonic, bits<16> opcode, SDPatternOperator operator,
               RegisterOperand cls>
  : InstRXE<opcode, (outs cls:$R1), (ins bdxaddr12only:$XBD2),
            mnemonic#"\t$R1, $XBD2",
            [(set cls:$R1, (operator bdxaddr12only:$XBD2))]> {
  let mayLoad = 1;
}

class UnaryRXY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
               RegisterOperand cls, AddressingMode mode = bdxaddr20only>
  : InstRXY<opcode, (outs cls:$R1), (ins mode:$XBD2),
            mnemonic#"\t$R1, $XBD2",
            [(set cls:$R1, (operator mode:$XBD2))]> {
  let mayLoad = 1;
}

multiclass UnaryRXPair<string mnemonic, bits<8> rxOpcode, bits<16> rxyOpcode,
                       SDPatternOperator operator, RegisterOperand cls> {
  let Function = mnemonic ## #cls in {
    let PairType = "12" in
      def "" : UnaryRX<mnemonic, rxOpcode, operator, cls, bdxaddr12pair>;
    let PairType = "20" in
      def Y  : UnaryRXY<mnemonic#"y", rxyOpcode, operator, cls, bdxaddr20pair>;
  }
}

class BinaryRR<string mnemonic, bits<8> opcode, SDPatternOperator operator,
               RegisterOperand cls1, RegisterOperand cls2>
  : InstRR<opcode, (outs cls1:$R1), (ins cls1:$R1src, cls2:$R2),
           mnemonic#"\t$R1, $R2",
           [(set cls1:$R1, (operator cls1:$R1src, cls2:$R2))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
}

class BinaryRRE<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                RegisterOperand cls1, RegisterOperand cls2>
  : InstRRE<opcode, (outs cls1:$R1), (ins cls1:$R1src, cls2:$R2),
            mnemonic#"\t$R1, $R2",
            [(set cls1:$R1, (operator cls1:$R1src, cls2:$R2))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
}

class BinaryRRF<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                RegisterOperand cls1, RegisterOperand cls2>
  : InstRRF<opcode, (outs cls1:$R1), (ins cls1:$R3, cls2:$R2),
            mnemonic#"\t$R1, $R3, $R2",
            [(set cls1:$R1, (operator cls1:$R3, cls2:$R2))]>;

class BinaryRI<string mnemonic, bits<12> opcode, SDPatternOperator operator,
               RegisterOperand cls, Immediate imm>
  : InstRI<opcode, (outs cls:$R1), (ins cls:$R1src, imm:$I2),
           mnemonic#"\t$R1, $I2",
           [(set cls:$R1, (operator cls:$R1src, imm:$I2))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
}

class BinaryRIL<string mnemonic, bits<12> opcode, SDPatternOperator operator,
                RegisterOperand cls, Immediate imm>
  : InstRIL<opcode, (outs cls:$R1), (ins cls:$R1src, imm:$I2),
            mnemonic#"\t$R1, $I2",
            [(set cls:$R1, (operator cls:$R1src, imm:$I2))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
}

class BinaryRX<string mnemonic, bits<8> opcode, SDPatternOperator operator,
               RegisterOperand cls, SDPatternOperator load,
               AddressingMode mode = bdxaddr12only>
  : InstRX<opcode, (outs cls:$R1), (ins cls:$R1src, mode:$XBD2),
           mnemonic#"\t$R1, $XBD2",
           [(set cls:$R1, (operator cls:$R1src, (load mode:$XBD2)))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
  let mayLoad = 1;
}

class BinaryRXE<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                  RegisterOperand cls, SDPatternOperator load>
  : InstRXE<opcode, (outs cls:$R1), (ins cls:$R1src, bdxaddr12only:$XBD2),
            mnemonic#"\t$R1, $XBD2",
            [(set cls:$R1, (operator cls:$R1src,
                                     (load bdxaddr12only:$XBD2)))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
  let mayLoad = 1;
}

class BinaryRXY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                RegisterOperand cls, SDPatternOperator load,
                AddressingMode mode = bdxaddr20only>
  : InstRXY<opcode, (outs cls:$R1), (ins cls:$R1src, mode:$XBD2),
            mnemonic#"\t$R1, $XBD2",
            [(set cls:$R1, (operator cls:$R1src, (load mode:$XBD2)))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
  let mayLoad = 1;
}

multiclass BinaryRXPair<string mnemonic, bits<8> rxOpcode, bits<16> rxyOpcode,
                        SDPatternOperator operator, RegisterOperand cls,
                        SDPatternOperator load> {
  let Function = mnemonic ## #cls in {
    let PairType = "12" in
      def "" : BinaryRX<mnemonic, rxOpcode, operator, cls, load, bdxaddr12pair>;
    let PairType = "20" in
      def Y  : BinaryRXY<mnemonic#"y", rxyOpcode, operator, cls, load,
                         bdxaddr20pair>;
  }
}

class BinarySI<string mnemonic, bits<8> opcode, SDPatternOperator operator,
               Operand imm, AddressingMode mode = bdaddr12only>
  : InstSI<opcode, (outs), (ins mode:$BD1, imm:$I2),
           mnemonic#"\t$BD1, $I2",
           [(store (operator (load mode:$BD1), imm:$I2), mode:$BD1)]> {
  let mayLoad = 1;
  let mayStore = 1;
}

class BinarySIY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                Operand imm, AddressingMode mode = bdaddr20only>
  : InstSIY<opcode, (outs), (ins mode:$BD1, imm:$I2),
            mnemonic#"\t$BD1, $I2",
            [(store (operator (load mode:$BD1), imm:$I2), mode:$BD1)]> {
  let mayLoad = 1;
  let mayStore = 1;
}

multiclass BinarySIPair<string mnemonic, bits<8> siOpcode,
                        bits<16> siyOpcode, SDPatternOperator operator,
                        Operand imm> {
  let Function = mnemonic ## #cls in {
    let PairType = "12" in
      def "" : BinarySI<mnemonic, siOpcode, operator, imm, bdaddr12pair>;
    let PairType = "20" in
      def Y  : BinarySIY<mnemonic#"y", siyOpcode, operator, imm, bdaddr20pair>;
  }
}

class ShiftRS<string mnemonic, bits<8> opcode, SDPatternOperator operator,
              RegisterOperand cls, AddressingMode mode>
  : InstRS<opcode, (outs cls:$R1), (ins cls:$R1src, mode:$BD2),
           mnemonic#"\t$R1, $BD2",
           [(set cls:$R1, (operator cls:$R1src, mode:$BD2))]> {
  let R3 = 0;
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
}

class ShiftRSY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
               RegisterOperand cls, AddressingMode mode>
  : InstRSY<opcode, (outs cls:$R1), (ins cls:$R3, mode:$BD2),
            mnemonic#"\t$R1, $R3, $BD2",
            [(set cls:$R1, (operator cls:$R3, mode:$BD2))]>;

class CompareRR<string mnemonic, bits<8> opcode, SDPatternOperator operator,
                RegisterOperand cls1, RegisterOperand cls2>
  : InstRR<opcode, (outs), (ins cls1:$R1, cls2:$R2),
           mnemonic#"\t$R1, $R2",
           [(operator cls1:$R1, cls2:$R2)]>;

class CompareRRE<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                 RegisterOperand cls1, RegisterOperand cls2>
  : InstRRE<opcode, (outs), (ins cls1:$R1, cls2:$R2),
            mnemonic#"\t$R1, $R2",
            [(operator cls1:$R1, cls2:$R2)]>;

class CompareRI<string mnemonic, bits<12> opcode, SDPatternOperator operator,
                RegisterOperand cls, Immediate imm>
  : InstRI<opcode, (outs), (ins cls:$R1, imm:$I2),
           mnemonic#"\t$R1, $I2",
           [(operator cls:$R1, imm:$I2)]>;

class CompareRIL<string mnemonic, bits<12> opcode, SDPatternOperator operator,
                 RegisterOperand cls, Immediate imm>
  : InstRIL<opcode, (outs), (ins cls:$R1, imm:$I2),
            mnemonic#"\t$R1, $I2",
            [(operator cls:$R1, imm:$I2)]>;

class CompareRILPC<string mnemonic, bits<12> opcode, SDPatternOperator operator,
                   RegisterOperand cls, SDPatternOperator load>
  : InstRIL<opcode, (outs), (ins cls:$R1, pcrel32:$I2),
            mnemonic#"\t$R1, $I2",
            [(operator cls:$R1, (load pcrel32:$I2))]> {
  let mayLoad = 1;
  // We want PC-relative addresses to be tried ahead of BD and BDX addresses.
  // However, BDXs have two extra operands and are therefore 6 units more
  // complex.
  let AddedComplexity = 7;
}

class CompareRX<string mnemonic, bits<8> opcode, SDPatternOperator operator,
                RegisterOperand cls, SDPatternOperator load,
                AddressingMode mode = bdxaddr12only>
  : InstRX<opcode, (outs), (ins cls:$R1, mode:$XBD2),
           mnemonic#"\t$R1, $XBD2",
           [(operator cls:$R1, (load mode:$XBD2))]> {
  let mayLoad = 1;
}

class CompareRXE<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                 RegisterOperand cls, SDPatternOperator load>
  : InstRXE<opcode, (outs), (ins cls:$R1, bdxaddr12only:$XBD2),
            mnemonic#"\t$R1, $XBD2",
            [(operator cls:$R1, (load bdxaddr12only:$XBD2))]> {
  let mayLoad = 1;
}

class CompareRXY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                 RegisterOperand cls, SDPatternOperator load,
                 AddressingMode mode = bdxaddr20only>
  : InstRXY<opcode, (outs), (ins cls:$R1, mode:$XBD2),
            mnemonic#"\t$R1, $XBD2",
            [(operator cls:$R1, (load mode:$XBD2))]> {
  let mayLoad = 1;
}

multiclass CompareRXPair<string mnemonic, bits<8> rxOpcode, bits<16> rxyOpcode,
                         SDPatternOperator operator, RegisterOperand cls,
                         SDPatternOperator load> {
  let Function = mnemonic ## #cls in {
    let PairType = "12" in
      def "" : CompareRX<mnemonic, rxOpcode, operator, cls,
                         load, bdxaddr12pair>;
    let PairType = "20" in
      def Y  : CompareRXY<mnemonic#"y", rxyOpcode, operator, cls,
                          load, bdxaddr20pair>;
  }
}

class CompareSI<string mnemonic, bits<8> opcode, SDPatternOperator operator,
                SDPatternOperator load, Immediate imm,
                AddressingMode mode = bdaddr12only>
  : InstSI<opcode, (outs), (ins mode:$BD1, imm:$I2),
           mnemonic#"\t$BD1, $I2",
           [(operator (load mode:$BD1), imm:$I2)]> {
  let mayLoad = 1;
}

class CompareSIL<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                 SDPatternOperator load, Immediate imm>
  : InstSIL<opcode, (outs), (ins bdaddr12only:$BD1, imm:$I2),
            mnemonic#"\t$BD1, $I2",
            [(operator (load bdaddr12only:$BD1), imm:$I2)]> {
  let mayLoad = 1;
}

class CompareSIY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                 SDPatternOperator load, Immediate imm,
                 AddressingMode mode = bdaddr20only>
  : InstSIY<opcode, (outs), (ins mode:$BD1, imm:$I2),
            mnemonic#"\t$BD1, $I2",
            [(operator (load mode:$BD1), imm:$I2)]> {
  let mayLoad = 1;
}

multiclass CompareSIPair<string mnemonic, bits<8> siOpcode, bits<16> siyOpcode,
                         SDPatternOperator operator, SDPatternOperator load,
                         Immediate imm> {
  let Function = mnemonic in {
    let PairType = "12" in
      def "" : CompareSI<mnemonic, siOpcode, operator, load, imm, bdaddr12pair>;
    let PairType = "20" in
      def Y  : CompareSIY<mnemonic#"y", siyOpcode, operator, load, imm,
                          bdaddr20pair>;
  }
}

class TernaryRRD<string mnemonic, bits<16> opcode,
                 SDPatternOperator operator, RegisterOperand cls>
  : InstRRD<opcode, (outs cls:$R1), (ins cls:$R1src, cls:$R3, cls:$R2),
            mnemonic#"\t$R1, $R3, $R2",
            [(set cls:$R1, (operator cls:$R1src, cls:$R3, cls:$R2))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
}

class TernaryRXF<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                 RegisterOperand cls, SDPatternOperator load>
  : InstRXF<opcode, (outs cls:$R1),
            (ins cls:$R1src, cls:$R3, bdxaddr12only:$XBD2),
            mnemonic#"\t$R1, $R3, $XBD2",
            [(set cls:$R1, (operator cls:$R1src, cls:$R3,
                                     (load bdxaddr12only:$XBD2)))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
  let mayLoad = 1;
}

class CmpSwapRS<string mnemonic, bits<8> opcode, SDPatternOperator operator,
                RegisterOperand cls, AddressingMode mode = bdaddr12only>
  : InstRS<opcode, (outs cls:$R1), (ins cls:$R1src, cls:$R3, mode:$BD2),
           mnemonic#"\t$R1, $R3, $BD2",
           [(set cls:$R1, (operator mode:$BD2, cls:$R1src, cls:$R3))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
  let mayLoad = 1;
  let mayStore = 1;
}

class CmpSwapRSY<string mnemonic, bits<16> opcode, SDPatternOperator operator,
                 RegisterOperand cls, AddressingMode mode = bdaddr20only>
  : InstRSY<opcode, (outs cls:$R1), (ins cls:$R1src, cls:$R3, mode:$BD2),
            mnemonic#"\t$R1, $R3, $BD2",
            [(set cls:$R1, (operator mode:$BD2, cls:$R1src, cls:$R3))]> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
  let mayLoad = 1;
  let mayStore = 1;
}

multiclass CmpSwapRSPair<string mnemonic, bits<8> rsOpcode, bits<16> rsyOpcode,
                         SDPatternOperator operator, RegisterOperand cls> {
  let Function = mnemonic ## #cls in {
    let PairType = "12" in
      def "" : CmpSwapRS<mnemonic, rsOpcode, operator, cls, bdaddr12pair>;
    let PairType = "20" in
      def Y  : CmpSwapRSY<mnemonic#"y", rsyOpcode, operator, cls, bdaddr20pair>;
  }
}

class RotateSelectRIEf<string mnemonic, bits<16> opcode, RegisterOperand cls1,
                       RegisterOperand cls2>
  : InstRIEf<opcode, (outs cls1:$R1),
             (ins cls1:$R1src, cls2:$R2,
                  uimm8zx6:$I3, uimm8zx6:$I4, uimm8zx6:$I5),
             mnemonic#"\t$R1, $R2, $I3, $I4, $I5", []> {
  let Constraints = "$R1 = $R1src";
  let DisableEncoding = "$R1src";
}

//===----------------------------------------------------------------------===//
// Pseudo instructions
//===----------------------------------------------------------------------===//
//
// Convenience instructions that get lowered to real instructions
// by either SystemZTargetLowering::EmitInstrWithCustomInserter()
// or SystemZInstrInfo::expandPostRAPseudo().
//
//===----------------------------------------------------------------------===//

class Pseudo<dag outs, dag ins, list<dag> pattern>
  : InstSystemZ<0, outs, ins, "", pattern> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}

// Implements "$dst = $cc & (8 >> CC) ? $src1 : $src2", where CC is
// the value of the PSW's 2-bit condition code field.
class SelectWrapper<RegisterOperand cls>
  : Pseudo<(outs cls:$dst), (ins cls:$src1, cls:$src2, i8imm:$cc),
           [(set cls:$dst, (z_select_ccmask cls:$src1, cls:$src2, imm:$cc))]> {
  let usesCustomInserter = 1;
  // Although the instructions used by these nodes do not in themselves
  // change CC, the insertion requires new blocks, and CC cannot be live
  // across them.
  let Defs = [CC];
  let Uses = [CC];
}

// OPERATOR is ATOMIC_SWAP or an ATOMIC_LOAD_* operation.  PAT and OPERAND
// describe the second (non-memory) operand.
class AtomicLoadBinary<SDPatternOperator operator, RegisterOperand cls,
                       dag pat, DAGOperand operand>
  : Pseudo<(outs cls:$dst), (ins bdaddr20only:$ptr, operand:$src2),
           [(set cls:$dst, (operator bdaddr20only:$ptr, pat))]> {
  let Defs = [CC];
  let Has20BitOffset = 1;
  let mayLoad = 1;
  let mayStore = 1;
  let usesCustomInserter = 1;
}

// Specializations of AtomicLoadWBinary.
class AtomicLoadBinaryReg32<SDPatternOperator operator>
  : AtomicLoadBinary<operator, GR32, (i32 GR32:$src2), GR32>;
class AtomicLoadBinaryImm32<SDPatternOperator operator, Immediate imm>
  : AtomicLoadBinary<operator, GR32, (i32 imm:$src2), imm>;
class AtomicLoadBinaryReg64<SDPatternOperator operator>
  : AtomicLoadBinary<operator, GR64, (i64 GR64:$src2), GR64>;
class AtomicLoadBinaryImm64<SDPatternOperator operator, Immediate imm>
  : AtomicLoadBinary<operator, GR64, (i64 imm:$src2), imm>;

// OPERATOR is ATOMIC_SWAPW or an ATOMIC_LOADW_* operation.  PAT and OPERAND
// describe the second (non-memory) operand.
class AtomicLoadWBinary<SDPatternOperator operator, dag pat,
                        DAGOperand operand>
  : Pseudo<(outs GR32:$dst),
           (ins bdaddr20only:$ptr, operand:$src2, ADDR32:$bitshift,
                ADDR32:$negbitshift, uimm32:$bitsize),
           [(set GR32:$dst, (operator bdaddr20only:$ptr, pat, ADDR32:$bitshift,
                                      ADDR32:$negbitshift, uimm32:$bitsize))]> {
  let Defs = [CC];
  let Has20BitOffset = 1;
  let mayLoad = 1;
  let mayStore = 1;
  let usesCustomInserter = 1;
}

// Specializations of AtomicLoadWBinary.
class AtomicLoadWBinaryReg<SDPatternOperator operator>
  : AtomicLoadWBinary<operator, (i32 GR32:$src2), GR32>;
class AtomicLoadWBinaryImm<SDPatternOperator operator, Immediate imm>
  : AtomicLoadWBinary<operator, (i32 imm:$src2), imm>;
