local api = vim.api
local empty_3f = vim.tbl_isempty
local map = vim.tbl_map
local _local_1_ = math
local abs = _local_1_["abs"]
local ceil = _local_1_["ceil"]
local max = _local_1_["max"]
local min = _local_1_["min"]
local pow = _local_1_["pow"]
local function clamp(val, min0, max0)
  if (val < min0) then
    return min0
  elseif (val > max0) then
    return max0
  elseif "else" then
    return val
  else
    return nil
  end
end
local function inc(x)
  return (x + 1)
end
local function dec(x)
  return (x - 1)
end
local function echo(msg)
  vim.cmd("redraw")
  return api.nvim_echo({{msg}}, false, {})
end
local function replace_keycodes(s)
  return api.nvim_replace_termcodes(s, true, false, true)
end
local _3cctrl_v_3e = replace_keycodes("<c-v>")
local _3cesc_3e = replace_keycodes("<esc>")
local function get_motion_force(mode)
  local _3_
  if mode:match("o") then
    _3_ = mode:sub(-1)
  else
    _3_ = nil
  end
  if (nil ~= _3_) then
    local last_ch = _3_
    if ((last_ch == _3cctrl_v_3e) or (last_ch == "V") or (last_ch == "v")) then
      return last_ch
    else
      return nil
    end
  else
    return nil
  end
end
local function get_cursor_pos()
  return {vim.fn.line("."), vim.fn.col(".")}
end
local function char_at_pos(_7_, _9_)
  local _arg_8_ = _7_
  local line = _arg_8_[1]
  local byte_col = _arg_8_[2]
  local _arg_10_ = _9_
  local char_offset = _arg_10_["char-offset"]
  local line_str = vim.fn.getline(line)
  local char_idx = vim.fn.charidx(line_str, dec(byte_col))
  local char_nr = vim.fn.strgetchar(line_str, (char_idx + (char_offset or 0)))
  if (char_nr ~= -1) then
    return vim.fn.nr2char(char_nr)
  else
    return nil
  end
end
local function get_fold_edge(lnum, reverse_3f)
  local _12_
  local _13_
  if reverse_3f then
    _13_ = vim.fn.foldclosed
  else
    _13_ = vim.fn.foldclosedend
  end
  _12_ = _13_(lnum)
  if (_12_ == -1) then
    return nil
  elseif (nil ~= _12_) then
    local fold_edge = _12_
    return fold_edge
  else
    return nil
  end
end
local safe_labels = {"s", "f", "n", "u", "t", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
local labels = {"s", "f", "n", "j", "k", "l", "o", "d", "w", "e", "h", "m", "v", "g", "u", "t", "c", ".", "z", "/", "F", "L", "N", "H", "G", "M", "U", "T", "?", "Z"}
local opts = {case_insensitive = true, safe_labels = safe_labels, labels = labels, special_keys = {repeat_search = "<enter>", next_match = "<enter>", prev_match = "<tab>", next_group = "<space>", prev_group = "<tab>", eol = "<space>"}}
local function setup(user_opts)
  opts = setmetatable(user_opts, {__index = opts})
  return nil
end
local function user_forced_autojump_3f()
  return (not opts.labels or empty_3f(opts.labels))
end
local function user_forced_no_autojump_3f()
  return (not opts.safe_labels or empty_3f(opts.safe_labels))
end
local hl
local function _16_(self, _3ftarget_windows)
  if _3ftarget_windows then
    for _, w in ipairs(_3ftarget_windows) do
      api.nvim_buf_clear_namespace(w.bufnr, self.ns, dec(w.topline), w.botline)
    end
  else
  end
  return api.nvim_buf_clear_namespace(0, self.ns, dec(vim.fn.line("w0")), vim.fn.line("w$"))
end
hl = {group = {["label-primary"] = "LeapLabelPrimary", ["label-secondary"] = "LeapLabelSecondary", match = "LeapMatch", backdrop = "LeapBackdrop"}, priority = {label = 65535, cursor = 65534, backdrop = 65533}, ns = api.nvim_create_namespace(""), cleanup = _16_}
local function init_highlight(force_3f)
  local bg = vim.o.background
  local def_maps
  local _19_
  do
    local _18_ = bg
    if (_18_ == "light") then
      _19_ = "#222222"
    elseif true then
      local _ = _18_
      _19_ = "#ccff88"
    else
      _19_ = nil
    end
  end
  local _24_
  do
    local _23_ = bg
    if (_23_ == "light") then
      _24_ = "#ff8877"
    elseif true then
      local _ = _23_
      _24_ = "#ccff88"
    else
      _24_ = nil
    end
  end
  local _29_
  do
    local _28_ = bg
    if (_28_ == "light") then
      _29_ = "#77aaff"
    elseif true then
      local _ = _28_
      _29_ = "#99ccff"
    else
      _29_ = nil
    end
  end
  def_maps = {[hl.group.match] = {fg = _19_, ctermfg = "red", underline = true, nocombine = true}, [hl.group["label-primary"]] = {fg = "black", bg = _24_, ctermfg = "black", ctermbg = "red", nocombine = true}, [hl.group["label-secondary"]] = {fg = "black", bg = _29_, ctermfg = "black", ctermbg = "blue", nocombine = true}}
  for name, def_map in pairs(def_maps) do
    if not force_3f then
      def_map["default"] = true
    else
    end
    api.nvim_set_hl(0, name, def_map)
  end
  return nil
end
local function apply_backdrop(reverse_3f, _3ftarget_windows)
  if _3ftarget_windows then
    for _, win in ipairs(_3ftarget_windows) do
      vim.highlight.range(win.bufnr, hl.ns, hl.group.backdrop, {dec(win.topline), 0}, {dec(win.botline), -1}, {priority = hl.priority.backdrop})
    end
    return nil
  else
    local _let_34_ = map(dec, get_cursor_pos())
    local curline = _let_34_[1]
    local curcol = _let_34_[2]
    local _let_35_ = {dec(vim.fn.line("w0")), dec(vim.fn.line("w$"))}
    local win_top = _let_35_[1]
    local win_bot = _let_35_[2]
    local function _37_()
      if reverse_3f then
        return {{win_top, 0}, {curline, curcol}}
      else
        return {{curline, inc(curcol)}, {win_bot, -1}}
      end
    end
    local _let_36_ = _37_()
    local start = _let_36_[1]
    local finish = _let_36_[2]
    return vim.highlight.range(0, hl.ns, hl.group.backdrop, start, finish, {priority = hl.priority.backdrop})
  end
end
local function echo_no_prev_search()
  return echo("no previous search")
end
local function echo_not_found(s)
  return echo(("not found: " .. s))
end
local function push_cursor_21(direction)
  local function _40_()
    local _39_ = direction
    if (_39_ == "fwd") then
      return "W"
    elseif (_39_ == "bwd") then
      return "bW"
    else
      return nil
    end
  end
  return vim.fn.search("\\_.", _40_())
end
local function cursor_before_eol_3f()
  return (vim.fn.search("\\_.", "Wn") ~= vim.fn.line("."))
end
local function cursor_before_eof_3f()
  return ((vim.fn.line(".") == vim.fn.line("$")) and (vim.fn.virtcol(".") == dec(vim.fn.virtcol("$"))))
end
local function add_offset_21(offset)
  if (offset < 0) then
    return push_cursor_21("bwd")
  elseif (offset > 0) then
    if not cursor_before_eol_3f() then
      push_cursor_21("fwd")
    else
    end
    if (offset > 1) then
      return push_cursor_21("fwd")
    else
      return nil
    end
  else
    return nil
  end
end
local function push_beyond_eof_21()
  local saved = vim.o.virtualedit
  vim.o.virtualedit = "onemore"
  vim.cmd("norm! l")
  local function _45_()
    vim.o.virtualedit = saved
    return nil
  end
  return api.nvim_create_autocmd({"CursorMoved", "WinLeave", "BufLeave", "InsertEnter", "CmdlineEnter", "CmdwinEnter"}, {callback = _45_, once = true})
end
local function simulate_inclusive_op_21(motion_force)
  local _46_ = motion_force
  if (_46_ == nil) then
    if cursor_before_eof_3f() then
      return push_beyond_eof_21()
    else
      return push_cursor_21("fwd")
    end
  elseif (_46_ == "v") then
    return push_cursor_21("bwd")
  else
    return nil
  end
end
local function force_matchparen_refresh()
  pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchparen"})
  return pcall(api.nvim_exec_autocmds, "CursorMoved", {group = "matchup_matchparen"})
end
local function jump_to_21_2a(pos, _49_)
  local _arg_50_ = _49_
  local winid = _arg_50_["winid"]
  local add_to_jumplist_3f = _arg_50_["add-to-jumplist?"]
  local mode = _arg_50_["mode"]
  local offset = _arg_50_["offset"]
  local reverse_3f = _arg_50_["reverse?"]
  local inclusive_op_3f = _arg_50_["inclusive-op?"]
  local op_mode_3f = mode:match("o")
  if add_to_jumplist_3f then
    vim.cmd("norm! m`")
  else
  end
  if (winid ~= vim.fn.win_getid()) then
    api.nvim_set_current_win(winid)
  else
  end
  vim.fn.cursor(pos)
  if offset then
    add_offset_21(offset)
  else
  end
  if (op_mode_3f and inclusive_op_3f and not reverse_3f) then
    simulate_inclusive_op_21(get_motion_force(mode))
  else
  end
  if not op_mode_3f then
    return force_matchparen_refresh()
  else
    return nil
  end
end
local function highlight_cursor(_3fpos)
  local _let_56_ = (_3fpos or get_cursor_pos())
  local line = _let_56_[1]
  local col = _let_56_[2]
  local pos = _let_56_
  local ch_at_curpos = (char_at_pos(pos, {}) or " ")
  return api.nvim_buf_set_extmark(0, hl.ns, dec(line), dec(col), {virt_text = {{ch_at_curpos, "Cursor"}}, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.cursor})
end
local function handle_interrupted_change_op_21()
  local seq
  local function _57_()
    if (vim.fn.col(".") > 1) then
      return "<RIGHT>"
    else
      return ""
    end
  end
  seq = ("<C-\\><C-G>" .. _57_())
  return api.nvim_feedkeys(replace_keycodes(seq), "n", true)
end
local function exec_user_autocmds(pattern)
  return api.nvim_exec_autocmds("User", {pattern = pattern, modeline = false})
end
local function get_input()
  local _58_, _59_ = pcall(vim.fn.getcharstr)
  local function _60_()
    local ch = _59_
    return (ch ~= _3cesc_3e)
  end
  if (((_58_ == true) and (nil ~= _59_)) and _60_()) then
    local ch = _59_
    return ch
  else
    return nil
  end
end
local function set_dot_repeat()
  local op = vim.v.operator
  local cmd = replace_keycodes("<cmd>lua require'leap'.leap {['dot-repeat?'] = true}<cr>")
  local change
  if (op == "c") then
    change = replace_keycodes("<c-r>.<esc>")
  else
    change = nil
  end
  local seq = (op .. cmd .. (change or ""))
  pcall(vim.fn["repeat#setreg"], seq, vim.v.register)
  return pcall(vim.fn["repeat#set"], seq, -1)
end
local function get_other_windows_on_tabpage()
  local visual_or_OP_mode_3f = (vim.fn.mode() ~= "n")
  local get_wininfo
  local function _63_(_241)
    return (vim.fn.getwininfo(_241))[1]
  end
  get_wininfo = _63_
  local get_buf = api.nvim_win_get_buf
  local curr_winid = vim.fn.win_getid()
  local ids = string.gmatch(vim.fn.string(vim.fn.winlayout()), "%d+")
  local ids0
  do
    local tbl_15_auto = {}
    local i_16_auto = #tbl_15_auto
    for id in ids do
      local val_17_auto
      if not ((tonumber(id) == curr_winid) or (visual_or_OP_mode_3f and (get_buf(tonumber(id)) ~= get_buf(curr_winid)))) then
        val_17_auto = id
      else
        val_17_auto = nil
      end
      if (nil ~= val_17_auto) then
        i_16_auto = (i_16_auto + 1)
        do end (tbl_15_auto)[i_16_auto] = val_17_auto
      else
      end
    end
    ids0 = tbl_15_auto
  end
  return map(get_wininfo, ids0)
end
local function get_horizontal_bounds()
  local match_length = 2
  local textoff = vim.fn.getwininfo(vim.fn.win_getid())[1].textoff
  local offset_in_win = dec(vim.fn.wincol())
  local offset_in_editable_win = (offset_in_win - textoff)
  local left_bound = (vim.fn.virtcol(".") - offset_in_editable_win)
  local window_width = api.nvim_win_get_width(0)
  local right_edge = (left_bound + dec((window_width - textoff)))
  local right_bound = (right_edge - dec(match_length))
  return {left_bound, right_bound}
end
local function to_closed_fold_edge_21(reverse_3f)
  local _66_
  local _67_
  if reverse_3f then
    _67_ = vim.fn.foldclosed
  else
    _67_ = vim.fn.foldclosedend
  end
  _66_ = _67_(vim.fn.line("."))
  if (_66_ == -1) then
    return nil
  elseif (nil ~= _66_) then
    local edge_line = _66_
    vim.fn.cursor(edge_line, 0)
    local function _69_()
      if reverse_3f then
        return 1
      else
        return vim.fn.col("$")
      end
    end
    vim.fn.cursor(0, _69_())
    return "moved"
  else
    return nil
  end
end
local function reach_right_bound()
  while ((vim.fn.virtcol(".") < __fnl_global__right_2dbound) and not (vim.fn.col(".") >= dec(vim.fn.col("$")))) do
    vim.cmd("norm! l")
  end
  return nil
end
local function to_next_in_window_pos_21(reverse_3f, left_bound, right_bound, stopline)
  local _local_71_ = {vim.fn.line("."), vim.fn.virtcol(".")}
  local line = _local_71_[1]
  local virtcol = _local_71_[2]
  local from_pos = _local_71_
  local _72_
  if (virtcol < left_bound) then
    if reverse_3f then
      if (dec(line) >= stopline) then
        _72_ = {dec(line), right_bound}
      else
        _72_ = nil
      end
    else
      _72_ = {line, left_bound}
    end
  elseif (virtcol > right_bound) then
    if reverse_3f then
      _72_ = {line, right_bound}
    else
      if (inc(line) <= stopline) then
        _72_ = {inc(line), left_bound}
      else
        _72_ = nil
      end
    end
  else
    _72_ = nil
  end
  if (nil ~= _72_) then
    local to_pos = _72_
    if (from_pos ~= to_pos) then
      vim.fn.cursor(to_pos)
      if reverse_3f then
        reach_right_bound()
      else
      end
      return "moved"
    else
      return nil
    end
  else
    return nil
  end
end
local function get_match_positions(pattern, _81_)
  local _arg_82_ = _81_
  local reverse_3f = _arg_82_["reverse?"]
  local whole_window_3f = _arg_82_["whole-window?"]
  local skip_curpos_3f = _arg_82_["skip-curpos?"]
  local _arg_83_ = _arg_82_["bounds"]
  local left_bound = _arg_83_[1]
  local right_bound = _arg_83_[2]
  local reverse_3f0
  if whole_window_3f then
    reverse_3f0 = false
  else
    reverse_3f0 = reverse_3f
  end
  local skip_orig_curpos_3f = skip_curpos_3f
  local _let_85_ = get_cursor_pos()
  local orig_line = _let_85_[1]
  local orig_col = _let_85_[2]
  local saved_view = vim.fn.winsaveview()
  local saved_cpo = vim.o.cpo
  local wintop = vim.fn.line("w0")
  local winbot = vim.fn.line("w$")
  local stopline
  if reverse_3f0 then
    stopline = wintop
  else
    stopline = winbot
  end
  local cleanup
  local function _87_()
    vim.fn.winrestview(saved_view)
    vim.o.cpo = saved_cpo
    return nil
  end
  cleanup = _87_
  vim.o.cpo = saved_cpo:gsub("c", "")
  local match_count = 0
  local set_to_topleft_3f
  if whole_window_3f then
    vim.fn.cursor({wintop, left_bound})
    set_to_topleft_3f = true
  else
    set_to_topleft_3f = nil
  end
  local function rec(match_at_curpos_3f)
    local match_at_curpos_3f0 = (match_at_curpos_3f or set_to_topleft_3f)
    local flags
    local function _89_()
      if reverse_3f0 then
        return "b"
      else
        return ""
      end
    end
    local function _90_()
      if match_at_curpos_3f0 then
        return "c"
      else
        return ""
      end
    end
    flags = (_89_() .. _90_())
    set_to_topleft_3f = false
    local _91_ = vim.fn.searchpos(pattern, flags, stopline)
    if ((_G.type(_91_) == "table") and (nil ~= (_91_)[1]) and (nil ~= (_91_)[2])) then
      local line = (_91_)[1]
      local col = (_91_)[2]
      local pos = _91_
      if (line == 0) then
        return cleanup()
      else
        local _92_ = to_closed_fold_edge_21(reverse_3f0)
        if (_92_ == "moved") then
          return rec(false)
        elseif true then
          local _ = _92_
          if (skip_orig_curpos_3f and (line == orig_line) and (col == orig_col)) then
            push_cursor_21("fwd")
            return rec(true)
          elseif (not vim.wo.wrap and (col < left_bound) and (col > right_bound)) then
            local _93_ = to_next_in_window_pos_21(reverse_3f0, left_bound, right_bound, stopline)
            if (_93_ == "moved") then
              return rec(true)
            elseif true then
              local _0 = _93_
              return cleanup()
            else
              return nil
            end
          else
            match_count = (match_count + 1)
            return pos
          end
        else
          return nil
        end
      end
    else
      return nil
    end
  end
  return rec
end
local function get_targets_2a(input, _99_)
  local _arg_100_ = _99_
  local reverse_3f = _arg_100_["reverse?"]
  local wininfo = _arg_100_["wininfo"]
  local targets = _arg_100_["targets"]
  local source_winid = _arg_100_["source-winid"]
  local targets0 = (targets or {})
  local pattern
  local function _101_()
    if opts.case_insensitive then
      return "\\c"
    else
      return "\\C"
    end
  end
  pattern = ("\\V" .. _101_() .. input:gsub("\\", "\\\\") .. "\\_.")
  local _let_102_ = get_horizontal_bounds()
  local _ = _let_102_[1]
  local right_bound = _let_102_[2]
  local bounds = _let_102_
  local whole_window_3f = wininfo
  local wininfo0 = (wininfo or vim.fn.getwininfo(vim.fn.win_getid())[1])
  local skip_curpos_3f = (whole_window_3f and (vim.fn.win_getid() == source_winid))
  local kwargs = {bounds = bounds, ["reverse?"] = reverse_3f, ["skip-curpos?"] = skip_curpos_3f, ["whole-window?"] = whole_window_3f}
  local prev_match = {}
  for _103_ in get_match_positions(pattern, kwargs) do
    local _each_104_ = _103_
    local line = _each_104_[1]
    local col = _each_104_[2]
    local pos = _each_104_
    local ch1 = char_at_pos(pos, {})
    local ch2, eol_3f = nil, nil
    do
      local _105_ = char_at_pos(pos, {["char-offset"] = 1})
      if (nil ~= _105_) then
        local char = _105_
        ch2, eol_3f = char
      elseif true then
        local _0 = _105_
        ch2, eol_3f = replace_keycodes(opts.special_keys.eol), true
      else
        ch2, eol_3f = nil
      end
    end
    local same_char_triplet_3f
    local _107_
    if reverse_3f then
      _107_ = dec
    else
      _107_ = inc
    end
    same_char_triplet_3f = ((ch2 == prev_match.ch2) and (line == prev_match.line) and (col == _107_(prev_match.col)))
    prev_match = {line = line, col = col, ch2 = ch2}
    if not same_char_triplet_3f then
      table.insert(targets0, {wininfo = wininfo0, pos = pos, pair = {ch1, ch2}, ["edge-pos?"] = (eol_3f or (col == right_bound))})
    else
    end
  end
  if next(targets0) then
    return targets0
  else
    return nil
  end
end
local function distance(_111_, _113_)
  local _arg_112_ = _111_
  local l1 = _arg_112_[1]
  local c1 = _arg_112_[2]
  local _arg_114_ = _113_
  local l2 = _arg_114_[1]
  local c2 = _arg_114_[2]
  local editor_grid_aspect_ratio = 0.3
  local _let_115_ = {abs((c1 - c2)), abs((l1 - l2))}
  local dx = _let_115_[1]
  local dy = _let_115_[2]
  local dx0 = (dx * editor_grid_aspect_ratio)
  return pow((pow(dx0, 2) + pow(dy, 2)), 0.5)
end
local function get_targets(input, _116_)
  local _arg_117_ = _116_
  local reverse_3f = _arg_117_["reverse?"]
  local target_windows = _arg_117_["target-windows"]
  if target_windows then
    local targets = {}
    local cursor_positions = {}
    local cross_win_3f = not ((#target_windows == 1) and (target_windows[1].winid == vim.fn.win_getid()))
    local source_winid = vim.fn.win_getid()
    for _, w in ipairs(target_windows) do
      if cross_win_3f then
        api.nvim_set_current_win(w.winid)
      else
      end
      cursor_positions[w.winid] = get_cursor_pos()
      get_targets_2a(input, {wininfo = w, ["source-winid"] = source_winid, targets = targets})
    end
    if cross_win_3f then
      api.nvim_set_current_win(source_winid)
    else
    end
    if not empty_3f(targets) then
      local by_screen_pos_3f = (vim.o.wrap and (#targets < 200))
      if by_screen_pos_3f then
        for winid, _120_ in pairs(cursor_positions) do
          local _each_121_ = _120_
          local line = _each_121_[1]
          local col = _each_121_[2]
          local _122_ = vim.fn.screenpos(winid, line, col)
          if ((_G.type(_122_) == "table") and ((_122_).col == col) and (nil ~= (_122_).row)) then
            local row = (_122_).row
            cursor_positions[winid] = {row, col}
          else
          end
        end
      else
      end
      for _, _125_ in ipairs(targets) do
        local _each_126_ = _125_
        local _each_127_ = _each_126_["pos"]
        local line = _each_127_[1]
        local col = _each_127_[2]
        local _each_128_ = _each_126_["wininfo"]
        local winid = _each_128_["winid"]
        local t = _each_126_
        if by_screen_pos_3f then
          local _129_ = vim.fn.screenpos(winid, line, col)
          if ((_G.type(_129_) == "table") and ((_129_).col == col) and (nil ~= (_129_).row)) then
            local row = (_129_).row
            t["screenpos"] = {row, col}
          else
          end
        else
        end
        t["rank"] = distance((t.screenpos or t.pos), cursor_positions[winid])
      end
      local function _132_(_241, _242)
        return ((_241).rank < (_242).rank)
      end
      table.sort(targets, _132_)
      return targets
    else
      return nil
    end
  else
    return get_targets_2a(input, {["reverse?"] = reverse_3f, ["source-winid"] = vim.fn.win_getid()})
  end
end
local function populate_sublists(targets)
  targets["sublists"] = {}
  if opts.case_insensitive then
    local function _135_(t, k)
      return rawget(t, k:lower())
    end
    local function _136_(t, k, v)
      return rawset(t, k:lower(), v)
    end
    setmetatable(targets.sublists, {__index = _135_, __newindex = _136_})
  else
  end
  for _, _138_ in ipairs(targets) do
    local _each_139_ = _138_
    local _each_140_ = _each_139_["pair"]
    local _0 = _each_140_[1]
    local ch2 = _each_140_[2]
    local target = _each_139_
    if not targets.sublists[ch2] then
      targets["sublists"][ch2] = {}
    else
    end
    table.insert(targets.sublists[ch2], target)
  end
  return nil
end
local function set_autojump(sublist, force_no_autojump_3f)
  sublist["autojump?"] = (not (force_no_autojump_3f or user_forced_no_autojump_3f()) and (user_forced_autojump_3f() or (#opts.safe_labels >= dec(#sublist))))
  return nil
end
local function attach_label_set(sublist)
  local _142_
  if user_forced_autojump_3f() then
    _142_ = opts.safe_labels
  elseif user_forced_no_autojump_3f() then
    _142_ = opts.labels
  elseif sublist["autojump?"] then
    _142_ = opts.safe_labels
  else
    _142_ = opts.labels
  end
  sublist["label-set"] = _142_
  return nil
end
local function set_sublist_attributes(targets, _144_)
  local _arg_145_ = _144_
  local force_no_autojump_3f = _arg_145_["force-no-autojump?"]
  for _, sublist in pairs(targets.sublists) do
    set_autojump(sublist, force_no_autojump_3f)
    attach_label_set(sublist)
  end
  return nil
end
local function set_labels(targets)
  for _, sublist in pairs(targets.sublists) do
    if (#sublist > 1) then
      for i, target in ipairs(sublist) do
        local i0
        if sublist["autojump?"] then
          i0 = dec(i)
        else
          i0 = i
        end
        if (i0 > 0) then
          local labels0 = sublist["label-set"]
          local _148_
          do
            local _147_ = (i0 % #labels0)
            if (_147_ == 0) then
              _148_ = (labels0)[#labels0]
            elseif (nil ~= _147_) then
              local n = _147_
              _148_ = (labels0)[n]
            else
              _148_ = nil
            end
          end
          target["label"] = _148_
        else
        end
      end
    else
    end
  end
  return nil
end
local function set_label_states(sublist, _154_)
  local _arg_155_ = _154_
  local group_offset = _arg_155_["group-offset"]
  local labels0 = sublist["label-set"]
  local _7clabels_7c = #labels0
  local offset = (group_offset * _7clabels_7c)
  local primary_start
  local function _156_()
    if sublist["autojump?"] then
      return 2
    else
      return 1
    end
  end
  primary_start = (offset + _156_())
  local primary_end = (primary_start + dec(_7clabels_7c))
  local secondary_start = inc(primary_end)
  local secondary_end = (primary_end + _7clabels_7c)
  for i, target in ipairs(sublist) do
    if target.label then
      local _157_
      if (function(_158_,_159_,_160_) return (_158_ <= _159_) and (_159_ <= _160_) end)(primary_start,i,primary_end) then
        _157_ = "active-primary"
      elseif (function(_161_,_162_,_163_) return (_161_ <= _162_) and (_162_ <= _163_) end)(secondary_start,i,secondary_end) then
        _157_ = "active-secondary"
      elseif (i > secondary_end) then
        _157_ = "inactive"
      else
        _157_ = nil
      end
      target["label-state"] = _157_
    else
    end
  end
  return nil
end
local function set_initial_label_states(targets)
  for _, sublist in pairs(targets.sublists) do
    set_label_states(sublist, {["group-offset"] = 0})
  end
  return nil
end
local function inactivate_labels(target_list)
  for _, target in ipairs(target_list) do
    target["label-state"] = "inactive"
  end
  return nil
end
local function set_beacon_for_labeled(target)
  if target["label-state"] then
    local _let_166_ = target
    local _let_167_ = _let_166_["pair"]
    local ch1 = _let_167_[1]
    local ch2 = _let_167_[2]
    local edge_pos_3f = _let_166_["edge-pos?"]
    local label = _let_166_["label"]
    local offset
    local function _168_()
      if edge_pos_3f then
        return 0
      else
        return ch2:len()
      end
    end
    offset = (ch1:len() + _168_())
    local virttext
    do
      local _169_ = target["label-state"]
      if (_169_ == "active-primary") then
        virttext = {{label, hl.group["label-primary"]}}
      elseif (_169_ == "active-secondary") then
        virttext = {{label, hl.group["label-secondary"]}}
      elseif (_169_ == "inactive") then
        virttext = {{" ", hl.group["label-secondary"]}}
      else
        virttext = nil
      end
    end
    target["beacon"] = {offset, virttext}
    return nil
  else
    return nil
  end
end
local function set_beacon_to_match_hl(target)
  local _let_172_ = target
  local _let_173_ = _let_172_["pair"]
  local ch1 = _let_173_[1]
  local ch2 = _let_173_[2]
  target["beacon"] = {0, {{(ch1 .. ch2), hl.group.match}}}
  return nil
end
local function set_beacon_to_empty_label(target)
  target["beacon"][2][1][1] = " "
  return nil
end
local function resolve_conflicts(target_list)
  local unlabeled_match_positions = {}
  local label_positions = {}
  for i, target in ipairs(target_list) do
    local _let_174_ = target
    local _let_175_ = _let_174_["pos"]
    local lnum = _let_175_[1]
    local col = _let_175_[2]
    local _let_176_ = _let_174_["pair"]
    local ch1 = _let_176_[1]
    local _ = _let_176_[2]
    local _let_177_ = _let_174_["wininfo"]
    local bufnr = _let_177_["bufnr"]
    local winid = _let_177_["winid"]
    local _178_ = target.beacon
    if (_178_ == nil) then
      local keys = {(bufnr .. " " .. winid .. " " .. lnum .. " " .. col), (bufnr .. " " .. winid .. " " .. lnum .. " " .. (col + ch1:len()))}
      for _0, k in ipairs(keys) do
        do
          local _179_ = label_positions[k]
          if (nil ~= _179_) then
            local other = _179_
            other.beacon = nil
            set_beacon_to_match_hl(target)
          else
          end
        end
        unlabeled_match_positions[k] = target
      end
    elseif ((_G.type(_178_) == "table") and (nil ~= (_178_)[1]) and true) then
      local offset = (_178_)[1]
      local _0 = (_178_)[2]
      local k = (bufnr .. " " .. winid .. " " .. lnum .. " " .. (col + offset))
      do
        local _181_ = unlabeled_match_positions[k]
        if (nil ~= _181_) then
          local other = _181_
          target.beacon = nil
          set_beacon_to_match_hl(other)
        elseif true then
          local _1 = _181_
          local _182_ = label_positions[k]
          if (nil ~= _182_) then
            local other = _182_
            target.beacon = nil
            set_beacon_to_empty_label(other)
          else
          end
        else
        end
      end
      label_positions[k] = target
    else
    end
  end
  return nil
end
local function set_beacons(target_list, _186_)
  local _arg_187_ = _186_
  local force_no_labels_3f = _arg_187_["force-no-labels?"]
  if force_no_labels_3f then
    for _, target in ipairs(target_list) do
      set_beacon_to_match_hl(target)
    end
    return nil
  else
    for _, target in ipairs(target_list) do
      set_beacon_for_labeled(target)
    end
    return resolve_conflicts(target_list)
  end
end
local function light_up_beacons(target_list, _3fstart_from)
  for i = (_3fstart_from or 1), #target_list do
    local target = target_list[i]
    local _189_ = target.beacon
    if ((_G.type(_189_) == "table") and (nil ~= (_189_)[1]) and (nil ~= (_189_)[2])) then
      local offset = (_189_)[1]
      local virttext = (_189_)[2]
      local _let_190_ = map(dec, target.pos)
      local lnum = _let_190_[1]
      local col = _let_190_[2]
      api.nvim_buf_set_extmark(target.wininfo.bufnr, hl.ns, lnum, (col + offset), {virt_text = virttext, virt_text_pos = "overlay", hl_mode = "combine", priority = hl.priority.label})
    else
    end
  end
  return nil
end
local state = {["repeat"] = {in1 = nil, in2 = nil}, ["dot-repeat"] = {in1 = nil, in2 = nil, ["target-idx"] = nil, ["reverse?"] = nil, ["inclusive-op?"] = nil, ["offset?"] = nil}}
local function leap(_192_)
  local _arg_193_ = _192_
  local dot_repeat_3f = _arg_193_["dot-repeat?"]
  local target_windows = _arg_193_["target-windows"]
  local kwargs = _arg_193_
  local function _195_()
    if dot_repeat_3f then
      return state["dot-repeat"]
    else
      return nil
    end
  end
  local _let_194_ = (_195_() or kwargs)
  local reverse_3f = _let_194_["reverse?"]
  local inclusive_op_3f = _let_194_["inclusive-op?"]
  local offset = _let_194_["offset"]
  local _3ftarget_windows
  do
    local _197_ = target_windows
    if (_G.type(_197_) == "table") then
      local t = _197_
      _3ftarget_windows = t
    elseif (_197_ == true) then
      _3ftarget_windows = get_other_windows_on_tabpage()
    else
      _3ftarget_windows = nil
    end
  end
  local bidirectional_3f = _3ftarget_windows
  local mode = api.nvim_get_mode().mode
  local op_mode_3f = mode:match("o")
  local change_op_3f = (op_mode_3f and (vim.v.operator == "c"))
  local dot_repeatable_op_3f = (op_mode_3f and not bidirectional_3f and (vim.v.operator ~= "y"))
  local force_no_autojump_3f = (op_mode_3f or bidirectional_3f)
  local spec_keys
  local function _199_(_, k)
    return replace_keycodes(opts.special_keys[k])
  end
  spec_keys = setmetatable({}, {__index = _199_})
  local function get_target_with_active_primary_label(sublist, input)
    local res = nil
    for idx, _200_ in ipairs(sublist) do
      local _each_201_ = _200_
      local label = _each_201_["label"]
      local label_state = _each_201_["label-state"]
      local target = _each_201_
      if (res or (label_state == "inactive")) then break end
      if ((label == input) and (label_state == "active-primary")) then
        res = {idx, target}
      else
      end
    end
    return res
  end
  local function update_state(state_2a)
    if not dot_repeat_3f then
      if state_2a["repeat"] then
        state["repeat"] = state_2a["repeat"]
      else
      end
      if (state_2a["dot-repeat"] and dot_repeatable_op_3f) then
        state["dot-repeat"] = vim.tbl_extend("error", state_2a["dot-repeat"], {["reverse?"] = reverse_3f, offset = offset, ["inclusive-op?"] = inclusive_op_3f})
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local jump_to_21
  do
    local first_jump_3f = true
    local function _206_(target)
      jump_to_21_2a(target.pos, {winid = target.wininfo.winid, ["add-to-jumplist?"] = first_jump_3f, mode = mode, offset = offset, ["reverse?"] = reverse_3f, ["inclusive-op?"] = inclusive_op_3f})
      first_jump_3f = false
      return nil
    end
    jump_to_21 = _206_
  end
  local function traverse(targets, idx, _207_)
    local _arg_208_ = _207_
    local force_no_labels_3f = _arg_208_["force-no-labels?"]
    if force_no_labels_3f then
      inactivate_labels(targets)
    else
    end
    set_beacons(targets, {["force-no-labels?"] = force_no_labels_3f})
    do
      apply_backdrop(reverse_3f, _3ftarget_windows)
      do
        light_up_beacons(targets, inc(idx))
      end
      highlight_cursor()
      vim.cmd("redraw")
    end
    local _210_
    local function _211_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup(_3ftarget_windows)
      return res_2_auto
    end
    local function _212_()
      if dot_repeatable_op_3f then
        set_dot_repeat()
      else
      end
      do
      end
      exec_user_autocmds("LeapLeave")
      return nil
    end
    _210_ = (_211_() or _212_())
    if (nil ~= _210_) then
      local input = _210_
      if ((input == spec_keys.next_match) or (input == spec_keys.prev_match)) then
        local new_idx
        do
          local _214_ = input
          if (_214_ == spec_keys.next_match) then
            new_idx = min(inc(idx), #targets)
          elseif (_214_ == spec_keys.prev_match) then
            new_idx = max(dec(idx), 1)
          else
            new_idx = nil
          end
        end
        update_state({["repeat"] = {in1 = state["repeat"].in1, in2 = targets[new_idx].pair[2]}})
        jump_to_21(targets[new_idx])
        return traverse(targets, new_idx, {["force-no-labels?"] = force_no_labels_3f})
      else
        local _216_ = get_target_with_active_primary_label(targets, input)
        if ((_G.type(_216_) == "table") and true and (nil ~= (_216_)[2])) then
          local _ = (_216_)[1]
          local target = (_216_)[2]
          if dot_repeatable_op_3f then
            set_dot_repeat()
          else
          end
          do
            jump_to_21(target)
          end
          exec_user_autocmds("LeapLeave")
          return nil
        elseif true then
          local _ = _216_
          if dot_repeatable_op_3f then
            set_dot_repeat()
          else
          end
          do
            vim.fn.feedkeys(input, "i")
          end
          exec_user_autocmds("LeapLeave")
          return nil
        else
          return nil
        end
      end
    else
      return nil
    end
  end
  local function get_first_pattern_input()
    do
      apply_backdrop(reverse_3f, _3ftarget_windows)
      do
        echo("")
      end
      highlight_cursor()
      vim.cmd("redraw")
    end
    local _222_
    local function _223_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup(_3ftarget_windows)
      return res_2_auto
    end
    local function _224_()
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      exec_user_autocmds("LeapLeave")
      return nil
    end
    _222_ = (_223_() or _224_())
    if (_222_ == spec_keys.repeat_search) then
      if state["repeat"].in1 then
        return state["repeat"].in1, state["repeat"].in2
      else
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_no_prev_search()
        end
        exec_user_autocmds("LeapLeave")
        return nil
      end
    elseif (nil ~= _222_) then
      local in1 = _222_
      return in1
    else
      return nil
    end
  end
  local function get_second_pattern_input(targets)
    do
      local _229_ = targets
      set_initial_label_states(_229_)
      set_beacons(_229_, {})
    end
    do
      apply_backdrop(reverse_3f, _3ftarget_windows)
      do
        light_up_beacons(targets)
      end
      highlight_cursor()
      vim.cmd("redraw")
    end
    local function _230_()
      local res_2_auto
      do
        res_2_auto = get_input()
      end
      hl:cleanup(_3ftarget_windows)
      return res_2_auto
    end
    local function _231_()
      if change_op_3f then
        handle_interrupted_change_op_21()
      else
      end
      do
      end
      exec_user_autocmds("LeapLeave")
      return nil
    end
    return (_230_() or _231_())
  end
  local function post_pattern_input_loop(sublist)
    local function loop(group_offset, initial_invoc_3f)
      do
        local _233_ = sublist
        set_label_states(_233_, {["group-offset"] = group_offset})
        set_beacons(_233_, {})
      end
      do
        apply_backdrop(reverse_3f, _3ftarget_windows)
        do
          light_up_beacons(sublist)
        end
        highlight_cursor()
        vim.cmd("redraw")
      end
      local _234_
      local function _235_()
        local res_2_auto
        do
          res_2_auto = get_input()
        end
        hl:cleanup(_3ftarget_windows)
        return res_2_auto
      end
      local function _236_()
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
        end
        exec_user_autocmds("LeapLeave")
        return nil
      end
      _234_ = (_235_() or _236_())
      if (nil ~= _234_) then
        local input = _234_
        if (((input == spec_keys.next_group) or ((input == spec_keys.prev_group) and not initial_invoc_3f)) and (not sublist["autojump?"] or user_forced_autojump_3f)) then
          local _7cgroups_7c = ceil((#sublist / #sublist["label-set"]))
          local max_offset = dec(_7cgroups_7c)
          local inc_2fdec
          if (input == spec_keys.next_group) then
            inc_2fdec = inc
          else
            inc_2fdec = dec
          end
          local new_offset = clamp(inc_2fdec(group_offset), 0, max_offset)
          return loop(new_offset, false)
        else
          return input
        end
      else
        return nil
      end
    end
    return loop(0, true)
  end
  exec_user_autocmds("LeapEnter")
  local function _241_(...)
    local _242_, _243_ = ...
    if ((nil ~= _242_) and true) then
      local in1 = _242_
      local _3fin2 = _243_
      local function _244_(...)
        local _245_ = ...
        if (nil ~= _245_) then
          local targets = _245_
          local function _246_(...)
            local _247_ = ...
            if (nil ~= _247_) then
              local in2 = _247_
              if dot_repeat_3f then
                local _248_ = targets[state["dot-repeat"]["target-idx"]]
                if (nil ~= _248_) then
                  local target = _248_
                  if dot_repeatable_op_3f then
                    set_dot_repeat()
                  else
                  end
                  do
                    jump_to_21(target)
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                elseif true then
                  local _ = _248_
                  if change_op_3f then
                    handle_interrupted_change_op_21()
                  else
                  end
                  do
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                else
                  return nil
                end
              elseif ((in2 == spec_keys.next_match) and not bidirectional_3f) then
                local in20 = targets[1].pair[2]
                update_state({["repeat"] = {in1 = in1, in2 = in20}})
                jump_to_21(targets[1])
                if (op_mode_3f or (#targets == 1)) then
                  if dot_repeatable_op_3f then
                    set_dot_repeat()
                  else
                  end
                  do
                    update_state({["dot-repeat"] = {in1 = in1, in2 = in20, ["target-idx"] = 1}})
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                else
                  return traverse(targets, 1, {["force-no-labels?"] = true})
                end
              else
                update_state({["repeat"] = {in1 = in1, in2 = in2}})
                local update_dot_repeat_state
                local function _254_(_241)
                  return update_state({["dot-repeat"] = {in1 = in1, in2 = in2, ["target-idx"] = _241}})
                end
                update_dot_repeat_state = _254_
                local _255_
                local function _256_(...)
                  if change_op_3f then
                    handle_interrupted_change_op_21()
                  else
                  end
                  do
                    echo_not_found((in1 .. in2))
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                end
                _255_ = (targets.sublists[in2] or _256_(...))
                if ((_G.type(_255_) == "table") and (nil ~= (_255_)[1]) and ((_255_)[2] == nil)) then
                  local only = (_255_)[1]
                  if dot_repeatable_op_3f then
                    set_dot_repeat()
                  else
                  end
                  do
                    update_dot_repeat_state(1)
                    jump_to_21(only)
                  end
                  exec_user_autocmds("LeapLeave")
                  return nil
                elseif (nil ~= _255_) then
                  local sublist = _255_
                  if sublist["autojump?"] then
                    jump_to_21(sublist[1])
                  else
                  end
                  local _260_ = post_pattern_input_loop(sublist)
                  local function _261_(...)
                    return not bidirectional_3f
                  end
                  if ((_260_ == spec_keys.next_match) and _261_(...)) then
                    local new_idx
                    if sublist["autojump?"] then
                      new_idx = 2
                    else
                      new_idx = 1
                    end
                    jump_to_21(sublist[new_idx])
                    if op_mode_3f then
                      if dot_repeatable_op_3f then
                        set_dot_repeat()
                      else
                      end
                      do
                        update_dot_repeat_state(1)
                      end
                      exec_user_autocmds("LeapLeave")
                      return nil
                    else
                      return traverse(sublist, new_idx, {["force-no-labels?"] = not sublist["autojump?"]})
                    end
                  elseif (nil ~= _260_) then
                    local input = _260_
                    local _265_ = get_target_with_active_primary_label(sublist, input)
                    if ((_G.type(_265_) == "table") and (nil ~= (_265_)[1]) and (nil ~= (_265_)[2])) then
                      local idx = (_265_)[1]
                      local target = (_265_)[2]
                      if dot_repeatable_op_3f then
                        set_dot_repeat()
                      else
                      end
                      do
                        update_dot_repeat_state(idx)
                        jump_to_21(target)
                      end
                      exec_user_autocmds("LeapLeave")
                      return nil
                    elseif true then
                      local _ = _265_
                      if sublist["autojump?"] then
                        if dot_repeatable_op_3f then
                          set_dot_repeat()
                        else
                        end
                        do
                          vim.fn.feedkeys(input, "i")
                        end
                        exec_user_autocmds("LeapLeave")
                        return nil
                      else
                        if change_op_3f then
                          handle_interrupted_change_op_21()
                        else
                        end
                        do
                        end
                        exec_user_autocmds("LeapLeave")
                        return nil
                      end
                    else
                      return nil
                    end
                  else
                    return nil
                  end
                else
                  return nil
                end
              end
            elseif true then
              local __60_auto = _247_
              return ...
            else
              return nil
            end
          end
          local function _275_(...)
            do
              local _276_ = targets
              populate_sublists(_276_)
              set_sublist_attributes(_276_, {["force-no-autojump?"] = force_no_autojump_3f})
              set_labels(_276_)
            end
            return (_3fin2 or get_second_pattern_input(targets))
          end
          return _246_(_275_(...))
        elseif true then
          local __60_auto = _245_
          return ...
        else
          return nil
        end
      end
      local function _278_(...)
        if change_op_3f then
          handle_interrupted_change_op_21()
        else
        end
        do
          echo_not_found((in1 .. (_3fin2 or "")))
        end
        exec_user_autocmds("LeapLeave")
        return nil
      end
      return _244_((get_targets(in1, {["reverse?"] = reverse_3f, ["target-windows"] = _3ftarget_windows}) or _278_(...)))
    elseif true then
      local __60_auto = _242_
      return ...
    else
      return nil
    end
  end
  local function _281_()
    if dot_repeat_3f then
      return state["dot-repeat"].in1, state["dot-repeat"].in2
    else
      return get_first_pattern_input()
    end
  end
  return _241_(_281_())
end
local function set_default_keymaps(force_3f)
  for _, _282_ in ipairs({{"n", "s", "<Plug>(leap-forward)"}, {"n", "S", "<Plug>(leap-backward)"}, {"x", "s", "<Plug>(leap-forward)"}, {"x", "S", "<Plug>(leap-backward)"}, {"o", "z", "<Plug>(leap-forward)"}, {"o", "Z", "<Plug>(leap-backward)"}, {"o", "x", "<Plug>(leap-forward-x)"}, {"o", "X", "<Plug>(leap-backward-x)"}, {"n", "gs", "<Plug>(leap-cross-window)"}, {"x", "gs", "<Plug>(leap-cross-window)"}, {"o", "gs", "<Plug>(leap-cross-window)"}}) do
    local _each_283_ = _282_
    local mode = _each_283_[1]
    local lhs = _each_283_[2]
    local rhs = _each_283_[3]
    if (force_3f or ((vim.fn.mapcheck(lhs, mode) == "") and (vim.fn.hasmapto(rhs, mode) == 0))) then
      vim.keymap.set(mode, lhs, rhs, {silent = true})
    else
    end
  end
  return nil
end
local temporary_editor_opts = {["vim.bo.modeline"] = false}
local saved_editor_opts = {}
local function save_editor_opts()
  for opt, _ in pairs(temporary_editor_opts) do
    local _let_285_ = vim.split(opt, ".", true)
    local _0 = _let_285_[1]
    local scope = _let_285_[2]
    local name = _let_285_[3]
    saved_editor_opts[opt] = _G.vim[scope][name]
  end
  return nil
end
local function set_editor_opts(opts0)
  for opt, val in pairs(opts0) do
    local _let_286_ = vim.split(opt, ".", true)
    local _ = _let_286_[1]
    local scope = _let_286_[2]
    local name = _let_286_[3]
    _G.vim[scope][name] = val
  end
  return nil
end
local function set_temporary_editor_opts()
  return set_editor_opts(temporary_editor_opts)
end
local function restore_editor_opts()
  return set_editor_opts(saved_editor_opts)
end
init_highlight()
api.nvim_create_augroup("LeapDefault", {})
api.nvim_create_autocmd("ColorScheme", {callback = init_highlight, group = "LeapDefault"})
local function _287_()
  save_editor_opts()
  return set_temporary_editor_opts()
end
api.nvim_create_autocmd("User", {pattern = "LeapEnter", callback = _287_, group = "LeapDefault"})
api.nvim_create_autocmd("User", {pattern = "LeapLeave", callback = restore_editor_opts, group = "LeapDefault"})
return {opts = opts, setup = setup, state = state, leap = leap, init_highlight = init_highlight, set_default_keymaps = set_default_keymaps}
