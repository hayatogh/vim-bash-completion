let g:bashcompletion_use_aliases = 1
let g:bashcompletion_use_functions = 1
let g:bashcompletion_redirections = ['<', '>', '&>']

let s:completer = expand('<sfile>:p:h') . '/../completer.sh '
if $WSL_DISTRO_NAME != '' || $MSYSTEM != ''
	let s:env = slice(substitute($PATH . ':', '\v\/(mnt\/)?c\/[^:]+:', '', 'g'), 0, -1)
	let s:completer = 'PATH=' . s:env . ' ' . s:completer
	unlet s:env
endif

let s:aliases = []
if g:bashcompletion_use_aliases
	let s:aliases = split(system("3>&1 &>/dev/null bash -ic '1>&3 echo ${!BASH_ALIASES[@]}'"))
endif
let s:funcs = []
if g:bashcompletion_use_functions
	let s:funcs = filter(map(systemlist("3>&1 &>/dev/null bash -ic '1>&3 declare -F'"), 'split(v:val)[2]'), 'v:val !~# ''^_''')
endif
let s:icomps = uniq(sort(extend(s:aliases, s:funcs)))
unlet s:aliases s:funcs

function! g:bash#complete(part)
	if a:part == ''
		return ''
	endif
	let l:quote_part = join(map(split(a:part . ' ', ' '), '"''" . v:val . "''"'))
	let l:comps = systemlist(s:completer . l:quote_part)
	let l:icomps_filtered = filter(copy(s:icomps), 'v:val =~# ''^' . a:part . '''')
	let l:comps = uniq(sort(extend(l:comps, l:icomps_filtered)))
	for l:redir in g:bashcompletion_redirections
		if split(a:part, ' ')[-1] =~# '^' . l:redir
			let l:comps = map(l:comps, '"' . l:redir . '" . v:val')
			break
		endif
	endfor
	return l:comps
endfunction
