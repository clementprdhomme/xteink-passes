--[==[
Code 128 barcode encoder

Copyright 2010 ZXing authors (Code128Writer.java)
Copyright 2008 ZXing authors (Code128Reader.java)
Copyright 2011 ZXing authors (OneDimensionalCodeWriter.java)
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
- core/src/main/java/com/google/zxing/oned/Code128Writer.java
- core/src/main/java/com/google/zxing/oned/Code128Reader.java (the CODE_PATTERNS table only)
- core/src/main/java/com/google/zxing/oned/OneDimensionalCodeWriter.java (appendPattern only)

Changes made to the original files:
- Translated from Java to Lua 5.5. The input is a string of bytes and positions are byte offsets.
- Only the default encoding (encodeFast and chooseCode) is ported. The compact encoding
  (MinimalEncoder), the FORCE_CODE_SET hint and the special function escapes (ESCAPE_FNC_1 to
  ESCAPE_FNC_4, used for GS1) are removed, together with the branches of chooseCode that handle them.
- Input bytes above 127 are rejected, as Code128Writer.check does for characters above 127.
- The module width in pixels is chosen here: encode takes a maximum width in pixels and a margin in
  modules, and returns the largest whole-pixel module width that fits.
- Errors are returned as `nil, err` ("invalid_argument" or "limit_exceeded") instead of exceptions.
- The result is an array of booleans (1-based, true for a bar) and the module width in pixels, instead
  of a boolean[] from OneDimensionalCodeWriter.

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

-- bar/space widths of the 107 patterns (values 0-102, start A/B/C at 103-105, stop at 106)
local CODE_PATTERNS = {
  [0] = { 2, 1, 2, 2, 2, 2 }, -- 0
  { 2, 2, 2, 1, 2, 2 }, -- 1
  { 2, 2, 2, 2, 2, 1 }, -- 2
  { 1, 2, 1, 2, 2, 3 }, -- 3
  { 1, 2, 1, 3, 2, 2 }, -- 4
  { 1, 3, 1, 2, 2, 2 }, -- 5
  { 1, 2, 2, 2, 1, 3 }, -- 6
  { 1, 2, 2, 3, 1, 2 }, -- 7
  { 1, 3, 2, 2, 1, 2 }, -- 8
  { 2, 2, 1, 2, 1, 3 }, -- 9
  { 2, 2, 1, 3, 1, 2 }, -- 10
  { 2, 3, 1, 2, 1, 2 }, -- 11
  { 1, 1, 2, 2, 3, 2 }, -- 12
  { 1, 2, 2, 1, 3, 2 }, -- 13
  { 1, 2, 2, 2, 3, 1 }, -- 14
  { 1, 1, 3, 2, 2, 2 }, -- 15
  { 1, 2, 3, 1, 2, 2 }, -- 16
  { 1, 2, 3, 2, 2, 1 }, -- 17
  { 2, 2, 3, 2, 1, 1 }, -- 18
  { 2, 2, 1, 1, 3, 2 }, -- 19
  { 2, 2, 1, 2, 3, 1 }, -- 20
  { 2, 1, 3, 2, 1, 2 }, -- 21
  { 2, 2, 3, 1, 1, 2 }, -- 22
  { 3, 1, 2, 1, 3, 1 }, -- 23
  { 3, 1, 1, 2, 2, 2 }, -- 24
  { 3, 2, 1, 1, 2, 2 }, -- 25
  { 3, 2, 1, 2, 2, 1 }, -- 26
  { 3, 1, 2, 2, 1, 2 }, -- 27
  { 3, 2, 2, 1, 1, 2 }, -- 28
  { 3, 2, 2, 2, 1, 1 }, -- 29
  { 2, 1, 2, 1, 2, 3 }, -- 30
  { 2, 1, 2, 3, 2, 1 }, -- 31
  { 2, 3, 2, 1, 2, 1 }, -- 32
  { 1, 1, 1, 3, 2, 3 }, -- 33
  { 1, 3, 1, 1, 2, 3 }, -- 34
  { 1, 3, 1, 3, 2, 1 }, -- 35
  { 1, 1, 2, 3, 1, 3 }, -- 36
  { 1, 3, 2, 1, 1, 3 }, -- 37
  { 1, 3, 2, 3, 1, 1 }, -- 38
  { 2, 1, 1, 3, 1, 3 }, -- 39
  { 2, 3, 1, 1, 1, 3 }, -- 40
  { 2, 3, 1, 3, 1, 1 }, -- 41
  { 1, 1, 2, 1, 3, 3 }, -- 42
  { 1, 1, 2, 3, 3, 1 }, -- 43
  { 1, 3, 2, 1, 3, 1 }, -- 44
  { 1, 1, 3, 1, 2, 3 }, -- 45
  { 1, 1, 3, 3, 2, 1 }, -- 46
  { 1, 3, 3, 1, 2, 1 }, -- 47
  { 3, 1, 3, 1, 2, 1 }, -- 48
  { 2, 1, 1, 3, 3, 1 }, -- 49
  { 2, 3, 1, 1, 3, 1 }, -- 50
  { 2, 1, 3, 1, 1, 3 }, -- 51
  { 2, 1, 3, 3, 1, 1 }, -- 52
  { 2, 1, 3, 1, 3, 1 }, -- 53
  { 3, 1, 1, 1, 2, 3 }, -- 54
  { 3, 1, 1, 3, 2, 1 }, -- 55
  { 3, 3, 1, 1, 2, 1 }, -- 56
  { 3, 1, 2, 1, 1, 3 }, -- 57
  { 3, 1, 2, 3, 1, 1 }, -- 58
  { 3, 3, 2, 1, 1, 1 }, -- 59
  { 3, 1, 4, 1, 1, 1 }, -- 60
  { 2, 2, 1, 4, 1, 1 }, -- 61
  { 4, 3, 1, 1, 1, 1 }, -- 62
  { 1, 1, 1, 2, 2, 4 }, -- 63
  { 1, 1, 1, 4, 2, 2 }, -- 64
  { 1, 2, 1, 1, 2, 4 }, -- 65
  { 1, 2, 1, 4, 2, 1 }, -- 66
  { 1, 4, 1, 1, 2, 2 }, -- 67
  { 1, 4, 1, 2, 2, 1 }, -- 68
  { 1, 1, 2, 2, 1, 4 }, -- 69
  { 1, 1, 2, 4, 1, 2 }, -- 70
  { 1, 2, 2, 1, 1, 4 }, -- 71
  { 1, 2, 2, 4, 1, 1 }, -- 72
  { 1, 4, 2, 1, 1, 2 }, -- 73
  { 1, 4, 2, 2, 1, 1 }, -- 74
  { 2, 4, 1, 2, 1, 1 }, -- 75
  { 2, 2, 1, 1, 1, 4 }, -- 76
  { 4, 1, 3, 1, 1, 1 }, -- 77
  { 2, 4, 1, 1, 1, 2 }, -- 78
  { 1, 3, 4, 1, 1, 1 }, -- 79
  { 1, 1, 1, 2, 4, 2 }, -- 80
  { 1, 2, 1, 1, 4, 2 }, -- 81
  { 1, 2, 1, 2, 4, 1 }, -- 82
  { 1, 1, 4, 2, 1, 2 }, -- 83
  { 1, 2, 4, 1, 1, 2 }, -- 84
  { 1, 2, 4, 2, 1, 1 }, -- 85
  { 4, 1, 1, 2, 1, 2 }, -- 86
  { 4, 2, 1, 1, 1, 2 }, -- 87
  { 4, 2, 1, 2, 1, 1 }, -- 88
  { 2, 1, 2, 1, 4, 1 }, -- 89
  { 2, 1, 4, 1, 2, 1 }, -- 90
  { 4, 1, 2, 1, 2, 1 }, -- 91
  { 1, 1, 1, 1, 4, 3 }, -- 92
  { 1, 1, 1, 3, 4, 1 }, -- 93
  { 1, 3, 1, 1, 4, 1 }, -- 94
  { 1, 1, 4, 1, 1, 3 }, -- 95
  { 1, 1, 4, 3, 1, 1 }, -- 96
  { 4, 1, 1, 1, 1, 3 }, -- 97
  { 4, 1, 1, 3, 1, 1 }, -- 98
  { 1, 1, 3, 1, 4, 1 }, -- 99
  { 1, 1, 4, 1, 3, 1 }, -- 100
  { 3, 1, 1, 1, 4, 1 }, -- 101
  { 4, 1, 1, 1, 3, 1 }, -- 102
  { 2, 1, 1, 4, 1, 2 }, -- 103
  { 2, 1, 1, 2, 1, 4 }, -- 104
  { 2, 1, 1, 2, 3, 2 }, -- 105
  { 2, 3, 3, 1, 1, 1, 2 }, -- 106
}

local CODE_START_A = 103
local CODE_START_B = 104
local CODE_START_C = 105
local CODE_CODE_A = 101
local CODE_CODE_B = 100
local CODE_CODE_C = 99
local CODE_STOP = 106

-- results of minimal lookahead for code C
local UNCODABLE = 0
local ONE_DIGIT = 1
local TWO_DIGITS = 2

local function is_digit(c)
  return c >= 48 and c <= 57 -- '0' to '9'
end

local function find_c_type(value, start)
  local last = #value
  if start >= last then
    return UNCODABLE
  end
  local c = string.byte(value, start + 1)
  if not is_digit(c) then
    return UNCODABLE
  end
  if start + 1 >= last then
    return ONE_DIGIT
  end
  c = string.byte(value, start + 2)
  if not is_digit(c) then
    return ONE_DIGIT
  end
  return TWO_DIGITS
end

local function choose_code(value, start, old_code)
  local lookahead = find_c_type(value, start)
  if lookahead == ONE_DIGIT then
    if old_code == CODE_CODE_A then
      return CODE_CODE_A
    end
    return CODE_CODE_B
  end
  if lookahead == UNCODABLE then
    if start < #value then
      local c = string.byte(value, start + 1)
      if c < 32 or (old_code == CODE_CODE_A and c < 96) then
        -- can continue in code A, encodes ASCII 0 to 95
        return CODE_CODE_A
      end
    end
    return CODE_CODE_B -- no choice
  end
  if old_code == CODE_CODE_C then -- can continue in code C
    return CODE_CODE_C
  end
  if old_code == CODE_CODE_B then
    -- seen two consecutive digits, see what follows
    lookahead = find_c_type(value, start + 2)
    if lookahead == UNCODABLE or lookahead == ONE_DIGIT then
      return CODE_CODE_B -- not worth switching now
    end
    -- at this point, there are at least 4 consecutive digits
    -- look ahead to choose whether to switch now or on the next round
    local index = start + 4
    lookahead = find_c_type(value, index)
    while lookahead == TWO_DIGITS do
      index = index + 2
      lookahead = find_c_type(value, index)
    end
    if lookahead == ONE_DIGIT then -- odd number of digits, switch later
      return CODE_CODE_B
    end
    return CODE_CODE_C -- even number of digits, switch now
  end
  -- here old_code == 0, which means we are choosing the initial code
  if lookahead == TWO_DIGITS then -- at least two digits, start in code C
    return CODE_CODE_C
  end
  return CODE_CODE_B
end

-- append the modules of a pattern, starting with a bar
local function append_pattern(target, pattern)
  local color = true
  for _, len in ipairs(pattern) do
    for _ = 1, len do
      target[#target + 1] = color
    end
    color = not color -- flip color after each segment
  end
end

-- encode a string of ASCII bytes
-- opts: max_width in pixels, margin in modules (on each side)
-- returns modules, module width (in pixels) or nil, err
local function encode(contents, opts)
  if type(contents) ~= "string" or #contents == 0 then
    return nil, "invalid_argument"
  end
  local length = #contents
  for i = 1, length do
    if string.byte(contents, i) > 127 then
      return nil, "invalid_argument"
    end
  end

  local patterns = {}
  local check_sum = 0
  local check_weight = 1
  local code_set = 0 -- selected code (CODE_CODE_A, CODE_CODE_B or CODE_CODE_C)
  local position = 0 -- position in contents

  while position < length do
    -- select code to use
    local new_code_set = choose_code(contents, position, code_set)

    -- get the pattern index
    local pattern_index
    if new_code_set == code_set then
      -- encode the current character
      local c = string.byte(contents, position + 1)
      if code_set == CODE_CODE_A then
        pattern_index = c - 32
        if pattern_index < 0 then
          -- everything below a space character comes behind the underscore in the code patterns table
          pattern_index = pattern_index + 96
        end
      elseif code_set == CODE_CODE_B then
        pattern_index = c - 32
      else
        -- CODE_CODE_C
        if position + 1 == length then
          -- this is the last character, but the encoding is C, which always encodes two characters
          return nil, "invalid_argument"
        end
        pattern_index = (c - 48) * 10 + string.byte(contents, position + 2) - 48
        position = position + 1 -- also incremented below
      end
      position = position + 1
    else
      -- should we change the current code?
      if code_set == 0 then
        -- no, we don't have a code set
        if new_code_set == CODE_CODE_A then
          pattern_index = CODE_START_A
        elseif new_code_set == CODE_CODE_B then
          pattern_index = CODE_START_B
        else
          pattern_index = CODE_START_C
        end
      else
        -- yes, we have a code set
        pattern_index = new_code_set
      end
      code_set = new_code_set
    end

    -- get the pattern
    patterns[#patterns + 1] = CODE_PATTERNS[pattern_index]

    -- compute checksum
    check_sum = check_sum + pattern_index * check_weight
    if position ~= 0 then
      check_weight = check_weight + 1
    end
  end

  -- compute and append checksum
  patterns[#patterns + 1] = CODE_PATTERNS[check_sum % 103]

  -- append stop code
  patterns[#patterns + 1] = CODE_PATTERNS[CODE_STOP]

  local modules = {}
  for _, pattern in ipairs(patterns) do
    append_pattern(modules, pattern)
  end

  local module_size = opts.max_width // (#modules + 2 * opts.margin)
  if module_size < 1 then
    return nil, "limit_exceeded"
  end

  return modules, module_size
end

libs["code128"] = {
  encode = encode,
}
