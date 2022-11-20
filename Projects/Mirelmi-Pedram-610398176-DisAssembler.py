DEBUG = False

reg_code = {
    "0000": ("al", "ax", "eax", "rax"),
    "0001": ("cl", "cx", "ecx", "rcx"),
    "0010": ("dl", "dx", "edx", "rdx"),
    "0011": ("bl", "bx", "ebx", "rbx"),
    "0100": ("ah", "sp", "esp", "rsp"),
    "0101": ("ch", "bp", "ebp", "rbp"),
    "0110": ("dh", "si", "esi", "rsi"),
    "0111": ("bh", "di", "edi", "rdi"),


    "1000": ("r8b", "r8w", "r8d", "r8"),
    "1001": ("r9b", "r9w", "r9d", "r9"),
    "1010": ("r10b", "r10w", "r10d", "r10"),
    "1011": ("r11b", "r11w", "r11d", "r11"),
    "1100": ("r12b", "r12w", "r12d", "r12"),
    "1101": ("r13b", "r13w", "r13d", "r13"),
    "1110": ("r14b", "r14w", "r14d", "r14"),
    "1111": ("r15b", "r15w", "r15d", "r15")
}

sett = {
    1: 1,
    1: 1
}


two_op_no_imm = {
    "100010": {"mov"},
    "000000": {"add"},
    "000100": {"adc"},
    "001010": {"sub"},
    "000110": {"sbb"},
    "001000": {"and"},
    "000010": {"or"},
    "001100": {"xor"},
    "001110": {"cmp"},
}

two_op_with_imm = {
    "110001": {"mov"}, # mem
    "1011": {"mov"}, # reg
    "100000": {"add", "adc", "sub", "sbb", "and", "or", "xor", "cmp"},
    "111101": {"test"},
    "110100": {"shl", "shr"},
    "110000": {"shl", "shr"}
}

one_operands = {
    "111101": {"neg", "not", "idiv", "imul"},
    "111111": {"inc", "dec", "push"},
    "100011": {"pop"},

}

one_op_with_imm = {
    "011010": {"push"},
}

long_opcode_prefix = "0f"

exception_opcodes = {
    "110000": {"xadd"},
    "101111": {"bsf", "bsr"},
    "101011": {"imul"},
    "100001": {"test", "xchg"},
}

regOp_codes = {  # when we have some part of opcode in regOp field
    '000': {"add", "pop", "inc", "mov", "test"},
    '010': {"adc", "not", },
    '101': {"sub", "shr", "imul"},
    '011': {"sbb", "neg"},
    '100': {"and", "shl"},
    '001': {"or", "dec"},
    '110': {"xor", "push"},
    '111': {"cmp", "idiv"},
}

size_index = {
    8: 0,
    16: 1,
    32: 2,
    64: 3
}


scales = {
    '00': 1,
    '01': 2,
    '10': 4,
    '11': 8
}

single_commands = {
    "f9": "stc",
    "f8": "clc",
    "fd": "std",
    "fc": "cld",
    "0f05": "syscall",
    "c3": "ret"
}


sizes = {
    8: "BYTE",
    16: "WORD",
    32: "DWORD",
    64: "QWORD",
}



def convertSingleHexToBin(single_hex):
    in_bin = bin(int(single_hex, 16))[2:]
    return '0' * (4 - len(in_bin)) + in_bin


def convertHexToBin(hex_code):
    return ''.join(map(convertSingleHexToBin, hex_code))


class Immediate:
    def __init__(self, hex_value: str, init=False):
        if init:
            self.__setValue(hex_value)

    def __setValue(self, hex_value: str):
        result = ""
        for i in range(0, len(hex_value), 2):
            result = hex_value[i: i+2] + result
        self.value = int(result, 16)

    def __str__(self):
        return hex(self.value)


class Prefix:
    def __init__(self):
        self.prefix66 = False
        self.prefix67 = False

    def __str__(self):
        return "Prefix: " + str(self.__dict__)


class Rex:
    def __init__(self):
        self.w = ""
        self.r = ""
        self.x = ""
        self.b = ""
        self.enabled = False

    def enable(self, hex_code):
        self.enabled = True
        self.w, self.r, self.x, self.b = convertSingleHexToBin(hex_code)

    def __str__(self):
        return "Rex: " + str(self.__dict__)


class OpCode:
    def __init__(self):
        self.opCode_name = ""
        self.opCode = ""
        self.D_or_S = ""
        self.W = ""

    def doInit(self, hex_code):
        in_bin = convertHexToBin(hex_code)
        self.opCode = in_bin[: 6]
        self.D_or_S = in_bin[6]
        self.W = in_bin[7]

    def __str__(self):
        return "OpCode:" + str(self.__dict__)


class MOD_RM:
    def __init__(self):
        self.MOD = ""
        self.RegOp = ""
        self.RM = ""

    def doInit(self, hex_code):
        in_bin = convertHexToBin(hex_code)
        self.MOD = in_bin[:2]
        self.RegOp = in_bin[2: 5]
        self.RM = in_bin[5:]

    def __str__(self):
        return "Mod/Rm:" + str(self.__dict__)


class SIB:
    def __init__(self):
        self.scale_code = ''
        self.index_code = ''
        self.base_code = ''
        self.enabled = False

    def enable(self, hex_code):
        self.enabled = True
        in_bin = convertHexToBin(hex_code)
        self.scale_code = in_bin[:2]
        self.index_code = in_bin[2: 5]
        self.base_code = in_bin[5:]

    def __str__(self):
        return "Sib: " + str(self.__dict__)


class Register:
    def __init__(self, reg_str: str):
        self.register_str = reg_str

    def __repr__(self):
        return self.register_str

    def __str__(self):
        return self.register_str


class Memory:
    def __init__(self, prefix67: bool, size: int):
        self.prefix67 = prefix67
        self.size = size
        self.address_size = 32 if self.prefix67 else 64
        self.base_name = None
        self.index_digit = None
        self.scale_digit = None
        self.displacement = None


    def __str__(self):
        result = f'{sizes[self.size]} PTR ['
        if self.base_name:
            result += self.base_name
            if self.index_digit or self.displacement:
                result += '+'
        if self.index_digit:
            result += f"{self.index_digit}*{self.scale_digit}"
            if self.displacement:
                result += '+'
        if self.displacement:
            result += hex(self.displacement.value)
        return result + ']'


class DisAssembler:
    def __init__(self):
        self.prefix = Prefix()
        self.rex = Rex()
        self.opcode = OpCode()
        self.mod_rm = MOD_RM()
        self.sib = SIB()
        self.displacement = None
        self.data = None
        self.operand1 = None
        self.operand2 = None
        self.operation_size = 0
        self.memory = None
        self.regOp_reg = None
        self.rm_reg = None
        self.hasLongOpcode = False

    def disassemble(self, machine_code: str):
        self.parseCode(machine_code)
        if self.opcode.opCode in single_commands:
            return

        if self.prefix.prefix66:
            self.operation_size = 16
        elif self.rex.enabled and self.rex.w == '1':
            self.operation_size = 64
        elif self.opcode.W == '0':
            self.operation_size = 8
        self.operation_size = 32 if self.operation_size == 0 else self.operation_size
        if self.prefix.prefix67 or self.mod_rm.MOD != '11':
            self.handleMemory()

        if self.hasLongOpcode:
            self.handleExceptionOpCodes()
            return

        if self.data or self.thereIsShift():
            if self.opcode.opCode[: 4] in two_op_with_imm: # we have move!
                self.handleMovImm()
                return
            self.opcode.opCode_name = list(two_op_with_imm[self.opcode.opCode].intersection(regOp_codes[self.mod_rm.RegOp]))[0]
            if self.memory:
                self.operand1 = self.memory
                self.operand2 = self.data
            else:
                if self.opcode.opCode_name in {"shr", "shl"} and self.opcode.opCode[3] == '1':
                    self.data = 1
                self.getRegisterFromRm()
                self.operand1 = self.rm_reg
                self.operand2 = self.data
        elif self.opcode.opCode in exception_opcodes:
            self.handleExceptionOpCodes()
        elif self.memory and self.opcode.opCode in two_op_no_imm:
            self.getRegisterFromRegOp()
            self.operand2 = self.regOp_reg
            self.operand1 = self.memory
            self.opcode.opCode_name = list(two_op_no_imm[self.opcode.opCode])[0]
            if self.opcode.D_or_S == '1':
                self.operand1, self.operand2 = self.operand2, self.operand1
        elif self.memory and self.opcode.opCode in one_operands:
            self.opcode.opCode_name = list(one_operands[self.opcode.opCode].intersection(regOp_codes[self.mod_rm.RegOp]))[0]
            self.operand1 = self.memory
        elif self.opcode.opCode in two_op_no_imm:
            self.opcode.opCode_name = list(two_op_no_imm[self.opcode.opCode])[0]
            self.getRegisterFromRegOp()
            self.getRegisterFromRm()
            self.operand1 = self.rm_reg
            self.operand2 = self.regOp_reg
        elif self.opcode.opCode in one_operands:
            self.opcode.opCode_name = list(one_operands[self.opcode.opCode].intersection(regOp_codes[self.mod_rm.RegOp]))[0]
            self.getRegisterFromRm()
            self.operand1 = self.rm_reg


    def parseCode(self, machine_code: str):
        if machine_code in single_commands:
            self.opcode.opCode = machine_code
            self.opcode.opCode_name = single_commands[machine_code]
            return

        if machine_code.startswith('67'):
            self.prefix.prefix67 = True
            machine_code = machine_code[2:]
        if machine_code.startswith('66'):
            self.prefix.prefix66 = True
            machine_code = machine_code[2:]
        if machine_code.startswith('4'):
            self.rex.enable(machine_code[1])
            machine_code = machine_code[2:]

        if machine_code.startswith(long_opcode_prefix):
            self.hasLongOpcode = True
            machine_code = machine_code[2: ]

        self.opcode.doInit(machine_code[:2])
        machine_code = machine_code[2: ]

        self.mod_rm.doInit(machine_code[:2])
        machine_code = machine_code[2: ]

        if self.mod_rm.RM == '100':
            self.sib.enable(machine_code[:2])
            machine_code = machine_code[2: ]
        if self.mod_rm.MOD == '10' or (self.mod_rm.MOD == '00' and self.sib.enabled and self.sib.base_code == '101'):
            self.displacement = Immediate(machine_code[ :8], init=True)
            machine_code = machine_code[8: ]
        if self.mod_rm.MOD == '01':
            self.displacement = Immediate(machine_code[ :2], init=True)
            machine_code = machine_code[2: ]
        if machine_code:
            self.data = Immediate(machine_code, init=True)

    def handleMemory(self):
        if not self.memory:
            self.memory = Memory(self.prefix.prefix67, self.operation_size)
        base_new_code = self.rex.b if self.rex.enabled else '0'
        index_new_code = self.rex.x if self.rex.enabled else '0'
        if self.sib.enabled:
            if not (self.mod_rm.MOD == '00' and self.sib.base_code == '101'): # base
                self.memory.base_name = reg_code[base_new_code + self.sib.base_code][size_index[self.memory.address_size]]
            if not (self.sib.index_code == '100') or (self.rex.enabled and self.rex.x == '1'):
                self.memory.index_digit = reg_code[index_new_code + self.sib.index_code][size_index[self.memory.address_size]]
                self.memory.scale_digit = scales[self.sib.scale_code]
            if self.displacement and (self.displacement.value or self.sib.base_code == '101'):
                self.memory.displacement = self.displacement
        else:
            self.memory.base_name =  reg_code[base_new_code + self.mod_rm.RM][size_index[self.memory.address_size]]
            if self.displacement:
                self.memory.displacement = self.displacement

    def getRegisterFromRm(self):
        new_code = self.rex.b if self.rex.enabled else '0'
        self.rm_reg = Register(reg_code[new_code + self.mod_rm.RM][size_index[self.operation_size]])

    def getRegisterFromRegOp(self):
        new_code = self.rex.r if self.rex.enabled else '0'
        self.regOp_reg = Register(reg_code[new_code + self.mod_rm.RegOp][size_index[self.operation_size]])


    def handleExceptionOpCodes(self):
        if self.memory:
            self.getRegisterFromRegOp()
            if 'xadd' in exception_opcodes[self.opcode.opCode]:
                self.operand1 = self.memory
                self.operand2 = self.regOp_reg
                self.opcode.opCode_name = 'xadd'
            else:
                self.operand1 = self.regOp_reg
                self.operand2 = self.memory
                if 'bsf' in exception_opcodes[self.opcode.opCode]:
                    self.opcode.opCode_name = 'bsf' if self.opcode.W == '0' else 'bsr'
                elif 'xchg' in exception_opcodes[self.opcode.opCode]:
                    self.opcode.opCode_name = 'xchg' if self.opcode.D_or_S == '1' else 'test'
                    self.operand1, self.operand2 = self.operand2, self.operand1
                else:
                    self.opcode.opCode_name = 'imul'
        else:
            self.getRegisterFromRegOp()
            self.getRegisterFromRm()
            if 'xadd' in exception_opcodes[self.opcode.opCode]:
                self.operand1 = self.rm_reg
                self.operand2 = self.regOp_reg
                self.opcode.opCode_name = 'xadd'
            else:
                self.operand1 = self.regOp_reg
                self.operand2 = self.rm_reg
                if 'bsf' in exception_opcodes[self.opcode.opCode]:
                    self.opcode.opCode_name = 'bsf' if self.opcode.W == '0' else 'bsr'
                elif 'xchg' in exception_opcodes[self.opcode.opCode]:
                    self.opcode.opCode_name = 'xchg' if self.opcode.D_or_S == '1' else 'test'
                    self.operand1, self.operand2 = self.operand2, self.operand1

                else:
                    self.opcode.opCode_name = 'imul'


    def handleMovImm(self):
        if self.operation_size == 8:
            self.operation_size = 32
        self.opcode.opCode_name = "mov"
        self.operand2 = self.data
        new_code = self.rex.b if self.rex.enabled else '0'
        self.operand1 = Register(reg_code[new_code + self.opcode.opCode[-1]+self.opcode.D_or_S+self.opcode.W][size_index[self.operation_size]])
        return

    def thereIsShift(self):
        try:
            return list(two_op_with_imm[self.opcode.opCode].intersection(regOp_codes[self.mod_rm.RegOp]))[0] in {"shr", "shl"}
        except:
            return False

    def __str__(self):
        info = '\n'.join(
            map(str, [self.prefix, self.rex, self.opcode, self.mod_rm, self.sib, self.displacement, self.data]))
        if self.operand1 and self.operand2:
            assembly = f"{self.opcode.opCode_name} {self.operand1},{self.operand2}"
        elif self.operand1:
            assembly = f"{self.opcode.opCode_name} {self.operand1}"
        else:
            assembly = self.opcode.opCode_name
        if DEBUG:
            return info + '\n\n\n' + assembly
        else:
            return assembly



if __name__ == "__main__":
    DEBUG = False
    disassembler = DisAssembler()
    inp = input().lower().strip()
    disassembler.disassemble(inp)
    # print(disassembler.__str__())
    print(disassembler.__str__())
