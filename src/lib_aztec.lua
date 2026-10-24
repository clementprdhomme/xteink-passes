--[==[
Aztec 2D barcode encoder

Copyright 2013 ZXing authors (Encoder.java, BinaryShiftToken.java)
Copyright 2008 ZXing authors (ReedSolomonEncoder.java)
Copyright 2007 ZXing authors (GenericGF.java)
Lua port and modifications Copyright 2026 Clément Prod'homme

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

This file is a Lua port of the following ZXing files (https://github.com/zxing/zxing):
- core/src/main/java/com/google/zxing/aztec/encoder/Encoder.java
- core/src/main/java/com/google/zxing/aztec/encoder/BinaryShiftToken.java
- core/src/main/java/com/google/zxing/common/reedsolomon/ReedSolomonEncoder.java
- core/src/main/java/com/google/zxing/common/reedsolomon/GenericGF.java

Changes made to the original files:
- Translated from Java to Lua 5.5 (32-bit integers). BitArray and BitMatrix are replaced by plain Lua
  tables, and the loops that modify their own counter (stuffBits) are rewritten as while loops.
- The HighLevelEncoder is not ported. The whole input is always encoded as a single Binary Shift (byte
  mode) segment, following BinaryShiftToken.appendTo. This produces valid but larger symbols than ZXing
  for text input, in exchange for a much cheaper encoding on low-power devices.
- No ECI support: the charset parameter is removed and the input bytes are encoded as they are.
- Only the automatic size selection is kept, with the default error correction (33%). The
  minECCPercent and userSpecifiedLayers parameters are removed.
- The Reed-Solomon remainder is computed with a shift-register loop over the log/exp tables instead of
  GenericGFPoly objects. The resulting check words are the same.
- Errors are returned as `nil, err` ("invalid_argument" or "limit_exceeded") instead of exceptions.
- The result is a table of rows of booleans (`matrix[y][x]`, 1-based, true for a dark module) and the
  size of the symbol, instead of an AztecCode object.

Full text of the License:


                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "[]"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright [yyyy] [name of copyright owner]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]==]

local EC_PERCENT = 33 -- minimal percentage of error check words
local MAX_NB_BITS = 32
local MAX_BINARY_SHIFT_BYTES = 2047 + 31 -- the 11-bit length of a long Binary Shift is stored minus 31

-- word size in bits, by number of layers
local WORD_SIZE = {
  [0] = 4, 6, 6, 8, 8, 8, 8, 8, 8, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
  12, 12, 12, 12, 12, 12, 12, 12, 12, 12
}

-- primitive polynomial of the Galois field, by word size
local PRIMITIVES = {
  [4] = 0x13,    -- x^4 + x + 1
  [6] = 0x43,    -- x^6 + x + 1
  [8] = 0x12D,   -- x^8 + x^5 + x^3 + x^2 + 1
  [10] = 0x409,  -- x^10 + x^3 + 1
  [12] = 0x1069, -- x^12 + x^6 + x^5 + x^3 + 1
}

local fields = {} -- Galois fields already built, by word size

-- bit arrays: { size = n, [1..n] = 0 or 1 }, most significant bit first
local function new_bits()
  return { size = 0 }
end

local function append_bits(bits, value, count)
  for i = count - 1, 0, -1 do
    bits.size = bits.size + 1
    bits[bits.size] = (value >> i) & 1
  end
end

-- 0-based, like BitArray.get
local function get_bit(bits, i)
  return bits[i + 1] == 1
end

-- build the exp/log tables of the Galois field (generator base 1)
local function get_field(word_size)
  local field = fields[word_size]
  if field then
    return field
  end

  local size = 1 << word_size
  local order = size - 1
  local exp = {}
  local log = {}
  local x = 1
  for i = 0, size - 1 do
    exp[i] = x
    x = x * 2 -- 2 (the polynomial x) is a primitive element
    if x >= size then
      x = (x ~ PRIMITIVES[word_size]) & (size - 1)
    end
  end
  -- repeat the table so that exp[log[a] + log[b]] needs no modulo
  for i = size, 2 * order do
    exp[i] = exp[i - order]
  end
  for i = 0, size - 2 do
    log[exp[i]] = i
  end

  field = { order = order, exp = exp, log = log }
  fields[word_size] = field
  return field
end

-- replace the last ec_words of words (0-based) with the Reed-Solomon check words
local function reed_solomon_encode(field, words, total_words, ec_words)
  local exp, log, order = field.exp, field.log, field.order
  local data_words = total_words - ec_words

  -- generator polynomial: product of (x + a^d) for d = 1..ec_words, highest degree first
  local generator = { 1 }
  for d = 1, ec_words do
    local root = exp[d % order]
    local next_generator = {}
    for i = 1, d + 1 do
      local value = generator[i] or 0
      local previous = generator[i - 1]
      if previous and previous ~= 0 then
        value = value ~ exp[log[previous] + log[root]]
      end
      next_generator[i] = value
    end
    generator = next_generator
  end

  -- log of the generator coefficients, without the leading 1 (nil for a zero coefficient)
  local generator_log = {}
  for i = 1, ec_words do
    local coefficient = generator[i + 1]
    generator_log[i] = coefficient ~= 0 and log[coefficient] or nil
  end

  -- remainder of words(x) * x^ec_words divided by the generator
  local remainder = {}
  for i = 1, ec_words do
    remainder[i] = 0
  end
  for i = 0, data_words - 1 do
    local factor = words[i] ~ remainder[1]
    if factor == 0 then
      for j = 1, ec_words - 1 do
        remainder[j] = remainder[j + 1]
      end
      remainder[ec_words] = 0
    else
      local factor_log = log[factor]
      for j = 1, ec_words do
        local value = remainder[j + 1] or 0
        local coefficient_log = generator_log[j]
        if coefficient_log then
          value = value ~ exp[factor_log + coefficient_log]
        end
        remainder[j] = value
      end
    end
  end

  for i = 1, ec_words do
    words[data_words + i - 1] = remainder[i]
  end
end

local function generate_check_words(bits, total_bits, word_size)
  -- bits is guaranteed to be a multiple of the word size, so no padding needed
  local message_size_in_words = bits.size // word_size
  local total_words = total_bits // word_size

  local words = {}
  for i = 0, total_words - 1 do
    local value = 0
    if i < message_size_in_words then
      for j = 0, word_size - 1 do
        if get_bit(bits, i * word_size + j) then
          value = value | (1 << (word_size - j - 1))
        end
      end
    end
    words[i] = value
  end

  reed_solomon_encode(get_field(word_size), words, total_words, total_words - message_size_in_words)

  local message_bits = new_bits()
  append_bits(message_bits, 0, total_bits % word_size)
  for i = 0, total_words - 1 do
    append_bits(message_bits, words[i], word_size)
  end
  return message_bits
end

local function stuff_bits(bits, word_size)
  local out = new_bits()
  local n = bits.size
  local mask = (1 << word_size) - 2
  local i = 0
  while i < n do
    local word = 0
    for j = 0, word_size - 1 do
      if i + j >= n or get_bit(bits, i + j) then
        word = word | (1 << (word_size - 1 - j))
      end
    end
    if (word & mask) == mask then
      append_bits(out, word & mask, word_size)
      i = i + word_size - 1
    elseif (word & mask) == 0 then
      append_bits(out, word | 1, word_size)
      i = i + word_size - 1
    else
      append_bits(out, word, word_size)
      i = i + word_size
    end
  end
  return out
end

local function get_total_bits_in_layer(layers, compact)
  return ((compact and 88 or 112) + 16 * layers) * layers
end

-- encode every byte of data in a single Binary Shift segment
local function encode_binary_shift(data)
  local bits = new_bits()
  local count = #data
  for i = 0, count - 1 do
    if i == 0 or (i == 31 and count <= 62) then
      -- we need a header before the first character, and before character 31 when the total byte
      -- count is <= 62
      append_bits(bits, 31, 5) -- BINARY_SHIFT
      if count > 62 then
        append_bits(bits, count - 31, 16)
      elseif i == 0 then
        -- 1 <= count <= 62
        append_bits(bits, math.min(count, 31), 5)
      else
        -- 32 <= count <= 62 and i == 31
        append_bits(bits, count - 31, 5)
      end
    end
    append_bits(bits, string.byte(data, i + 1), 8)
  end
  return bits
end

local function generate_mode_message(compact, layers, message_size_in_words)
  local mode_message = new_bits()
  if compact then
    append_bits(mode_message, layers - 1, 2)
    append_bits(mode_message, message_size_in_words - 1, 6)
    return generate_check_words(mode_message, 28, 4)
  end
  append_bits(mode_message, layers - 1, 5)
  append_bits(mode_message, message_size_in_words - 1, 11)
  return generate_check_words(mode_message, 40, 4)
end

local function draw_mode_message(set, compact, matrix_size, mode_message)
  local center = matrix_size // 2
  if compact then
    for i = 0, 6 do
      local offset = center - 3 + i
      if get_bit(mode_message, i) then
        set(offset, center - 5)
      end
      if get_bit(mode_message, i + 7) then
        set(center + 5, offset)
      end
      if get_bit(mode_message, 20 - i) then
        set(offset, center + 5)
      end
      if get_bit(mode_message, 27 - i) then
        set(center - 5, offset)
      end
    end
  else
    for i = 0, 9 do
      local offset = center - 5 + i + i // 5
      if get_bit(mode_message, i) then
        set(offset, center - 7)
      end
      if get_bit(mode_message, i + 10) then
        set(center + 7, offset)
      end
      if get_bit(mode_message, 29 - i) then
        set(offset, center + 7)
      end
      if get_bit(mode_message, 39 - i) then
        set(center - 7, offset)
      end
    end
  end
end

local function draw_bulls_eye(set, center, size)
  for i = 0, size - 1, 2 do
    for j = center - i, center + i do
      set(j, center - i)
      set(j, center + i)
      set(center - i, j)
      set(center + i, j)
    end
  end
  set(center - size, center - size)
  set(center - size + 1, center - size)
  set(center - size, center - size + 1)
  set(center + size, center - size)
  set(center + size, center - size + 1)
  set(center + size, center + size - 1)
end

-- encode a string of bytes; returns matrix, size or nil, err
local function encode(data)
  if type(data) ~= "string" or #data == 0 then
    return nil, "invalid_argument"
  end
  if #data > MAX_BINARY_SHIFT_BYTES then
    return nil, "limit_exceeded"
  end

  local bits = encode_binary_shift(data)

  -- stuff bits and choose symbol size
  local ecc_bits = bits.size * EC_PERCENT // 100 + 11
  local total_size_bits = bits.size + ecc_bits
  local compact
  local layers
  local total_bits_in_layer
  local word_size = 0
  local stuffed_bits = nil
  -- we look at the possible table sizes in the order Compact1, Compact2, Compact3, Compact4, Normal4,...
  -- Normal(i) for i < 4 isn't typically used since Compact(i+1) is the same size, but has more data
  local i = 0
  while true do
    if i > MAX_NB_BITS then
      return nil, "limit_exceeded"
    end
    compact = i <= 3
    layers = compact and i + 1 or i
    total_bits_in_layer = get_total_bits_in_layer(layers, compact)
    if total_size_bits <= total_bits_in_layer then
      -- [re]stuff the bits if this is the first opportunity, or if the word size has changed
      if stuffed_bits == nil or word_size ~= WORD_SIZE[layers] then
        word_size = WORD_SIZE[layers]
        stuffed_bits = stuff_bits(bits, word_size)
      end
      local usable_bits_in_layers = total_bits_in_layer - (total_bits_in_layer % word_size)
      -- compact format only allows 64 data words, though C4 can hold more words than that
      local fits_compact = not compact or stuffed_bits.size <= word_size * 64
      if fits_compact and stuffed_bits.size + ecc_bits <= usable_bits_in_layers then
        break
      end
    end
    i = i + 1
  end
  local message_bits = generate_check_words(stuffed_bits, total_bits_in_layer, word_size)

  -- generate mode message
  local message_size_in_words = stuffed_bits.size // word_size
  local mode_message = generate_mode_message(compact, layers, message_size_in_words)

  -- allocate symbol
  local base_matrix_size = (compact and 11 or 14) + layers * 4 -- not including alignment lines
  local alignment_map = {}
  local matrix_size
  if compact then
    -- no alignment marks in compact mode, alignment_map is a no-op
    matrix_size = base_matrix_size
    for j = 0, base_matrix_size - 1 do
      alignment_map[j] = j
    end
  else
    matrix_size = base_matrix_size + 1 + 2 * ((base_matrix_size // 2 - 1) // 15)
    local orig_center = base_matrix_size // 2
    local center = matrix_size // 2
    for j = 0, orig_center - 1 do
      local new_offset = j + j // 15
      alignment_map[orig_center - j - 1] = center - new_offset - 1
      alignment_map[orig_center + j] = center + new_offset + 1
    end
  end

  local matrix = {}
  for y = 1, matrix_size do
    local row = {}
    for x = 1, matrix_size do
      row[x] = false
    end
    matrix[y] = row
  end
  -- 0-based, like BitMatrix.set
  local set = function(x, y)
    matrix[y + 1][x + 1] = true
  end

  -- draw data bits
  local row_offset = 0
  for l = 0, layers - 1 do
    local row_size = (layers - l) * 4 + (compact and 9 or 12)
    for j = 0, row_size - 1 do
      local column_offset = j * 2
      for k = 0, 1 do
        if get_bit(message_bits, row_offset + column_offset + k) then
          set(alignment_map[l * 2 + k], alignment_map[l * 2 + j])
        end
        if get_bit(message_bits, row_offset + row_size * 2 + column_offset + k) then
          set(alignment_map[l * 2 + j], alignment_map[base_matrix_size - 1 - l * 2 - k])
        end
        if get_bit(message_bits, row_offset + row_size * 4 + column_offset + k) then
          set(alignment_map[base_matrix_size - 1 - l * 2 - k], alignment_map[base_matrix_size - 1 - l * 2 - j])
        end
        if get_bit(message_bits, row_offset + row_size * 6 + column_offset + k) then
          set(alignment_map[base_matrix_size - 1 - l * 2 - j], alignment_map[l * 2 + k])
        end
      end
    end
    row_offset = row_offset + row_size * 8
  end

  -- draw mode message
  draw_mode_message(set, compact, matrix_size, mode_message)

  -- draw alignment marks
  local center = matrix_size // 2
  if compact then
    draw_bulls_eye(set, center, 5)
  else
    draw_bulls_eye(set, center, 7)
    local j = 0
    for _ = 0, base_matrix_size // 2 - 1, 15 do
      for k = center & 1, matrix_size - 1, 2 do
        set(center - j, k)
        set(center + j, k)
        set(k, center - j)
        set(k, center + j)
      end
      j = j + 16
    end
  end

  return matrix, matrix_size
end

libs["aztec"] = {
  encode = encode,
}
