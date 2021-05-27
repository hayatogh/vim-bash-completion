let s:completer = expand('<sfile>:p:h') . '/../completer.sh '
if $WSL_DISTRO_NAME != '' || $MSYSTEM != ''
	let s:env = slice(substitute($PATH . ':', '\v\/(mnt\/)?c\/[^:]+:', '', 'g'), 0, -1)
	let s:completer = 'PATH=' . s:env . ' ' . s:completer
endif


function! g:bash#complete(part)
	if a:part == ''
		return ''
	endif
	let l:quote_part = join(map(split(a:part . ' ', ' '), '"''" . v:val . "''"'))
	let l:filtered = s:filter(systemlist(s:completer . l:quote_part))
	if split(a:part, ' ')[-1] =~# '^<'
		let l:filtered = map(l:filtered, '"<" . v:val')
	endif
	return l:filtered
endfunction

function! s:filter(list)
	let l:set = {}
	let l:newlist = []
	for l:index in range(len(a:list))
		if !has_key(l:set, a:list[l:index])
			let l:set[a:list[l:index]] = ""
			let l:newlist += [a:list[l:index]]
		endif
	endfor
	return l:newlist
endfunction
