let s:axisLineOptions = { "optionBase": "axislines=", "options" : [
            \ "left",
            \ "box",
            \ "middle",
            \ "center",
            \ "right",
            \ "none", ] }


let s:colorOptions = { "optionBase": "color=", "options": [
            \ "red",
            \ "green",
            \ "blue",
            \ "cyan",
            \ "magenta",
            \ "yellow",
            \ "black",
            \ "gray",
            \ "white",
            \ "darkgray",
            \ "lightgray",
            \ "brown",
            \ "lime",
            \ "olive",
            \ "orange",
            \ "pink",
            \ "purple",
            \ "teal",
            \ "violet" ] }

let s:linestyles = [
            \ "solid",
            \ "dotted",
            \ "densely dotted",
            \ "loosely dotted",
            \ "dashed",
            \ "densely dashed",
            \ "loosely dashed",
            \ "dashdotted",
            \ "densely dashdotted",
            \ "loosely dashdotted",
            \ "dashdotdotted",
            \ "densely dashdotdotted",
            \ "loosely dashdotdotted",
            \ ]
            
let s:markoptions = {"optionBase": "mark=", "options": [
            \ "*",
            \ "x",
            \ "+",
            \ "-",
            \ "|",
            \ "o",
            \ "asterisk",
            \ "star",
            \ "pointed star",
            \ "oplus",
            \ "oplus*",
            \ "otimes",
            \ "otimes*",
            \ "square",
            \ "square*",
            \ "triangle",
            \ "triangle*",
            \ "diamond",
            \ "diamond*",
            \ "halfsquare*",
            \ "halfsquare right*",
            \ "halfsquare left*",
            \ "Mercedes star",
            \ "Mercedes star flipped",
            \ "halfcircle",
            \ "halfcircle*",
            \ "pentagon",
            \ "pentagon*",
            \ "ball",
            \ "text",
            \ "cube",
            \ "cube*",
            \ ]
            \ }

let s:colSepOptions = {"optionBase": "colsep=", "options": [
            \ "space",
            \ "tab",
            \ "comma",
            \ "colon",
            \ "semicolon",
            \ "braces",
            \ "&",
            \ "ampersand",
            \ ]
            \ }

let s:gridOptions =  {"optionBase": "grid=", "options": [
            \ "major",
            \ "both",
            \ "none",
            \ "minor"
            \ ]
            \ }
" Quickly wrap selection (in visual mode) or current 
" WORD (in normal mode) as italic.
vnoremap <leader>ti di\textit{<c-r>"}<esc>
nnoremap <leader>ti diWi\textit{<c-r>"}<esc>

" Quickly wrap selection as bold.
vnoremap <leader>tb di\textbf{<c-r>"}<esc>
nnoremap <leader>tb diWi\textbf{<c-r>"}<esc>

" Auto close inline equation.
inoremap \( \(\)<esc>hi

nnoremap <leader>tpac :<c-u>call <SID>FlipTikzOmniComplete()<cr>

function! s:FlipTikzOmniComplete()
    if &omnifunc !~# "TikzPlotComplete"
        let g:TikzPlotOmniCompleteBackup = &omnifunc
        let &omnifunc="TikzPlotComplete"
    else 
        let &omnifunc = g:TikzPlotOmniCompleteBackup
    endif
    echo "omnifunc is now " . &omnifunc
endfunction

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
                        \ "grid style",
                        \ "minor grid style",
                        \ "major grid style",
                        \ "grid",
                        \ "minor xtick",
                        \ "minor ytick",
                        \ "mark",
                        \ "xmajorgrids",
                        \ "ymajorgrids",
                        \ "zmajorgrids",
                        \ "xminorgrids",
                        \ "yminorgrids",
                        \ "zminorgrids",
                        \ "width",
                        \ "height",
                        \ ] 

            let possibleOptions = possibleOptions + s:linestyles

            let equalTypeOptions = [s:markoptions, s:colSepOptions, s:gridOptions, s:colorOptions, s:axisLineOptions]

            let trimmedBase = substitute(a:base,'\s\+',"","g")
            for equalTypeOption in equalTypeOptions
                if trimmedBase ==? equalTypeOption["optionBase"]
                    return map(equalTypeOption["options"], 'a:base . v:val . ","')
                endif
            endfor

            let results = []
            for possibleOption in possibleOptions
                if trimmedBase ==? "line"  || trimmedBase ==? "linetype" || trimmedBase ==? "linestyle"
                    return s:linestyles
                endif
                
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




