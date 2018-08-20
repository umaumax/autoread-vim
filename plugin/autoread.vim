" NOTE: 1sec interval or while using terryma/vim-multiple-cursors
" NOTE: reltimestr(reltime())
let g:pre_second=-1
function! s:check_update_interval()
	if g:pre_second==strftime('%c')
		return 0
	endif
	let g:pre_second=strftime('%c')
	if get(g:, 'multi_cursor_inputing', 0)
		return 0
	endif
	return 1
endfunction

if has('nvim')
	" NOTE: nvimのautoreadは自動的に上書きをしてしまう
	set noautoread
	let b:pre_timestamp=-1
	function! s:gettimestamp(filepath)
		if !filereadable(a:filepath)
			return -1
		endif
		if has('mac')
			let timestamp=0+substitute(system('stat -f %m '.a:filepath),'\n','','')
		elseif !has('win')
			let timestamp=0+substitute(system('stat -c %Y '.a:filepath),'\n','','')
		endif
		return timestamp
	endfunction
	function! s:updatetime(timestamp)
		let b:pre_timestamp = a:timestamp
	endfunction
	function! s:update_this_file_time()
		let filepath=resolve(expand('%:p'))
		let timestamp = s:gettimestamp(filepath)
		if timestamp == -1
			return
		endif
		call s:updatetime(timestamp)
	endfunction
	function! s:checktime()
		let filepath=resolve(expand('%:p'))
		let timestamp = s:gettimestamp(filepath)
		if timestamp == -1
			return
		endif
		if b:pre_timestamp==-1
			call s:updatetime(timestamp)
			return
		endif
		if b:pre_timestamp < timestamp
			" reload
			:edit!
			" NOTE: 次のreloadがないと，更新があった状態で:を押下してcmdlineモードに入ったときに画面の状態が更新されない
			:redraw!
		endif
		call s:updatetime(timestamp)
	endfunction
	command! Checktime call <SID>checktime()
	augroup file_autoread_checktime
		au!
		" gvim has auto reload function
		if !has("gui_running")
			autocmd BufWritePost * silent! call <SID>update_this_file_time()
			"silent! necessary otherwise throws errors when using command line window.
			autocmd BufEnter * silent! call <SID>checktime()

			" NOTE: terryma/vim-multiple-cursors often leave insert mode
			autocmd CursorHold,CursorHoldI,InsertEnter,InsertLeave,CmdlineEnter,CmdLineLeave *
						\		if s:check_update_interval()
						\|		silent! call <SID>checktime()
						\|	endif
			"these two _may_ slow things down. Remove if they do.
			" autocmd CursorMoved   * silent! call <SID>checktime()
			" autocmd CursorMovedI  * silent! call <SID>checktime()
		endif
	augroup END
else
	" NOTE: normal vim
	set autoread
	augroup file_autoread_checktime
		au!
		" gvim has auto reload function
		if !has("gui_running")
			"silent! necessary otherwise throws errors when using command line window.
			autocmd BufEnter      * silent! checktime
			autocmd CursorHold,CursorHoldI,InsertEnter,InsertLeave,CmdlineEnter,CmdLineLeave *
						\		if s:check_update_interval()
						\|		silent! checktime
						\|	endif
			"these two _may_ slow things down. Remove if they do.
			" 			autocmd CursorMoved   * silent! checktime
			" 			autocmd CursorMovedI  * silent! checktime
		endif
	augroup END
endif
