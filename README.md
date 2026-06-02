# Neovim Configuration

Cấu hình Neovim gọn nhẹ, viết bằng Lua và chia thành các module độc lập.
Plugin được cài trực tiếp bằng `vim.pack`, không cần plugin manager bên thứ ba.

## Tính năng chính

- Giao diện Catppuccin Mocha với nền trong suốt.
- Gợi ý code, tài liệu và signature help bằng `blink.cmp`.
- LSP cho Lua, C/C++, Rust, Go và Markdown.
- Tự động cài LSP server bằng Mason.
- Highlight cú pháp bằng Treesitter.
- Render Markdown, ảnh, công thức LaTeX và sơ đồ Mermaid ngay trong Kitty.
- Tìm file, buffer, nội dung và tài liệu bằng Telescope.
- Tự đóng ngoặc và dấu nháy bằng `nvim-autopairs`.
- Hiển thị nhóm phím tắt bằng `which-key.nvim`.
- Lưu undo history và đồng bộ clipboard với hệ điều hành.

## Yêu cầu

### Chung

- Neovim có hỗ trợ `vim.pack` và `vim.lsp.config`.
- `git` để tải plugin.
- `ripgrep` để Telescope tìm kiếm nội dung bằng live grep.
- Một công cụ clipboard như `xclip`, `xsel` hoặc `win32yank`.
- Nerd Font để hiển thị icon.

### Markdown

- Kitty để hiển thị ảnh inline trong terminal.
- ImageMagick để chuyển đổi định dạng ảnh.
- Mermaid CLI (`mmdc`) để generate sơ đồ Mermaid.
- Google Chrome hoặc Chromium để Mermaid CLI generate hình ảnh.
- Tectonic hoặc `pdflatex` để render công thức LaTeX.
- Tree-sitter CLI để cài parser `latex`.

Trên Arch Linux, có thể cài các dependency Markdown bằng:

```sh
sudo pacman -S --needed kitty imagemagick tectonic tree-sitter-cli chromium nodejs npm
sudo npm install -g @mermaid-js/mermaid-cli
```

Nếu đã cài Google Chrome thì không cần cài thêm Chromium. Module Markdown tự
động tìm `google-chrome-stable`, `google-chrome`, `chromium` hoặc
`chromium-browser`.

Cấu hình hiện tại đã được kiểm tra với Neovim `0.12.2`, Kitty `0.47.1`,
Tectonic `0.16.9`, Tree-sitter CLI `0.26.9` và Mermaid CLI `11.15.0`.

## Cài đặt

Sao lưu cấu hình cũ nếu cần, sau đó clone repository vào thư mục cấu hình
Neovim:

```sh
git clone <repository-url> ~/.config/nvim
nvim
```

Trong lần khởi động đầu tiên, `vim.pack` tải và nạp plugin. Mason tiếp tục cài
các LSP server đã khai báo, bao gồm `marksman` cho Markdown.

Để cài các Treesitter parser được cấu hình sẵn, chạy lệnh sau bên trong
Neovim:

```vim
:TSInstallConfigured
```

## Cấu trúc thư mục

```text
.
├── init.lua
├── nvim-pack-lock.json
└── lua/config/
    ├── diagnostics.lua
    ├── globals.lua
    ├── keymaps.lua
    ├── options.lua
    ├── pack.lua
    └── plugins/
        ├── autopairs.lua
        ├── colorscheme.lua
        ├── completion.lua
        ├── lsp.lua
        ├── markdown.lua
        ├── telescope.lua
        ├── treesitter.lua
        └── which-key.lua
```

`init.lua` chỉ nạp các module. Cấu hình editor cơ bản nằm trong `lua/config/`,
còn phần cài đặt và thiết lập plugin nằm trong `lua/config/plugins/`.

## Plugin

| Plugin | Vai trò |
| --- | --- |
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Colorscheme Catppuccin Mocha |
| [saghen/blink.cmp](https://github.com/saghen/blink.cmp) | Completion, documentation và signature help |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Tự đóng ngoặc và dấu nháy |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Cấu hình LSP server |
| [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) | Quản lý công cụ phát triển |
| [mason-org/mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Kết nối Mason với LSP |
| [WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Tự động cài LSP server |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Parsing và highlight cú pháp |
| [folke/snacks.nvim](https://github.com/folke/snacks.nvim) | Hiển thị ảnh, LaTeX và Mermaid inline trong Kitty |
| [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Render thành phần Markdown trong buffer |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Tìm kiếm tương tác |
| [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | Icon cho giao diện plugin |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim) | Gợi ý nhóm phím tắt |

`plenary.nvim` và `blink.lib` được cài làm dependency cho Telescope và
`blink.cmp`.

## Ngôn ngữ hỗ trợ

### LSP

| Ngôn ngữ | LSP server |
| --- | --- |
| Lua | `lua_ls` |
| C/C++ | `clangd` |
| Rust | `rust_analyzer` |
| Go | `gopls` |
| Markdown | `marksman` |

Các server này được Mason cài tự động khi khởi động Neovim.

### Treesitter

Lệnh `:TSInstallConfigured` cài parser cho:

```text
lua, vim, vimdoc, c, cpp, python, javascript, typescript,
html, css, json, markdown, markdown_inline, yaml, latex
```

## Markdown

`render-markdown.nvim` cải thiện cách hiển thị heading, bảng, checkbox, quote,
code block và link. `snacks.nvim` sử dụng Kitty Graphics Protocol để hiển thị
ảnh, công thức LaTeX và sơ đồ Mermaid ngay trong buffer.

Handler chuyển LaTeX sang ký tự Unicode của `render-markdown.nvim` được tắt để
tránh render trùng lặp. Công thức LaTeX được `snacks.nvim` biên dịch thành ảnh
bằng Tectonic.

````markdown
![Ảnh local](./images/example.png)

```mermaid
flowchart LR
  A --> B
```

```math
E = mc^2
```
````

Lần render LaTeX đầu tiên có thể chậm hơn bình thường vì Tectonic cần tải
bundle TeX vào cache.

### Kitty và tmux

Khi chạy Neovim trực tiếp trong Kitty, ảnh inline hoạt động qua Kitty Graphics
Protocol. Nếu dùng tmux, có thể cần thêm cấu hình sau:

```tmux
set -gq allow-passthrough on
```

### Kiểm tra

Nếu ảnh, LaTeX hoặc Mermaid không hiển thị, chạy:

```vim
:checkhealth snacks
:checkhealth render-markdown
```

Mermaid CLI cần Chrome hoặc Chromium. Nếu trình duyệt không được tự động tìm
thấy, đặt biến môi trường trước khi mở Neovim:

```sh
export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
```

## Phím tắt

Phím leader là `<Space>`.

### Chung

| Phím | Chế độ | Chức năng |
| --- | --- | --- |
| `<Esc>` | Normal | Xóa highlight của kết quả tìm kiếm |
| `<Space>tt` | Normal | Bật hoặc tắt nền trong suốt |

### Telescope

| Phím | Chức năng |
| --- | --- |
| `<Space>sp` | Mở danh sách picker |
| `<Space>sb` | Tìm buffer |
| `<Space>sf` | Tìm file |
| `<Space>sw` | Tìm từ đang đặt con trỏ |
| `<Space>sg` | Tìm nội dung bằng live grep |
| `<Space>sr` | Tiếp tục lần tìm kiếm gần nhất |
| `<Space>sh` | Tìm tài liệu trợ giúp |
| `<Space>sm` | Tìm man page |

### LSP

Các phím sau khả dụng khi LSP đã attach vào buffer:

| Phím | Chức năng |
| --- | --- |
| `grd` | Đi tới definition |
| `grf` | Format buffer |

### Completion

| Phím | Chức năng |
| --- | --- |
| `<C-p>` | Chọn gợi ý trước |
| `<C-n>` | Chọn gợi ý tiếp theo |
| `<C-y>` | Chấp nhận gợi ý |
| `<C-e>` | Đóng danh sách gợi ý |
| `<C-Space>` | Hiển thị completion hoặc documentation |
| `<Tab>` | Đi tới vị trí snippet tiếp theo |
| `<S-Tab>` | Quay lại vị trí snippet trước |
| `<C-b>` | Cuộn documentation lên |
| `<C-f>` | Cuộn documentation xuống |
| `<C-k>` | Hiển thị hoặc ẩn signature help |

## Thiết lập editor

- Hiển thị line number tuyệt đối và tương đối.
- Sử dụng indentation 2 spaces và chuyển tab thành spaces.
- Hiển thị ký tự whitespace.
- Luôn hiển thị sign column cho diagnostic.
- Hiển thị diagnostic bằng icon và virtual text.
- Preview lệnh substitute trong split riêng.
- Bật mouse, cursor line, line wrapping và persistent undo.
- Dùng clipboard hệ điều hành qua `unnamedplus`.

## Quản lý plugin

Helper `lua/config/pack.lua` gọi `vim.pack.add()` với `confirm = false` và
`load = true`. Plugin mới được khai báo trong module tương ứng rồi nạp từ
`init.lua`.

Phiên bản plugin được lưu trong `nvim-pack-lock.json`. Để bật cập nhật plugin
tự động khi khởi động, bỏ comment dòng sau ở cuối `init.lua`:

```lua
vim.pack.update()
```
