-- cref-converter.lua
-- Converts all Quarto cross-references (@fig-label, @tbl-label) to use \cref
-- This filter intercepts Quarto’s reference system and replaces it with cleveref

function Cite(cite)
-- Quarto cross-references come through as citations
  if cite.citations and #cite.citations > 0 then
    local citation = cite.citations[1]
    local id = citation.id
-- Check if this is a figure or table reference
-- Quarto uses prefixes: fig-, tbl-, eq-, sec-, etc.
    if id:match("^fig%-") or id:match("^tbl%-") or id:match("^eq%-") then
  -- Convert hyphen to colon for LaTeX labels (fig-myplot → fig:myplot)
    local latex_id = id:gsub("%-", "-")

  -- Use \cref which cleveref will format properly
    return pandoc.RawInline('latex', "\\Cref{" .. latex_id .. "}")
    end


  end
  return cite
end

-- Also handle Link elements (in case references come through as links)
function Link(link)
if FORMAT:match 'latex' then
  local target = link.target
-- Check if it's a reference link (starts with #)
if target:match("^#fig%-") or target:match("^#tbl%-") or target:match("^#eq%-") then
  -- Remove the # and convert hyphen to colon
  local id = target:sub(2):gsub("%-", ":")

  -- Replace the link with \cref
  return pandoc.RawInline('latex', "\\Cref{" .. id .. "}")
end

end
return link
end
