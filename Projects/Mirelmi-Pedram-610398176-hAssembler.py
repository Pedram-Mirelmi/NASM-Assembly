import re
from typing import Union

DEBUG = False

reg_code = {
    "al": "0000",
    "ah": "0100",
    "ax": "0000",
    "eax": "0000",
    "rax": "0000",

    "cl": "0001",
    "ch": "0101",
    "cx": "0001",
    "ecx": "0001",
    "rcx": "0001",

    "dl": "0010",
    "dh": "0110",
    "dx": "0010",
    "edx": "0010",
    "rdx": "0010",

    "bl": "0011",
    "bh": "0111",
    "bx": "0011",
    "ebx": "0011",
    "rbx": "0011",

    "sp": "0100",
    "esp": "0100",
    "rsp": "0100",

    "bp": "0101",
    "ebp": "0101",
    "rbp": "0101",

    "si": "0110",
    "esi": "0110",
    "rsi": "0110",

    "di": "0111",
    "edi": "0111",
    "rdi": "0111",

    "r8b": "1000",
    "r8w": "1000",
    "r8d": "1000",
    "r8": "1000",

    "r9": "1001",
    "r9d": "1001",
    "r9w": "1001",
    "r9b": "1001",

    "r10b": "1010",
    "r10w": "1010",
    "r10d": "1010",
    "r10": "1010",

    "r11b": "1011",
    "r11w": "1011",
    "r11d": "1011",
    "r11": "1011",

    "r12b": "1100",
    "r12w": "1100",
    "r12d": "1100",
    "r12": "1100",

    "r13b": "1101",
    "r13w": "1101",
    "r13d": "1101",
    "r13": "1101",

    "r14b": "1110",
    "r14w": "1110",
    "r14d": "1110",
    "r14": "1110",

    "r15b": "1111",
    "r15w": "1111",
    "r15d": "1111",
    "r15": "1111"
}

reg_size = {
    "al": 8,
    "cl": 8,
    "dl": 8,
    "bl": 8,
    "ah": 8,
    "ch": 8,
    "dh": 8,
    "bh": 8,

    "r8b": 8,
    "r9b": 8,
    "r10b": 8,
    "r11b": 8,
    "r12b": 8,
    "r13b": 8,
    "r14b": 8,
    "r15b": 8,

    "ax": 16,
    "cx": 16,
    "dx": 16,
    "bx": 16,
    "sp": 16,
    "bp": 16,
    "si": 16,
    "di": 16,

    "r8w": 16,
    "r9w": 16,
    "r10w": 16,
    "r12w": 16,
    "r13w": 16,
    "r11w": 16,
    "r14w": 16,
    "r15w": 16,

    "eax": 32,
    "ecx": 32,
    "edx": 32,
    "ebx": 32,
    "esp": 32,
    "ebp": 32,
    "esi": 32,
    "edi": 32,

    "r8d": 32,
    "r9d": 32,
    "r10d": 32,
    "r11d": 32,
    "r12d": 32,
    "r13d": 32,
    "r14d": 32,
    "r15d": 32,

    "rax": 64,
    "rcx": 64,
    "rdx": 64,
    "rbx": 64,
    "rsp": 64,
    "rbp": 64,
    "rsi": 64,
    "rdi": 64,

    "r8": 64,
    "r9": 64,
    "r10": 64,
    "r11": 64,
    "r12": 64,
    "r13": 64,
    "r14": 64,
    "r15": 64
}

displacements_modes = {
    None: '00',
    8: '01',
    32: '10',
    'reg': '11'
}

scales = {
    1: '00',
    2: '01',
    4: '10',
    8: '11'
}

sizes = {
    "byte": 8,
    "word": 16,
    "dword": 32,
    "qword": 64
}

single_commands = {
    "stc": "f9",
    "clc": "f8",
    "std": "fd",
    "cld": "fc",
    "syscall": "0f05",
    "ret": "C3"
}

single_operand_commands = {
    "neg": {
        'r': '1111 01',
        'm': '1111 01',
    },
    "not": {
        'r': '1111 01',
        'm': '1111 01',
    },
    "push": {
        'r': '0101 0',
        'm': '1111 11',
        'i': '0110 10'
    },
    "pop": {
        'r': '0101 1',
        'm': '1000 11'
    },
    "inc": {
        'r': '1111 11',
        'm': '1111 11'
    },
    "dec": {
        'r': '1111 11',
        'm': '1111 11'
    },
    "idiv": {
        'r': '1111 01',
        'm': '1111 01'
    },

}

two_operand_commands = {
    "mov": {
        'r,r': '1000 10',
        'r,m': '1000 10',
        'm,r': '1000 10',
        'r,i': '1011',
        'm,i': '1100 10'
    },
    "add": {
        'r,r': '0000 00',
        'r,m': '0000 00',
        'm,r': '0000 00',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "adc": {
        'r,r': '0001 00',
        'r,m': '0001 00',
        'm,r': '0001 00',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "sub": {
        'r,r': '0010 10',
        'r,m': '0010 10',
        'm,r': '0010 10',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "sbb": {
        'r,r': '0001 10',
        'r,m': '0001 10',
        'm,r': '0001 10',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "and": {
        'r,r': '0010 00',
        'r,m': '0010 00',
        'm,r': '0010 00',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "or": {
        'r,r': '0000 10',
        'r,m': '0000 10',
        'm,r': '0000 10',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "xor": {
        'r,r': '0011 00',
        'r,m': '0011 00',
        'm,r': '0011 00',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "cmp": {
        'r,r': '0011 10',
        'r,m': '0011 10',
        'm,r': '0011 10',
        'r,i': '1000 00',
        'm,i': '1000 00'
    },
    "test": {
        'r,r': '1000 01',
        'r,m': '1000 01',
        'm,r': '1000 01',
        'r,i': '1111 01',
        'm,i': '1111 01'
    },
    "xchg": {
        'r,r': '1000 01',
        'r,m': '1000 01',
        'm,r': '1000 01',
    },
    "xadd": {
        'r,r': '0000 1111 1100 00',
        'm,r': '0000 1111 1100 00'
    },
    "imul": {
        'a,r': '1111 01',

        'r,r': '0000 1111 1010 11',
        'r,m': '0000 1111 1010 11',
    },
    "bsf": {
        'r,r': '0000 1111 1011 1100',
        'm,r': '0000 1111 1011 1100'
    },
    "bsr": {
        'r,r': '0000 1111 1011 1101',
        'm,r': '0000 1111 1011 1101'
    },
    "shr": {
        1: '1101 00',
        'i': '1100 00'
    },
    "shl": {
        1: '1101 00',
        'i': '1100 00'
    },
}

regOp = {  # when we have some part of opcode in regOp field
    "add": '000',
    "adc": '010',
    "sub": '101',
    "sbb": '011',
    "and": '100',
    "or": '001',
    "xor": '110',
    "cmp": '111',

    "shr": '101',
    "shl": '100',

    "neg": "011",
    "not": "010",
    "push": "110",
    "pop": "000",

    "inc": "000",
    "dec": "001",

    "idiv": "111",


    "mov": "000"

}

prefixes = {
    (32, 64): (False, False),
    (32, 32): (False, True),
    (16, 64): (True, False),
    (16, 32): (True, True),
    (64, 64): (False, False),
    (64, 32): (False, True)
}


class Operand:
    def __init__(self):
        self.size = None


class Immediate(Operand):
    def __init__(self, value, preferred_size=None, init=False):
        super(Immediate, self).__init__()
        self.initiated = False
        if init:
            self.__doInit(value, preferred_size)

    def __doInit(self, value: int, preferred_size: int = None):
        self.initiated = True
        self.value = value
        if -(2 ** 7) <= value < 2 ** 7:
            self.real_size = 8
        elif -(2 ** 15) <= value < 2 ** 15:
            self.real_size = 16
        elif -(2 ** 31) <= value < 2 ** 31:
            self.real_size = 32
        else:
            self.real_size = 64
        self.preferred_size = preferred_size if preferred_size else self.real_size
        self.size = self.real_size

    def getSize(self):
        return self.preferred_size if self.preferred_size else self.real_size

    def getHex(self):
        in_hex = hex(int(self.getBinary(), 2))[2:]
        return '0' * (self.getSize() // 4 - len(in_hex)) + in_hex

    def getReversedHex(self):
        result = ""
        in_hex = self.getHex()
        for i in range(0, len(in_hex), 2):
            result = in_hex[i:i + 2] + result
        return result

    def getReversedBinary(self):
        result = ""
        in_bin = self.getBinary()
        for i in range(0, len(in_bin), 8):
            result = in_bin[i: i+8] + result
        return result

    def getBinary(self):
        if self.value >= 0:
            in_binary = bin(self.value)[2:]
            return '0' * (self.getSize() - len(in_binary)) + in_binary
        return bin(self.value + (1 << self.getSize()))

    def __str__(self):
        if self.initiated:
            if DEBUG:
                return "Imm:" + self.getReversedHex()
            else:
                return self.getReversedBinary()
        return ""


class Register(Operand):
    def __init__(self, source_str: str):
        super(Register, self).__init__()
        self.register_str = source_str.strip()
        self.size = reg_size[self.register_str]
        self.old_code = reg_code[self.register_str][1:]
        self.is_new = self.register_str[1].isdigit()
        self.new_code = reg_code[self.register_str][0]

    def __repr__(self):
        return self.register_str


class Memory(Operand):
    def __init__(self, source_str):
        super(Memory, self).__init__()
        self.direct_addressing = False
        self.address_size = 0
        self.uses_new_registers = False
        self.__split(source_str)

    def __split(self, source_str: str):
        outer_tokens = source_str.split()  # <SIZE> PTR [<address>]
        self.size = sizes[outer_tokens[0]]
        address_tokens = re.split(r'[\*\+]', outer_tokens[-1][1:-1])
        if address_tokens[-1].startswith("0x"):
            self.displacement = Immediate(int(address_tokens.pop()[2:], 16), init=True)
            self.displacement.preferred_size = 8 if self.displacement.real_size == 8 else 32
        else:
            self.displacement = None

        if address_tokens:
            if address_tokens[-1] in {'1', '2', '4', '8'}:  # we have index and scale
                self.scale = int(address_tokens.pop())
                self.index = Register(address_tokens.pop())
                self.uses_new_registers = self.uses_new_registers or self.index.register_str[1].isdigit()
                self.address_size = max(self.address_size, self.index.size)
            else:
                self.scale = None
                self.index = None

            if address_tokens:
                self.base = Register(address_tokens.pop())
                self.uses_new_registers = self.uses_new_registers or self.base.register_str[1].isdigit()
                self.address_size = max(self.address_size, self.base.size)
            else:
                self.base = None
        else:
            self.scale = None
            self.index = None
            self.base = None
            self.direct_addressing = True


class Prefix:
    def __init__(self):
        self.prefixG1 = ""
        self.prefixG2 = ""
        self.prefix66 = ""
        self.prefix67 = ""

    def setPref66(self):
        self.prefix66 = "66"

    def setPref67(self):
        self.prefix67 = "67"

    def setPrefG1(self):
        self.prefixG1 = "f2"

    def setPrefG2(self):
        self.prefixG2 = "f3"

    def setPrefix(self, pref_tuple):
        if pref_tuple[0]:
            self.setPref66()
        if pref_tuple[1]:
            self.setPref67()

    def __str__(self):
        if DEBUG:
            return "Prefix: " + str(self.__dict__)
        elif self.prefix66 or self.prefix67:
            return ('0' + bin(int(self.prefix67, 16))[2: ] if self.prefix67 else "") + ('0' + bin(int(self.prefix66, 16))[2: ] if self.prefix66 else "")
        return ""


class Rex:
    def __init__(self):
        self.pref = ""
        self.w = ""
        self.r = ""
        self.x = ""
        self.b = ""
        self.enabled = False

    def enable(self):
        self.enabled = True
        self.pref = '0100'
        self.w = self.r = self.x = self.b = '0'

    def __str__(self):
        if DEBUG:
            return "Rex: " + str(self.__dict__)
        if self.enabled:
            return self.pref + self.w + self.r + self.x + self.b
        return ""


class OpCode:
    def __init__(self, command_str=""):
        self.opCode_name = command_str
        self.opCode = ""
        self.D_or_S = ""
        self.W = ""

    def __str__(self):
        if DEBUG:
            return "OpCode:" + str(self.__dict__)
        return (self.opCode + self.D_or_S + self.W).replace(' ', '')


class MOD_RM:
    def __init__(self):
        self.MOD = ""
        self.RegOp = ""
        self.RM = ""

    def __str__(self):
        if DEBUG:
            return "Mod/Rm:" + str(self.__dict__)
        else:
            return self.MOD + self.RegOp + self.RM


class SIB:
    def __init__(self):
        self.scale = '0'
        self.index = '100'
        self.base = '101'
        self.enabled = False

    def __str__(self):
        if self.enabled:
            if DEBUG:
                return "Sib: " + str(self.__dict__)
            else:
                return self.scale + self.index + self.base
        return ""



class Assembler:
    def __init__(self):
        self.prefix = Prefix()
        self.rex = Rex()
        self.opcode = OpCode()
        self.mod_rm = MOD_RM()
        self.sib = SIB()
        self.displacement = Immediate(0)
        self.data = Immediate(0)
        self.operand1 = None
        self.operand2 = None
        self.operation_size = 0
        self.rex_enabled = False

    def assemble(self, code_line):  # Done
        self.operand1: Union[Memory, Register]
        self.operand2: Union[Memory, Register]
        self.parseCode(code_line)
        if self.opcode.opCode_name in single_commands:
            return single_commands[self.opcode.opCode_name]
        elif self.opcode.opCode_name in two_operand_commands:
            self.handleTwoOperandCase()
        elif self.opcode.opCode_name in single_operand_commands:
            self.handleOneOperandCase()
        else:
            raise Exception("Unknown Command!")
        if self.operation_size == 16:
            self.prefix.setPref66()
        if (isinstance(self.operand1, Memory) and self.operand1.address_size == 32) or (isinstance(self.operand2, Memory) and self.operand2.address_size == 32):
            self.prefix.setPref67()
        return self.__str__()

    def handleOneOperandCase(self):
        if self.opcode.opCode_name in {"push", "pop"}:
            return self.handlePushPop()
        self.mod_rm.RegOp = regOp[self.opcode.opCode_name]
        self.opcode.D_or_S = '1'
        if isinstance(self.operand1, Register):
            self.opcode.opCode = single_operand_commands[self.opcode.opCode_name]['r']
            self.mod_rm.MOD = '11'
            self.mod_rm.RM = self.operand1.old_code
            self.opcode.W = '0' if self.operand1.size == 8 else '1'
            if self.rex_enabled:
                self.rex.enable()
                self.rex.b = self.operand1.new_code
                self.rex.w = '1' if self.operation_size == 64 else '0'

        elif isinstance(self.operand1, Memory):
            self.opcode.opCode = single_operand_commands[self.opcode.opCode_name]['m']
            self.mod_rm.RegOp = regOp[self.opcode.opCode_name]
            self.opcode.W = '0' if self.operand1.size == 8 else '1'
            self.handleMemory(self.operand1)



    def handleTwoOperandCase(self):
        self.operand1: Union[Memory, Register]
        self.operand2: Union[Memory, Register]
        if self.opcode.opCode_name in {'shl', 'shr'}:
            return self.handleShifts()
        if self.opcode.opCode_name == "imul":
            return self.handleImul()
        if self.opcode.opCode_name in {'bsf', 'bsr'}:
            return self.handleBsfBsr()
        if isinstance(self.operand1, Register):
            if isinstance(self.operand2, Register):  # mov reg2, reg1
                self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['r,r']
                self.opcode.D_or_S = '0' if self.opcode.opCode_name != 'xchg' else '1'
                self.opcode.W = '0' if self.operand2.size == 8 else '1'
                self.mod_rm.MOD = '11'
                self.mod_rm.RegOp = self.operand2.old_code  # reg1
                self.mod_rm.RM = self.operand1.old_code  # reg2
                if self.rex_enabled:
                    self.rex.enable()
                    self.rex.w = '1' if self.operation_size == 64 else '0'
                    self.rex.r = self.operand2.new_code[0]
                    self.rex.b = self.operand1.new_code[0]
                    self.rex.x = '0'

                return

            if isinstance(self.operand2, Memory):  # mov reg, [mem]
                self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['r,m']
                self.opcode.D_or_S = '1'
                self.opcode.W = '0' if self.operand1.size == 8 else '1'
                if self.rex_enabled:
                    self.rex.r = self.operand1.new_code
                self.mod_rm.RegOp = self.operand1.old_code
                self.handleMemory(mem=self.operand2)
                return

            if isinstance(self.operand2, Immediate):  # mov reg, imm
                if self.opcode.opCode_name == "mov":
                    self.handleMovImm()
                else:
                    self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['r,i']
                    self.opcode.D_or_S = '1' if self.operand2.size == 8 and self.operand2.size < self.operand1.size else '0'
                    self.opcode.W = '0' if self.operand1.size == 8 else '1'
                    self.mod_rm.MOD = '11'
                    self.mod_rm.RM = self.operand1.old_code
                    self.mod_rm.RegOp = regOp[self.opcode.opCode_name]
                if self.rex_enabled:
                    self.rex.r = self.operand1.new_code
                if self.operand1.size == 16:
                    self.prefix.setPref66()
                self.data = Immediate(self.operand2.value, init=True)
                self.data.preferred_size = self.operand1.size
                return


        elif isinstance(self.operand1, Memory):  # operand1: Memory
            if isinstance(self.operand2, Register):  # mov [mem], reg
                self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['m,r']
                self.opcode.D_or_S = '0'
                self.opcode.W = '0' if self.operand2.size == 8 else '1'
                if self.rex_enabled:
                    self.rex.r = self.operand2.new_code
                self.mod_rm.RegOp = self.operand2.old_code
                self.handleMemory(mem=self.operand1)
                return

            if isinstance(self.operand2, Immediate):  # mov [mem], imm
                if self.opcode.opCode_name in {'shr', 'shl'}:
                    return self.handleShifts()
                self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['m,i']
                self.opcode.D_or_S = '1' if self.operand2.real_size == 8 and self.operand2.size < self.operand1.size else '0'
                self.opcode.W = '0' if self.operand1.size == 8 else '0'
                self.mod_rm.RegOp = regOp[self.opcode.opCode_name]
                self.handleMemory(self.operand1)
                self.displacement = Immediate(self.operand2.value, init=True)
                return
        else:
            raise Exception("what???!")

    def handleMemory(self, mem):  # TODO add rex
        if not mem.index and mem.base:
            self.sib.enabled = False
            self.mod_rm.RM = mem.base.old_code
            if mem.displacement:
                self.mod_rm.MOD = displacements_modes[mem.displacement.preferred_size]
                self.displacement = Immediate(mem.displacement.value, mem.displacement.preferred_size, init=True)
            elif mem.base.register_str.endswith('bp'):
                self.mod_rm.MOD = displacements_modes[8]  # [ebp] ===== [ebp+0]
                self.displacement = Immediate(0, preferred_size=8, init=True)
            else:
                self.mod_rm.MOD = displacements_modes[None]
            if self.rex.enabled:
                self.rex.b = mem.base.new_code

        else:
            self.sib.enabled = True
            self.mod_rm.RM = '100'
            if mem.direct_addressing:
                self.mod_rm.MOD = '00'
                self.sib.base = reg_code['rbp'][1:]
                self.displacement = Immediate(mem.displacement.value, init=True)
                if self.displacement.real_size == 16:
                    self.displacement.preferred_size = 32
                if self.rex.enabled:
                    self.rex.b = '0'
                    self.rex.x = '0'
                return

            self.sib.index = mem.index.old_code
            self.sib.scale = scales[mem.scale]
            if self.rex.enabled:
                self.rex.x = mem.index.new_code

            ############################################
            if not mem.base:
                self.mod_rm.MOD = '00'
                self.mod_rm.RM = '100'
                self.sib.base = reg_code['rbp'][1:]
                if mem.displacement:
                    self.displacement = Immediate(mem.displacement.value, 32, init=True)
                else:
                    self.displacement = Immediate(0, 32, init=True)

            if mem.base:
                self.sib.base = mem.base.old_code
                if mem.base.register_str.endswith('bp'):
                    if not mem.displacement:
                        self.displacement = Immediate(0, preferred_size=8, init=True)
                    else:
                        self.displacement = Immediate(mem.displacement.value, init=True)
                        if self.displacement.real_size > 8:
                            self.displacement.preferred_size = 32

                    self.mod_rm.MOD = displacements_modes[self.displacement.preferred_size]

                else:
                    if mem.displacement:
                        self.displacement = Immediate(mem.displacement.value, init=True)
                        if self.displacement.real_size == 16:
                            self.displacement.preferred_size = 32
                        self.mod_rm.MOD = displacements_modes[self.displacement.preferred_size]
                    else:
                        self.mod_rm.MOD = displacements_modes[None]
                if self.rex.enabled:
                    self.rex.b = mem.base.new_code

    def parseCode(self, code_line):
        point1 = code_line.find(' ')
        if point1 == -1:
            self.opcode.opCode_name = code_line.strip()
            return
        self.opcode.opCode_name = code_line[:point1].strip()
        rest = code_line[point1 + 1:]
        point2 = rest.find(",")
        if point2 == -1:
            self.operand1 = self.getAppropriateOperand(rest)
            if self.opcode.opCode_name in {'shr', 'shl'}:
                self.operand2 = Immediate(1, init=True)
            self.operation_size = self.operand1.size
        else:
            self.operand1 = self.getAppropriateOperand(rest[:point2])
            self.operand2 = self.getAppropriateOperand(rest[point2 + 1:])
            self.operation_size = max(self.operand1.size, self.operand2.size)

        self.rex_enabled = self.rex_enabled or self.operation_size == 64
        if self.rex_enabled:
            self.rex.enable()
        self.rex.w = '1' if self.operation_size == 64 else '0'

    def getAppropriateOperand(self, operand_str):
        operand_str = operand_str.strip()
        if operand_str.endswith(']'):
            operand = Memory(operand_str)
            self.rex_enabled = self.rex_enabled or operand.uses_new_registers
            return operand
        if operand_str[0].isdigit():
            return Immediate(int(operand_str[2:], 16), init=True) if operand_str.startswith('0x') else Immediate(int(operand_str), init=True)
        operand = Register(operand_str)
        self.rex_enabled = self.rex_enabled or operand.is_new
        return operand

    def handleShifts(self):
        self.opcode.D_or_S = '0'
        self.opcode.W = '0' if self.operand1.size == 8 else '1'
        self.mod_rm.RegOp = regOp[self.opcode.opCode_name]
        if self.operand2.value == 1:
            self.opcode.opCode = two_operand_commands[self.opcode.opCode_name][1]
        else:
            self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['i']
            self.displacement = Immediate(self.operand2.value, init=True)
        if isinstance(self.operand1, Memory):
            self.handleMemory(self.operand1)
        else:
            self.operand1: Register
            self.mod_rm.MOD = '11'
            self.mod_rm.RM = self.operand1.old_code
            if self.operand1.is_new:
                self.rex.enable()
                self.rex.b = self.operand1.new_code
                self.rex.w = '1' if self.operand1.size == 64 else '0'

    def handlePushPop(self):
        if isinstance(self.operand1, Register):
            self.opcode.opCode = single_operand_commands[self.opcode.opCode_name]['r']
            self.mod_rm.RegOp = self.operand1.old_code
            if self.operand1.is_new and self.rex_enabled:
                self.rex.w = '0'
            else:
                self.rex_enabled = False
                self.rex.enabled = False
            if self.operand1.size == 16:
                self.prefix.setPref66()
        elif isinstance(self.operand1, Memory):
            self.opcode.W = '0' if self.operand1.size == 8 else '1'
            self.opcode.opCode = single_operand_commands[self.opcode.opCode_name]['m']
            self.opcode.D_or_S = '1'
            self.mod_rm.RegOp = regOp[self.opcode.opCode_name]
            self.handleMemory(self.operand1)
        else:  # imm (push)
            self.opcode.opCode = single_operand_commands[self.opcode.opCode_name]['i']
            self.opcode.W = '0'
            self.opcode.D_or_S = '1' if self.operand1.size == 8 else '0'
            self.mod_rm.RegOp = regOp[self.opcode.opCode_name]
            self.data = Immediate(self.operand1.value)

    def handleImul(self):
        if isinstance(self.operand2, Register): # imul reg, reg
            self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['r,r']
            self.opcode.D_or_S = self.opcode.W = '1'
            self.mod_rm.MOD = '11'
            self.mod_rm.RegOp = self.operand1.old_code
            self.mod_rm.RM = self.operand2.old_code
            if self.rex_enabled:
                self.rex.r = self.operand1.new_code
                self.rex.b = self.operand2.new_code
                self.rex.w = '1' if self.operand1.size == 64 else '0'

        elif isinstance(self.operand2, Memory): # imul reg, [mem]
            self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['r,m']
            self.opcode.D_or_S = self.opcode.W = '1'
            self.mod_rm.RegOp = self.operand1.old_code
            self.handleMemory(self.operand2)
            if self.rex_enabled:
                self.rex.r = self.operand1.new_code
                self.rex.w = '1' if self.operand1.size == 64 else '0'


    def handleMovImm(self):
        if self.operand1.size == 64:
            self.opcode.opCode = '1100 01'
            self.opcode.D_or_S = '1'
            self.opcode.W = '1'
            self.mod_rm.MOD = '11'
            self.mod_rm.RegOp = '000'
            self.mod_rm.RM = self.operand1.old_code
        else:
            self.opcode.opCode = '1011'
            self.opcode.W = '0' if self.operand1.size == 8 else '1'
            self.mod_rm.RM = self.operand1.old_code

    def handleBsfBsr(self):
        if isinstance(self.operand2, Register):  # bsf/bsr reg, reg
            self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['r,r']
            self.mod_rm.MOD = '11'
            self.mod_rm.RegOp = self.operand1.old_code
            self.mod_rm.RM = self.operand2.old_code
            if self.rex_enabled:
                self.rex.b = self.operand2.new_code
                self.rex.r = self.operand1.new_code
                self.rex.w = '1' if self.operand1.size == 64 else '0'


        elif isinstance(self.operand2, Memory):
            self.opcode.opCode = two_operand_commands[self.opcode.opCode_name]['m,r']
            self.mod_rm.RegOp = self.operand1.old_code
            self.handleMemory(self.operand2)
            if self.rex_enabled:
                self.rex.r = self.operand1.new_code
                self.rex.w = '1' if self.operand1.size == 64 else '0'


    def __str__(self):
        delimiter = '\n' if DEBUG else ''
        title = 'Assembler' if DEBUG else ''
        in_bin = title + delimiter.join(map(str, [self.prefix, self.rex, self.opcode, self.mod_rm, self.sib, self.displacement, self.data]))
        if DEBUG:
            return in_bin
        else:
            in_hex_raw = hex(int(in_bin, 2))[2: ]
            result = '0' * (len(in_bin)//4 - len(in_hex_raw)) + in_hex_raw
            return result


if __name__ == "__main__":
    # DEBUG = True
    assembler = Assembler()
    inp = input()

    print(assembler.assemble(inp.strip().lower()), end='')
    # DEBUG = False
    # print()
    # print(assembler.__str__())
