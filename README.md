# Neovim Configuration

Cấu hình Neovim gọn nhẹ, viết bằng Lua và chia thành các module độc lập.
Plugin được cài trực tiếp bằng `vim.pack`, không cần plugin manager bên thứ ba.

## Tính năng chính

- Giao diện Catppuccin Mocha với nền trong suốt.
- Gợi ý code, tài liệu và signature help bằng `blink.cmp`.
- LSP cho Lua, C/C++, Rust và Go.
- Tự động cài LSP server bằng Mason.
- Highlight cú pháp bằng Treesitter.
- Tìm file, buffer, nội dung và tài liệu bằng Telescope.
- Tự đóng ngoặc và dấu nháy bằng `nvim-autopairs`.
- Hiển thị nhóm phím tắt bằng `which-key.nvim`.
- Lưu undo history và đồng bộ clipboard với hệ điều hành.

## Yêu cầu

- Neovim có hỗ trợ `vim.pack` và `vim.lsp.config`.
- `git` để tải plugin.
- `ripgrep` để Telescope tìm kiếm nội dung bằng live grep.
- Một công cụ clipboard như `xclip`, `xsel` hoặc `win32yank`.
- Nerd Font để hiển thị icon.

Cấu hình hiện tại đã được kiểm tra với Neovim `0.12.2`.

## Cài đặt

Sao lưu cấu hình cũ nếu cần, sau đó clone repository vào thư mục cấu hình
Neovim:

```sh
git clone <repository-url> ~/.config/nvim
nvim
```

Trong lần khởi động đầu tiên, `vim.pack` sẽ tải và nạp plugin. Mason tiếp tục
cài các LSP server đã khai báo.

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

Các server này được Mason cài tự động khi khởi động Neovim.

### Treesitter

Lệnh `:TSInstallConfigured` cài parser cho:

```text
lua, vim, vimdoc, c, cpp, python, javascript, typescript,
html, css, json, markdown, markdown_inline
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
