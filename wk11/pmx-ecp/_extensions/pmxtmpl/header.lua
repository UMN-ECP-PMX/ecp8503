local text = require 'text'

function Header(el)
    if el.level == 1 then
        -- Debug: print original content
        print("Original content:", pandoc.utils.stringify(el.content))

        -- Convert to string
        local header_text = pandoc.utils.stringify(el.content)
        print("Stringified:", header_text)

        -- Uppercase using Lua's string.upper (safer)
        local upper_text = string.upper(header_text)
        print("Uppercase:", upper_text)

        -- Replace content
        el.content = { pandoc.Str(upper_text) }
        return el
    end
end
