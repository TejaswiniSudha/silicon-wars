# Experiment 2: Instruction Encoding (x86-64 Machine Code)

## 1. Goal
Assemble a small x86-64 assembly program using the GNU Assembler (`as`) and disassemble it with `objdump` to inspect and decode raw variable-length machine code bytes—specifically opcodes, ModR/M bytes, REX prefixes, and immediate operands.

## 2. COA Concepts
- **Machine Code:** Raw binary/hexadecimal bytes directly fetched and decoded by the CPU front-end.
- **Variable-Length Encoding:** Unlike fixed-width RISC ISAs (4 bytes per instruction), x86-64 instructions range from 1 to 15 bytes.
- **Opcode:** The core byte(s) specifying the operation (e.g., `0x01` for `ADD`, `0xC3` for `RET`).
- **ModR/M Byte:** A 1-byte field (`Mod [2 bits] | Reg [3 bits] | R/M [3 bits]`) encoding addressing mode and register operands.
- **REX Prefix:** A 1-byte prefix (`0x48` = REX.W) that promotes 32-bit x86 instructions to 64-bit operand size.
- **Little-Endian Immediate:** Multi-byte constants are stored with the least significant byte at the lowest memory address.

## 3. Method
1. Wrote four representative x86-64 instructions in `encoding.s`:
   - `add eax, ebx` (32-bit register-to-register addition)
   - `add rax, rbx` (64-bit register-to-register addition)
   - `mov eax, 5` (32-bit immediate load)
   - `ret` (near return)
2. Assembled `encoding.s` into an ELF64 object file (`encoding.o`) using `as`.
3. Disassembled `encoding.o` in Intel syntax using `objdump -d -M intel` to inspect the exact byte offsets and hexadecimal encoding.
4. Decoded each byte into its architectural fields and recorded the breakdown in `results.csv`.

## 4. Commands

    # Assemble into an object file
    as encoding.s -o encoding.o

    # Disassemble and display raw machine code bytes
    objdump -d -M intel encoding.o

## 5. Results
Actual `objdump` output on x86-64 (WSL2 Ubuntu):

    0000000000000000 <_start>:
       0:   01 d8                   add    eax,ebx
       2:   48 01 d8                add    rax,rbx
       5:   b8 05 00 00 00          mov    eax,0x5
       a:   c3                      ret

Total size of all 4 instructions: **11 bytes**. Structured data is saved in `results.csv`.

## 6. Decoded Byte Table

| Instruction | Hex Bytes | Length | REX Prefix | Opcode | ModR/M | Immediate | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `add eax, ebx` | `01 d8` | 2 bytes | None | `01` | `d8` | None | `0xd8` = `11 011 000` (Mod=reg, Reg=`ebx`, R/M=`eax`) |
| `add rax, rbx` | `48 01 d8` | 3 bytes | `48` | `01` | `d8` | None | REX.W (`0x48`) promotes 32-bit `add` to 64-bit |
| `mov eax, 5` | `b8 05 00 00 00` | 5 bytes | None | `b8` | None | `05 00 00 00` | Register baked into opcode; Little-Endian immediate `5` |
| `ret` | `c3` | 1 byte | None | `c3` | None | None | Single-byte near return |

## 7. Explanation of Results
- **Variable-Length Encoding:** The four instructions occupy 2, 3, 5, and 1 bytes respectively, showing how x86-64 trades decoder simplicity for code density.
- **Backward Compatibility via REX:** `add rax, rbx` (`48 01 d8`) reuses the exact same opcode and ModR/M byte as `add eax, ebx` (`01 d8`), simply prepending the `0x48` REX.W prefix to widen the operation to 64 bits.
- **Compact Immediate Encoding:** `mov eax, 5` encodes the destination register (`eax`) directly inside the `0xb8` opcode, avoiding a ModR/M byte, followed by the 4-byte Little-Endian value `05 00 00 00`.

## 8. Limitations
- This experiment inspects static instruction encoding in an unlinked object file (`encoding.o`) rather than executing the instructions.
- Advanced x86-64 encodings (such as SIB bytes for complex memory addressing, memory displacements, and VEX/EVEX prefixes used by AVX2) are not covered in this minimal 4-instruction sample.
