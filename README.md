# Collection of basic configuration files

```
.
├── .bashrc
├── .ccls
├── .clang-format
├── .gitconfig
├── .gitignore
├── .ripgreprc
├── .tmux.conf
├── .zshrc
├── README.md
├── default.ctags
├── init.el
└── init.vim
```

> Tree is generated by:
`tree -I "$(cat .gitignore|tr '\n' '|').git" -a`

<BR/>

## Summary

* Bash configuration, serves as base for Z shell too
* ccls: C/C++ language server, used in Emacs/vi
* Clang formatter settings for C/C++
* Common git config with shortcuts, diff & merge tools
* Ignore patterns for git to avoid tracing unwanted/temporary files
* Basic ripgrep config. Ripgrep is a more feature rich replacement to grep
* tmux configuration. Shows warning on older tmux
	* Explore if there is compatibility for copy-mode-vi
* Basic *Z* shell (zsh) config built on Bash config
* Universal ctags configuration to limit tag generation for few languages
	* This avoids picking definitions from non-programming language files
	* Treat Cython as Python
* Basic Emacs customization. Depends on package manager to fetch packages on demand from MELPA/ELPA
* Basic common vim/neovim configuration. Warns on very old vim versions