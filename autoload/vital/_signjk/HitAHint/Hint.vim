" function() wrapper
if v:version > 703 || v:version == 703 && has('patch1170')
  let s:_function = function('function')
else
  function! s:_SID() abort
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
  endfunction
  let s:_s = '<SNR>' . s:_SID() . '_'
  function! s:_function(fstr) abort
    return function(substitute(a:fstr, 's:', s:_s, 'g'))
  endfunction
endif

function! s:_assert(...) abort
  return ''
endfunction

function! s:_vital_loaded(V) abort
  if a:V.exists('Vim.PowerAssert')
    let s:assert = a:V.import('Vim.PowerAssert').assert
  else
    let s:assert = s:_function('s:_assert')
  endif
endfunction

" TERMS:
"   key: A character to generate hint. e.g. a,b,c,d,e,f,...
"   hint: A hint is a combination of keys. e.g. a,b,ab,abc,..

" s:create() assigns keys to each targets and generate hint dict.
" Example:
"   let targets = [1, 2, 3, 4, 5, 6]
"   echo s:label(targets, ['a', 'b', 'c'])
"   " => {
"     'a': 1,
"     'b': {
"       'a': 2,
"       'b': 3
"     },
"     'c': {
"       'a': 4,
"       'b': 5,
"       'c': 6
"     }
"   }
"   Hint-to-target:
"     a  -> 1
"     ba -> 2
"     bb -> 3
"     ca -> 4
"     cb -> 5
"     cc -> 6
" @param {list<T>} targets
" @param {list<string>} keys each key should be uniq
" @return Tree{string: (T|Tree)}
function! s:create(targets, keys) abort
  exe s:assert('len(a:keys) > 1')
  let groups = {}
  let keys_count = reverse(s:_keys_count(len(a:targets), len(a:keys)))

  let target_idx = 0
  let key_idx = 0
  for key_count in keys_count
    if key_count > 1
      " We need to create a subgroup
      " Recurse one level deeper
      let sub_targets = a:targets[target_idx : target_idx + key_count - 1]
      let groups[a:keys[key_idx]] = s:create(sub_targets, a:keys)
    elseif key_count == 1
      " Assign single target key_idx
      let groups[a:keys[key_idx]] = a:targets[target_idx]
    else
      " No target
      continue
    endif
    let key_idx += 1
    let target_idx += key_count
  endfor
  return groups
endfunction

" s:_keys_count() generates list which represents how many targets to be
" assigned to the key.
" If the count > 1, use tree recursively.
" Example:
"   echo s:_keys_count(5, 3)
"   " => [3, 1, 1]
"   echo s:_keys_count(8, 3)
"   " => [3, 3, 2]
" @param {number} target_len
" @param {number} keys_len
function! s:_keys_count(targets_len, keys_len) abort
  exe s:assert('a:keys_len > 1')
  let _keys_count = repeat([0], a:keys_len)
  let is_first_level = 1
  let targets_left_cnt = a:targets_len
  while targets_left_cnt > 0
    let cnt_to_add = is_first_level ? 1 : a:keys_len - 1
    for i in range(a:keys_len)
      let _keys_count[i] += cnt_to_add
      let targets_left_cnt -= cnt_to_add
      if targets_left_cnt <= 0
        let _keys_count[i] += targets_left_cnt 
        break
      endif
    endfor
    let is_first_level = 0
  endwhile
  exe s:assert('len(_keys_count) is# a:keys_len')
  return _keys_count
endfunction
