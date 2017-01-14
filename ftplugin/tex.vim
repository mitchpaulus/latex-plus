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


