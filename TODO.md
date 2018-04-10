TODO
====

* :new で任意のサイズのウィンドウを作成した後、'curwin' オプションつきで `term_start`する
* 選択した Visual 領域を初期 word にして fzf を開始する

### MEMO:

* (パイプで繋げない)コマンド単独動作の場合、 windows だとフルパスで表示され、Linux では 相対パスで表示される

Basic Usage
-----------

* Run `:NNN` or `:NNN [starting-directory]` to invoke NNN in find file mode.
* Run `:NNN Buffer` or `:NNN MRU` to invoke NNN in find buffer or find MRU
file mode.
* Run `:NNN Mixed` to search in Files, Buffers and MRU files at the same
time.

Check `:help ctrlp-commands` and `:help ctrlp-extensions` for other commands.

### Once NNN is open:

* ~~Press `<F5>` to purge the cache for the current directory to get new files, remove deleted files and apply new ignore options.~~
* Press `<C-f>` and `<C-b>` to cycle between modes.
* ~~Press `<C-d>` to switch to filename only search instead of full path.~~
* Press `<C-r>` to switch ~~to regexp mode~~ search mode(exntended-search, extended-search with exact match, non-extended-search).
* Use `<C-j>`, `<C-k>` or the arrow keys to navigate the result list.
* Use `<C-t>` or `<C-v>`, `<C-x>` to open the selected entry in a new tab or in a new split by default.
* Use `<C-n>`, `<C-p>` to select the next/previous string in the prompt's history.
* Use `<C-y>` to create a new file and its parent directories.
* Use ~~`<C-z>`~~ `<Tab>` or `<C-i>` to mark/unmark multiple files and ~~`<C-o>`~~ `<CR>` to open them.
