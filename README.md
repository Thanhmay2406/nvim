# Neovim Configuration

Một cấu hình Neovim viết bằng Lua, chia nhỏ theo module và cài plugin trực tiếp
bằng `vim.pack`.

Repo này hiện tập trung vào 4 nhóm chức năng:

- chỉnh giao diện và hành vi editor cơ bản,
- LSP + completion,
- tìm kiếm bằng Telescope,
- workflow Python notebook với Molten, Jupytext và Kaggle CLI.

## Trạng thái hiện tại

Những gì đang được cấu hình trong code:

- Theme `catppuccin` với flavour `mocha`.
- Toggle nền trong suốt bằng `<leader>tt`.
- Completion bằng `blink.cmp`.
- LSP qua `nvim-lspconfig` + `mason.nvim`.
- Treesitter cho một nhóm ngôn ngữ cố định.
- Telescope để tìm file, buffer, grep, help, man page.
- Render Markdown cơ bản bằng `render-markdown.nvim`.
- Chạy cell Python kiểu notebook bằng `molten-nvim`.
- Hiển thị ảnh output notebook qua `image.nvim` với backend `kitty`.
- Nhóm phím tắt bằng `which-key.nvim`.

Những gì README cũ có nói nhưng code hiện tại không cấu hình rõ ràng, nên không
còn được hứa hẹn ở đây:

- không có phần cấu hình Mermaid riêng,
- không có phần cài parser hay dependency Markdown tự động,
- không có workflow quản lý notebook ngoài các lệnh Jupytext/Kaggle đã viết,
- không có plugin manager bên thứ ba như `lazy.nvim` hay `packer.nvim`.

## Yêu cầu

Tối thiểu:

- Neovim đủ mới để có `vim.pack`, `vim.system`, `vim.lsp.config`.
- `git`.
- Nerd Font nếu muốn icon hiển thị đẹp.
- công cụ clipboard hệ thống cho `unnamedplus`.

Phụ trợ theo tính năng:

- `ripgrep` cho `Telescope live_grep`.
- Python 3 nếu muốn dùng Python host riêng của Neovim.
- `kitty` và ImageMagick nếu muốn hiển thị ảnh từ notebook output.
- `jupytext` nếu muốn pair/sync `.py` với `.ipynb`.
- `kaggle` CLI nếu muốn dùng các lệnh Kaggle kernel.

Nếu tồn tại file `~/.config/nvim/.venv-nvim/bin/python`, Neovim sẽ tự dùng nó
làm `python3_host_prog`.

## Cài đặt

```sh
git clone <repository-url> ~/.config/nvim
nvim
```

Khi khởi động, các module trong `init.lua` sẽ lần lượt gọi `vim.pack.add(...)`
để tải plugin cần thiết.

Nếu bạn muốn Neovim tự update plugin khi mở lên, bỏ comment dòng này trong
`init.lua`:

```lua
-- vim.pack.update()
```

## Cấu trúc

```text
.
├── init.lua
├── README.md
├── nvim-pack-lock.json
└── lua/config
    ├── diagnostics.lua
    ├── globals.lua
    ├── keymaps.lua
    ├── options.lua
    ├── pack.lua
    └── plugins
        ├── autopairs.lua
        ├── colorscheme.lua
        ├── completion.lua
        ├── lsp.lua
        ├── markdown.lua
        ├── notebook.lua
        ├── telescope.lua
        ├── treesitter.lua
        └── which-key.lua
```

`init.lua` chỉ nạp module. Cấu hình editor cơ bản nằm trong `lua/config/`, còn
plugin nằm trong `lua/config/plugins/`.

## Plugin đang dùng

| Plugin | Vai trò |
| --- | --- |
| `catppuccin/nvim` | Colorscheme |
| `saghen/blink.lib` | Dependency cho `blink.cmp` |
| `saghen/blink.cmp` | Completion |
| `windwp/nvim-autopairs` | Tự đóng ngoặc và dấu nháy |
| `neovim/nvim-lspconfig` | Khai báo và bật LSP |
| `mason-org/mason.nvim` | Quản lý tool/LSP server |
| `mason-org/mason-lspconfig.nvim` | Cầu nối Mason và LSP |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Tự cài các server đã khai báo |
| `nvim-treesitter/nvim-treesitter` | Treesitter parser/runtime |
| `nvim-lua/plenary.nvim` | Dependency cho Telescope |
| `nvim-tree/nvim-web-devicons` | Icon |
| `nvim-telescope/telescope.nvim` | Tìm kiếm |
| `folke/snacks.nvim` | Hỗ trợ hiển thị ảnh |
| `MeanderingProgrammer/render-markdown.nvim` | Render Markdown trong buffer |
| `3rd/image.nvim` | Hiển thị ảnh cho notebook output |
| `benlubas/molten-nvim` | Chạy code notebook trong buffer Python |
| `folke/which-key.nvim` | Gợi ý nhóm phím |

## Thiết lập editor

Các option nổi bật hiện có:

- bật `termguicolors`,
- `number` + `relativenumber`,
- đồng bộ clipboard với hệ điều hành,
- lưu `undofile`,
- `signcolumn = "yes"`,
- hiển thị ký tự trắng,
- `cursorline`,
- `wrap` + `breakindent`,
- indent 2 spaces,
- `textwidth = 80`,
- fold theo indent và mở sẵn với `foldlevel = 99`.

Phím chung hiện có:

- `<Esc>`: bỏ highlight của search.
- `<leader>tt`: bật/tắt nền trong suốt của `catppuccin`.

## LSP

Các server đang được khai báo:

- `lua_ls`
- `pyright`
- `clangd`
- `rust_analyzer`
- `gopls`
- `marksman`

Mason được cấu hình để đảm bảo các server trên được cài.

Keymap khi LSP attach:

- `grd`: nhảy tới definition
- `grf`: format buffer

## Treesitter

Lệnh `:TSInstallConfigured` sẽ cài parser cho:

```text
lua, vim, vimdoc, c, cpp, python, javascript, typescript,
html, css, json, markdown, markdown_inline, yaml, latex
```

Khi mở file thuộc các filetype trên, config sẽ gọi `vim.treesitter.start()`.

## Telescope

Các phím tìm kiếm đang có:

- `<leader>sp`: danh sách builtin picker
- `<leader>sb`: buffer
- `<leader>sf`: file
- `<leader>sw`: grep từ dưới con trỏ
- `<leader>sg`: live grep
- `<leader>sr`: resume picker trước
- `<leader>sh`: help tags
- `<leader>sm`: man pages

## Python Notebook

Workflow hiện tại dùng file `.py` với marker `# %%`.

Các capability chính:

- chạy cell hiện tại bằng Molten,
- pair/sync với `.ipynb` bằng Jupytext,
- attach vào Jupyter Server có sẵn qua URL,
- gọi Kaggle CLI ngay từ Neovim để init/push/pull/status/output.

### Lệnh notebook

- `:JupytextPair`
- `:JupytextSync`
- `:JupytextToIpynb`
- `:JupyterRunCell`
- `:JupyterServerSet [url]`
- `:JupyterServerConnect [url]`

### Lệnh Kaggle

- `:KaggleKernelInit`
- `:KaggleKernelPush`
- `:KaggleKernelPull [owner/slug]`
- `:KaggleKernelStatus [owner/slug]`
- `:KaggleKernelFiles [owner/slug]`
- `:KaggleKernelOutput [owner/slug]`

Config sẽ ưu tiên đọc `kernel-metadata.json` để suy ra `owner/slug`. Nếu không
có, nó sẽ hỏi thủ công.

Output tải từ Kaggle được đặt trong thư mục `kaggle-output/` cạnh notebook, trừ
khi bạn tự override `vim.g.kaggle_output_dirname`.

### Keymap trong file Python

- `<leader>ji`: khởi tạo Molten kernel local
- `<leader>ju`: attach qua Jupyter Server URL
- `<leader>jU`: lưu Jupyter Server URL cho session hiện tại
- `<leader>jc`: chạy cell hiện tại
- `<leader>jl`: chạy dòng hiện tại
- `<leader>jr`: chạy lại cell Molten đang active
- `<leader>jo`: mở output
- `<leader>je`: vào cửa sổ output
- `<leader>jx`: interrupt execution
- `<leader>jd`: xóa cell output đang active
- `<leader>jv`: chạy vùng chọn visual
- `<leader>jp`: pair Jupytext
- `<leader>js`: sync Jupytext
- `<leader>jb`: export sang `.ipynb`
- `<leader>ki`: `KaggleKernelInit`
- `<leader>kp`: `KaggleKernelPush`
- `<leader>kl`: `KaggleKernelPull`
- `<leader>ks`: `KaggleKernelStatus`
- `<leader>kf`: `KaggleKernelFiles`
- `<leader>ko`: `KaggleKernelOutput`
- `]j`: nhảy tới marker `# %%` tiếp theo
- `[j`: nhảy tới marker `# %%` trước đó

## Ghi chú

- `nvim-pack-lock.json` là lockfile plugin snapshot, nhưng có thể chứa mục cũ
  nếu bạn vừa đổi plugin mà chưa refresh lock.
- Repo này hiện không có bước bootstrap dependency tự động; các binary như
  `jupytext`, `kaggle`, `magick` hay browser cho terminal image rendering cần có
  sẵn trong máy nếu bạn dùng các tính năng đó.
