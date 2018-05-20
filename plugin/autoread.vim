set autoread
augroup file_autoread_checktime
	au!
	if !has("gui_running")
		"silent! necessary otherwise throws errors when using command line window.
		autocmd BufEnter      * silent! checktime
		autocmd CursorHold    * silent! checktime
		autocmd CursorHoldI   * silent! checktime
		"these two _may_ slow things down. Remove if they do.
		autocmd CursorMoved   * silent! checktime
		autocmd CursorMovedI  * silent! checktime
		au FocusLost,WinLeave * :silent! noautocmd w
		au FocusLost,WinLeave * :silent! w
	endif
augroup END
