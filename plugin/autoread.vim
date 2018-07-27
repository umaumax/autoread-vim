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
			autocmd BufEnter      * silent! call <SID>checktime()
			autocmd CursorHold    * silent! call <SID>checktime()
			autocmd CursorHoldI   * silent! call <SID>checktime()
			"these two _may_ slow things down. Remove if they do.
			autocmd CursorMoved   * silent! call <SID>checktime()
			autocmd CursorMovedI  * silent! call <SID>checktime()
		endif
	augroup END
else
	set autoread
	augroup file_autoread_checktime
		au!
		" gvim has auto reload function
		if !has("gui_running")
			"silent! necessary otherwise throws errors when using command line window.
			autocmd BufEnter      * silent! checktime
			autocmd CursorHold    * silent! checktime
			autocmd CursorHoldI   * silent! checktime
			"these two _may_ slow things down. Remove if they do.
			autocmd CursorMoved   * silent! checktime
			autocmd CursorMovedI  * silent! checktime
			" 			au FocusLost,WinLeave * :silent! noautocmd w
			" 			au FocusLost,WinLeave * :silent! w
		endif
	augroup END
endif
