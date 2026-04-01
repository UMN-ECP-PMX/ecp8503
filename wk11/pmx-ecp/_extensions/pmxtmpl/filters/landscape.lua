local portrait_saved = false -- not used anymore: TODO: take it out next iteration
local start_val = [[
    \clearpage
    \KOMAoptions{paper=landscape, pagesize}
    \areaset[current]{9in}{5.5in}
    \setlength{\oddsidemargin}{0in}
    \setlength{\evensidemargin}{0in}
    \setlength{\topmargin}{-0.5in}
    \setlength{\headheight}{30pt}
    \setlength{\headsep}{25pt}
    \setlength{\footskip}{1in}
    \KOMAoptions{headsepline=2pt:\textwidth}%
    \pagestyle{scrheadings}
]]
local stop_val = [[
    \clearpage
    \savedportrait
    \KOMAoptions{headsepline=2pt:\textwidth}%
    \pagestyle{scrheadings}
]]

local save_portrait = '\\storeareas\\savedportrait'

function Pandoc(doc)
  local init = pandoc.RawBlock('latex', save_portrait)
  table.insert(doc.blocks, 1, init)
  return doc
end

function Div(el)
  if el.classes:includes('lscape') then
    if FORMAT:match 'latex' then
      local start = pandoc.RawBlock('latex', start_val)
      local stop = pandoc.RawBlock('latex', stop_val)
      table.insert(el.content, 1, start)
      table.insert(el.content, stop)
      return el.content
    end
  end
  return el
end
