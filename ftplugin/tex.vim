" Quickly wrap selection (in visual mode) or current 
" WORD (in normal mode) as italic.
vnoremap <leader>ti di\textit{<c-r>"}<esc>
nnoremap <leader>ti diWi\textit{<c-r>"}<esc>

" Quickly wrap selection as bold.
vnoremap <leader>tb di\textbf{<c-r>"}<esc>
nnoremap <leader>tb diWi\textbf{<c-r>"}<esc>

" Auto close inline equation.
inoremap \( \(\)<esc>hi

" Auto close line wise equation.
inoremap \[ \[\]<esc>hi

" Insert new equation environment
nnoremap \teq i\begin{equation}<cr><cr>\end{equation}<esc>ki<tab>

function! TikzPlotComplete(findstart, base)
    if a:findstart 
        let line = getline('.')
        let matchcol = match(line, '\a')
        return matchcol
    else
        " find items related to base
        "
        if IsEnvironment(line('.'), 'axis')
            let possibleOptions = ["xtick",
                        \ "ytick",
                        \ "ylabel",
                        \ "ylabel style",
                        \ "xlabel",
                        \ "xlabel style",
                        \ "align",
                        \ "col sep",
                        \ "ymin",
                        \ "ymax",
                        \ "xmin",
                        \ "xmax", 
                        \ "only marks",
                        \ "axis lines",
                        \ '\addlegendentry',
                        \ "legend pos",
                        \ ] 

            let results = []
            for possibleOption in possibleOptions
                if match(possibleOption, a:base) > -1
                    call add(results, possibleOption)
                endif 
            endfor
            return results
        endif
        return []
    endif
endfunction


" Pulls out the current visual selection as a new command.
function! s:CreateCommandLatex()
    " Store the current value of register s in case you want to keep it. 
    let currentPosition = getpos(".")

    call inputsave()
    let newCommandName = input("Enter name for the command: ")
    call inputrestore()

    let temp = @s 

    norm! gv"sy

    execute "normal! gvs\\" . newCommandName 

    let openLine = search("^\s*$","bnW")

    if openLine > 0
        execute "normal! " . openLine . "Gi\\newcommand{\\" . newCommandName . "}{" . @s .  "}\<esc>%h"
    endif 

    call setpos('.', currentPosition)

    let @s = temp

endfunction

xnoremap <leader>trv :<c-u>call <SID>CreateCommandLatex()<cr>

" These mappings add an item element when one is above it. 
inoremap <cr> <cr><esc>:<c-u>call <SID>AddItemCommand()<cr>
nnoremap o o<esc>:<c-u>call <SID>AddItemCommand()<cr>

function! s:AddItemCommand()
    let currentLine = line('.')
    let previousLineText = getline(currentLine-1)

    if match(previousLineText,'^\s*\\item') == 0
        execute "normal! i    \\item "
    endif
    startinsert!
endfunction

nnoremap <leader>cd :!lualatex %

function! IsEnvironment(lineNumber, environment)
    let saveCursor = getpos('.')

    call cursor(a:lineNumber, 0)

    let beginLinePrevious = search('\\begin{' . a:environment . '}',"bnW")
    if beginLinePrevious == 0
        call setpos('.',saveCursor)
        return 0
    endif

    let endLinePrevious = search('\\end{' . a:environment . '}', "bnW")
    if endLinePrevious >= beginLinePrevious 
        call setpos('.',saveCursor)
        return 0
    endif

    call setpos('.',saveCursor)
    return 1
endfunction




