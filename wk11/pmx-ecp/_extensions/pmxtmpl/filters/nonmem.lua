-- pandoc lua filter for fancyvrb/Verbatim with robust wrapping
-- Classes recognized on the code block:
--   Target: nonmem | nmctl | control-stream | nm
--   Size:   tiny | footnotesize | scriptsize (default \small)
--   Font:   courier | inconsolata | lucida (default \ttfamily)
--   Flags:  nowrap | numbers | landscape-code

function CodeBlock(el)
  local is_nonmem =
      el.classes:includes('nonmem') or
      el.classes:includes('nmctl') or
      el.classes:includes('control-stream') or
      el.classes:includes('nm')

  if not is_nonmem then
    return nil
  end

  if not FORMAT:match('latex') then
    return nil
  end

  local code = el.text

  -- Font family: implemented via formatcom (fancyvrb)
  local ff = '\\ttfamily'
  if el.classes:includes('courier') then
    ff = '\\fontfamily{pcr}\\selectfont'      -- Courier
  elseif el.classes:includes('inconsolata') then
    ff = '\\fontfamily{zi4}\\selectfont'      -- Inconsolata (needs zi4)
  elseif el.classes:includes('lucida') then
    ff = '\\fontfamily{fvm}\\selectfont'      -- Bera Mono/Lucida-like
  end

  -- Font size
  local fs = '\\small'
  if el.classes:includes('tiny') then
    fs = '\\tiny'
  elseif el.classes:includes('footnotesize') then
    fs = '\\footnotesize'
  elseif el.classes:includes('scriptsize') then
    fs = '\\scriptsize'
  end

  -- Format command applied to verbatim content
  local formatcom = ff .. fs

  -- Wrapping
  local nowrap = el.classes:includes('nowrap')
  local opts = {}

  table.insert(opts, string.format('formatcom=%s', formatcom))
  table.insert(opts, 'showspaces=false')
  table.insert(opts, 'showtabs=false')

  if not nowrap then
    -- robust wrapping with fvextra
    table.insert(opts, 'breaklines=true')
    table.insert(opts, 'breakanywhere=true')            -- requires fvextra
    table.insert(opts, 'breakautoindent=true')          -- preserve indent
    table.insert(opts, [[postbreak=\mbox{\textcolor{red}{$\hookrightarrow$}\space}]])
  else
    table.insert(opts, 'breaklines=false')
  end

  -- Margins and frame
  table.insert(opts, 'xleftmargin=2pt')
  table.insert(opts, 'xrightmargin=2pt')
  table.insert(opts, 'frame=leftline')
  table.insert(opts, 'framesep=1mm')

  -- Line numbers (fancyvrb)
  if el.classes:includes('numbers') then
    table.insert(opts, 'numbers=left')
    table.insert(opts, 'stepnumber=5')
    table.insert(opts, 'numbersep=6pt')
    table.insert(opts, 'numberblanklines=false')
    -- number color needs \theFancyVerbLine redefinition; keep default or set via \fvset globally
  end

  local opt_str = table.concat(opts, ',\n')

  local out = string.format("\\begin{Verbatim}[%s]\n%s\n\\end{Verbatim}", opt_str, code)

  if el.classes:includes('landscape-code') then
    out = "\\begin{landscape}\n" .. out .. "\n\\end{landscape}"
  end

  return pandoc.RawBlock('latex', out)
end
