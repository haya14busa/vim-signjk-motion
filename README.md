signjk-motion
=============

`:sign` version of `<Plug>(easymotion-j)` and `<Plug>(easymotion-k)` in [easymotion/vim-easymotion](https://github.com/easymotion/vim-easymotion).

![](https://raw.githubusercontent.com/haya14busa/i/1a24362e8b9eaeb94ad3265da0e6d0cfedc00177/misc/signjk.gif)

USAGE
-----

```vim
map <Leader>j <Plug>(signjk-j)
map <Leader>k <Plug>(signjk-k)
```

ADVANCED USAGE
--------------

![](https://raw.githubusercontent.com/haya14busa/i/7b6415c5d5a40b8b389eeadd3374956af7304fff/misc/signjk_textobj_lines.gif)

```vim
omap L <Plug>(textobj-signjk-lines)
vmap L <Plug>(textobj-signjk-lines)
```
