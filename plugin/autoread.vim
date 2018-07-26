if has('nvim')
	" NOTE: nvimのautoreadは自動的に上書きをしてしまう
	set noautoread
	let b:pre_timestamp=-1
	function! s:checktime()
		let filepath=resolve(expand('%:p'))
		if !filereadable(filepath)
			return
		endif
		if has('mac')
			let b:timestamp=0+substitute(system('stat -f %m '.filepath),'\n','','')
		elseif !has('win')
			let b:timestamp=0+substitute(system('stat -c %Y '.filepath),'\n','','')
		endif
		if b:pre_timestamp==-1
			let b:pre_timestamp=b:timestamp
			return
		endif
		if b:pre_timestamp < b:timestamp
			" reload
			:edit!
		endif
		let b:pre_timestamp = b:timestamp
	endfunction
	command! Checktime call <SID>checktime()
	augroup file_autoread_checktime
		au!
		" gvim has auto reload function
		if !has("gui_running")
			"silent! necessary otherwise throws errors when using command line window.
			autocmd BufEnter      * silent! call <SID>checktime()
			autocmd CursorHold    * silent! call <SID>checktime()
			autocmd CursorHoldI   * silent! call <SID>checktime()
			"these two _may_ slow things down. Remove if they do.
			autocmd CursorMoved   * silent! call <SID>checktime()
			autocmd CursorMovedI  * silent! call <SID>checktime()
			" 			au FocusLost,WinLeave * :silent! noautocmd w
			" 			au FocusLost,WinLeave * :silent! w
		endif
	augroup END
else
	set autoread
	augroup file_autoread_checktime
		au!
		" gvim has auto reload function
		if !has("gui_running")
			"silent! necessary otherwise throws errors when using command line window.
			autocmd BufEnter     <buffer> * silent! checktime
			autocmd CursorHold   <buffer> * silent! checktime
			autocmd CursorHoldI  <buffer> * silent! checktime
			"these two _may_ slow things down. Remove if they do.
			autocmd CursorMoved  <buffer> * silent! checktime
			autocmd CursorMovedI <buffer> * silent! checktime
			" 			au FocusLost,WinLeave * :silent! noautocmd w
			" 			au FocusLost,WinLeave * :silent! w
		endif
	augroup END
endif
