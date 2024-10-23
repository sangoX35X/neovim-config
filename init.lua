-- options
	-- auto
	-- backup
	-- encoding
	-- indent
	-- looks
	-- searching
	-- others
-- functions
-- keymaps
-- autocmds
-- plugins
	-- lazy.nvim
	-- libraries
	-- ai
	-- lsp
	-- treesitter
	-- git
	-- mini
	-- ddc
	-- ddu
	-- skkeleton
	-- utils
	-- looks
	-- nvimTree
	-- language

local vim = vim
local api = vim.api
local opt = vim.opt
local key = vim.keymap

--#options
--##options-auto
--opt.autoread = true
opt.autochdir = true
--opt.autowrite = false
--opt.autowriteall = false
--##backup
--opt.backup = false
--opt.backupcopy = "auto"
--opt.backupdir = ""
--[[ autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		opt.backupext = os.date(".backup-%Y%m%d%H%M%S")
	end
}) --]]
--##options-encoding
opt.encoding = "UTF-8"
opt.fileencodings = "UTF-8,UTF-16,UTF-32,SHIFT-JIS"
--##options-indent
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = -1
opt.shiftwidth = 0
opt.expandtab = false
--##options-looks
opt.ambiwidth = "single"
opt.helplang = "ja,en"
opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.cursorcolumn = true
opt.termguicolors = true
opt.pumblend = 20
opt.listchars = {
--	eol = "↵",
	tab = "│  ",
	space = "･",
	multispace = "│ ",
	trail = "␣",
	extends = "➙"
}
opt.list = true
opt.wrap = false
--##options-searching
opt.wrapscan = true
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true
--##options-others
opt.clipboard = "unnamedplus"
opt.virtualedit = "block"

--#functions
local function char_at_cursor(horizontal_relative_position, vertical_relative_position)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	row = row + (vertical_relative_position or 0)
	col = col + (horizontal_relative_position or 0) + 1 -- 1-indexed
	local line = api.nvim_buf_get_lines(0, row - 1, row, false)[1]
	local result = string.sub(line, col, col)
	if result == "" then
		return nil
	end
	return result
end

--#keymaps
vim.g.mapleader = " "

key.set({'i', 'c'}, "<C-l>", "<Esc>")
key.set('t', "<C-l>", "<C-\\><C-n>")
key.set({'n', 'v'}, "L", "$")
key.set({'n', 'v'}, "H", "0")
key.set('n', "dL", "d$")
key.set('n', "dH", "d0")
key.set('n', "cL", "c$")
key.set('n', "cH", "c0")
-- NOTE: followings are setted by "mini.basics"
-- key.set({'i', 'c', 't'}, "<A-h>", "<Left>")
-- key.set({'i', 'c', 't'}, "<A-j>", "<Down>")
-- key.set({'i', 'c', 't'}, "<A-k>", "<Up>")
-- key.set({'i', 'c', 't'}, "<A-l>", "<Right>")
-- key.set('n', "<C-h>", "<C-w>h")
-- key.set('n', "<C-j>", "<C-w>j")
-- key.set('n', "<C-k>", "<C-w>k")
-- key.set('n', "<C-l>", "<C-w>l")
key.set('n', "<C-S-k>", "<Cmd>tabNext<CR>")
key.set('n', "<C-S-j>", "<Cmd>tabprevious<CR>")
-- local function toggle_hlsearch ()
-- 	if opt.hlsearch:get() then
-- 		opt.hlsearch = false
-- 	else
-- 		opt.hlsearch = true
-- 	end
-- 	cmd.redraw()
-- end
-- key.set({'n', 'v'}, "<Leader>s", toggle_hlsearch)
--#autocmds
local changeMultispace = function ()
	local tabstop = vim.opt.tabstop:get()
	local listchars = vim.opt.listchars:get()
	listchars.multispace = "│" .. string.rep(" ", tabstop - 1)
	vim.opt_local.listchars = listchars
end
vim.api.nvim_create_autocmd(
	"OptionSet",
	{
		pattern = "tabstop",
		callback = changeMultispace
	}
)
vim.api.nvim_create_autocmd(
	{
		"BufNewFile",
		"BufRead"
	},
	{
		pattern = "*",
		callback = changeMultispace
	}
)

--#plugins
--##plugins-lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath
	}
end
vim.opt.rtp:prepend(lazypath)
local plugins = {
--##plugins-libraries
	{ "nvim-lua/plenary.nvim", lazy = true },
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			vim.api.nvim_create_autocmd(
				"Colorscheme",
				{
					callback = require"nvim-web-devicons".refresh
				}
			)
		end
	},
	{ "neovim/nvim-lspconfig", lazy = true },
--##plugins-ai
	{
		"github/copilot.vim",
		config = function ()
			vim.g.copilot_no_maps = true
			key.set('i', "<C-c><C-c>", "copilot#Accept('<CR>')", { expr = true, silent = true, replace_keycodes = false })
			key.set('i', "<C-c>w", "<Plug>(copilot-accept-word)")
			key.set('i', "<C-c>l", "<Plug>(copilot-accept-line)")
		end
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		build = "make tiktoken",
		opts = {
			debug = true
		}
	},
	{
		"codota/tabnine-vim",
		enabled = false,
		build = [=[
			export PYENV_ROOT="$HOME/.pyenv"
			[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
			eval "$(pyenv init -)"
			pyenv shell 3.7
			./install.sh
		]=]
	},
--##plugins-lsp
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		dependencies = {
			"mfussenegger/nvim-dap",
			{
				"rcarriga/nvim-dap-ui",
				dependencies = {
					"mfussenegger/nvim-dap",
					"nvim-neotest/nvim-nio"
				},
				config = true
			}
		},
		opts = {
			ui = {
				icons = {
					package_installed = "󰏗",
					package_uninstalled = "󱧖",
					package_pending = "󰇚"
				}
			}
		}
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = { },
		config = function ()
			require("mason-lspconfig").setup_handlers {
				function (server_name)
					require("lspconfig")[ server_name ].setup { }
				end
			}
		end
	},
	{
		"nvimdev/lspsaga.nvim",
		lazy = false,
		opts = {
			ui = {
				code_action = ""
			}
		},
		keys = {
			{"<Leader>ls<Space>", ":Lspsaga "},
			{"<Leader>lsa", "<Cmd>Lspsaga code_action<CR>"},
			{"<Leader>lsdb", "<Cmd>Lspsaga show_buf_diagnostics<CR>"},
			{"<Leader>lsdc", "<Cmd>Lspsaga show_cursor_diagnostics<CR>"},
			{"<Leader>lsdl", "<Cmd>Lspsaga show_line_diagnostics<CR>"},
			{"<Leader>lsdw", "<Cmd>Lspsaga show_workspace_diagnostics<CR>"},
			{"<Leader>lsf", "<Cmd>Lspsaga finder<CR>"},
			{"<Leader>lsk", "<Cmd>Lspsaga hover_doc<CR>"},
			{"<Leader>lso", "<Cmd>Lspsaga outline<CR>"},
			{"<Leader>lsr", "<Cmd>Lspsaga rename<CR>"},
			{"<Leader>lssb", "<Cmd>Lspsaga subtypes<CR>"},
			{"<Leader>lssp", "<Cmd>Lspsaga supertypes<CR>"},
			{"<Leader>lst", "<Cmd>Lspsaga term_toggle<CR>"},
			{"<Leader>lsw", "<Cmd>Lspsaga winbar_toggle<CR>"},
		},
		config = true
	},
	{
		"dense-analysis/ale",
		cond = false
	},
--##plugins-treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = "all",
			sync_install = true
		}
	},
--##plugins-git
	{
		"tpope/vim-fugitive",
		cmd = "Git",
		keys = {
			{"<Leader>g<Space>", ":Git "},
			{"<Leader>gc", "<Cmd>Git commit<CR>"},
			{"<Leader>gps", "<Cmd>Git push<CR>"}
		},
		config = function ()
			vim.api.nvim_create_autocmd(
				"FileType",
				{
					pattern = {
						"gitcommit",
						"fugitive"
					},
					callback = function ()
						vim.opt_local.number = false
						vim.opt_local.relativenumber = false
						vim.opt_local.signcolumn = "no"
					end
				}
			)
		end
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			on_attach = function (bufnr)
				local gitsigns = require"gitsigns"
				vim.g.mapleader = " "
				vim.keymap.set("n", "<Leader>ghs", gitsigns.stage_hunk, { buffer = bufnr })
				vim.keymap.set("n", "<Leader>ghr", gitsigns.reset_hunk, { buffer = bufnr })
				vim.keymap.set(
					"v",
					"<Leader>ghs",
					function() gitsigns.stage_hunk { vim.fn.line".", vim.fn.line"v" } end,
					{ buffer = bufnr }
				)
				vim.keymap.set(
					"v",
					"<Leader>ghr",
					function() gitsigns.reset_hunk { vim.fn.line".", vim.fn.line"v" } end,
					{ buffer = bufnr }
				)
				vim.keymap.set("n", "<Leader>gss", gitsigns.stage_buffer, { buffer = bufnr })
				vim.keymap.set("n", "<Leader>ghS", gitsigns.undo_stage_hunk, { buffer = bufnr })
				vim.keymap.set("n", "<Leader>grr", gitsigns.reset_buffer, { buffer = bufnr })
				vim.keymap.set("n", "<Leader>ghp", gitsigns.preview_hunk, { buffer = bufnr })
				vim.keymap.set("n", "<Leader>gb", gitsigns.toggle_current_line_blame, { buffer = bufnr })
				vim.keymap.set("n", "<Leader>gdf", gitsigns.diffthis, { buffer = bufnr })
				vim.keymap.set(
					"n",
					"<Leader>gD",
					function() gitsigns.diffthis {"~"} end,
					{ buffer = bufnr }
				)
				vim.keymap.set("n", "<Leader>gdl", gitsigns.toggle_deleted, { buffer = bufnr })
			end
		}
	},
--##plugins-mini
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function ()
			require("mini.animate").setup()
			require("mini.basics").setup {
				options = {
					basic = true,
					extra_ui = true,
					win_borders = "bold"
				},
				mappings = {
					basic = true,
					option_toggle_prefix = [[\]],
					windows = true,
					move_with_alt = true
				},
				autocommands = {
					basic = true,
					relnum_in_visual_mode = true
				},
				silent = false
			}
			require("mini.bracketed").setup()
			require("mini.colors").setup()
			vim.cmd.Colorscheme("kanagawa-wave")
			require("mini.comment").setup {
				options = {
					ignore_blank_line = true
				}
			}
			require("mini.cursorword").setup()
			require("mini.files").setup()
			vim.keymap.set(
				"n",
				"<Leader>me",
				function ()
					MiniFiles.open()
				end
			)
			require("mini.hipatterns").setup {
				highlighters = {
					fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
					hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
					todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
					note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
					hex_color = require("mini.hipatterns").gen_highlighter.hex_color()
				}
			}
			require("mini.indentscope").setup {
				symbol = "┃"
			}
			require("mini.jump").setup()
			require("mini.jump2d").setup()
			vim.keymap.set(
				"n",
				"<Leader>mf",
				function ()
					MiniJump2d.start()
				end
			)
			require("mini.move").setup()
			require("mini.pairs").setup()
			require("mini.splitjoin").setup()
			require("mini.starter").setup()
			require("mini.statusline").setup()
			require("mini.surround").setup()
			require("mini.tabline").setup()
			require("mini.trailspace").setup()
		end
	},
	{
		"kylechui/nvim-surround",
		config = true
	},
--##plugins-ddc
	{
		"Shougo/ddc.vim",
		dependencies = {
			"vim-denops/denops.vim",
			{
				"Shougo/pum.vim",
				config = function()
					vim.fn["pum#set_option"] {
						border = "rounded",
						auto_select = true,
						max_width = 50,
						max_height = 15,
						blend = 20
					}
					vim.keymap.set(
						{ "i", "c" },
						"<C-n>",
						function ()
							if vim.fn["pum#visible"]() then
								vim.fn["pum#map#select_relative"](1)
							else
								return "<C-n>"
							end
						end,
						{ expr = true }
					)
					vim.keymap.set(
						{ "i", "c" },
						"<C-p>",
						function ()
							if vim.fn["pum#visible"]() then
								vim.fn["pum#map#select_relative"](-1)
							else
								return "<C-p>"
							end
						end,
						{ expr = true }
					)
					vim.keymap.set(
						{ "i", "c" },
						"<C-y>",
						function ()
							if vim.fn["pum#visible"]() then
								vim.fn["pum#map#confirm"]()
							else
								return "<C-y>"
							end
						end,
						{ expr = true }
					)
					vim.keymap.set(
						{ "i", "c" },
						"<C-e>",
						function ()
							if vim.fn["pum#visible"]() then
								vim.fn["pum#map#cancel"]()
							else
								return "<C-e>"
							end
						end,
						{ expr = true }
					)
				end
			},
			"Shougo/ddc-ui-pum",
			{
				"matsui54/denops-popup-preview.vim",
				config = function()
					vim.fn["popup_preview#enable"]()
				end
			},
			"matsui54/denops-signature_help",
			--sources
			"Shougo/ddc-around",
			"LumaKernel/ddc-file",
			{
				"Shougo/ddc-source-lsp",
				dependencies = {
					"hrsh7th/vim-vsnip",
					"uga-rosa/ddc-source-vsnip",
				},
			},
			"matsui54/ddc-source-buffer",
			"Shougo/ddc-source-cmdline-history",
			"Shougo/ddc-source-cmdline",
			{
				"Shougo/ddc-source-copilot",
				dependencies = {
					"github/copilot.vim"
				}
			},
			"Shougo/ddc-source-line",
			"Shougo/ddc-source-input",
			-- "statiolake/ddc-ale",
			-- "LumaKernel/ddc-tabnine",
			"Shougo/neco-vim",
			--filers
			"Shougo/ddc-converter_remove_overlap",
			"tani/ddc-fuzzy",
			"Shougo/ddc-filter-matcher_head",
			"Shougo/ddc-filter-sorter_rank",
			"ttak0422/ddc-sorter_itemsize"
		},
		config = function ()
			vim.fn["ddc#custom#patch_global"]("ui", "pum")
			vim.fn["ddc#custom#patch_global"] {
				sources = {
					-- "tabnine",
					"lsp",
					-- "ale",
					"file",
					"buffer",
					"around",
					"copilot"
				},
				sourceOptions = {
					_ = {
						matchers = {
							"matcher_fuzzy"
						},
						sorters = {
							"sorter_itemsize"
						},
						converters = {
							"converter_remove_overlap",
							"converter_fuzzy"
						}
					},
					tabnine = {
						mark = "󰬁 Tabnine"
					},
					lsp = {
						mark = "󰒋 LSP",
						forceCompletionPattern = {[['\.\w*|:\w*|->\w*']]}, -- {[["%.%w*|:%w*|->%w*"]]},
						sorters = {
							"sorter_lsp-detail-size",
							"sorter_lsp-kind"
						}
					},
					ale = {
						mark = " ALE"
					},
					around = {
						mark = "󰦨 Around"
					},
					file = {
						mark = " File",
					},
					buffer = {
						mark = "󰌨 Buffer",
						maxAutoCompleteLength = 32
					},
					copilot = {
						mark = " Copilot"
					},
					["cmdline-history"] = {
						mark = "󰋚 History"
					},
					cmdline = {
						mark = " Command"
					},
					necovim = {
						mark = " neco"
					}
				},
				sourceParams = {
					lsp = {
						snippetEngine = vim.fn["denops#callback#register"](function(body) vim.fn["vsnip#anonymous"](body) end),
						enableResolveItem = true,
						enableAdditionalTextEdit = true
					}
				},
				cmdlineSources = {
					[":"] = {"necovim", "cmdline-history", "cmdline"},
					['@'] = {'cmdline-history', 'input', 'file', 'around'},
					['>'] = {'cmdline-history', 'input', 'file', 'around'},
					['/'] = {'around', 'line'},
					['?'] = {'around', 'line'},
					['-'] = {'around', 'line'},
					['='] = {'input'}
				},
				postFilters = {
					"converter_remove_overlap",
					"sorter_rank",
					"sorter_fuzzy"
				},
				filterParams = {
				}
			}
			vim.fn["ddc#enable"]();
			vim.keymap.set(
				{
					"n"
				},
				":",
				"<Cmd>call ddc#enable_cmdline_completion()<CR>:"
			)
			vim.keymap.set(
				"i",
				"<Tab>",
				function ()
					local char = char_at_cursor(-1, 0)
					if vim.fn["pum#visible"]() then
						-- vim.fn["pum#map#select_relative"](1)
						return "<Cmd>call pum#map#select_relative(1)<CR>"
					elseif not char or char:match("%s") then
						return "<Tab>"
					else
						-- vim.fn["ddc#map#manual_complete"]()
						return "<Cmd>call ddc#map#manual_complete()<CR>"
					end
				end,
				{ expr = true }
			)
			vim.keymap.set(
				"i",
				"<S-Tab>",
				function ()
					local char = char_at_cursor(0, -1)
					if vim.fn["pum#visible"]() then
						-- vim.fn["pum#map#select_relative"](-1)
						return "<Cmd>call pum#map#select_relative(-1)<CR>"
					else
						-- vim.fn["ddc#map#manual_complete"]()
						return "<Cmd>call ddc#map#manual_complete()<CR>"
					end
				end,
				{ expr = true }
			)
			vim.keymap.set(
				"c",
				"<Tab>",
				function ()
					if vim.fn["pum#visible"]() then
						vim.fn["pum#map#insert_relative"](1)
					else
						vim.fn["ddc#map#manual_complete"]()
					end
				end
			)
			vim.keymap.set(
				"c",
				"<S-Tab>",
				function ()
					if vim.fn["pum#visible"]() then
						vim.fn["pum#map#insert_relative"](-1)
					else
						return "\t"
					end
				end
			)
		end
	},
--##plugins-ddu
	{
		"Shougo/ddu.vim",
		cmd = "Ddu",
		dependencies = {
			"vim-denops/denops.vim",
			--ui
			"Shougo/ddu-ui-ff",
			"Shougo/ddu-ui-filer",
			--sources
			"Shougo/ddu-source-file",
			"Shougo/ddu-source-file_rec",
			"Shougo/ddu-source-line",
			"Shougo/ddu-source-register",
			"shun/ddu-source-rg",
			"shun/ddu-source-buffer",
			"uga-rosa/ddu-source-lsp",
			--filters
			"yuki-yano/ddu-filter-fzf",
			--kinds
			"Shougo/ddu-kind-file",
			"Shougo/ddu-kind-word",
			--others
			"ryota2357/ddu-column-icon_filename",
			"Shougo/ddu-commands.vim"
		},
		config = function()
			local function set_ff_keymaps(args)
				vim.keymap.set("n", "q", function() vim.fn["ddu#ui#do_action"]("quit") end, { buffer = args.buf })
				vim.keymap.set("n", "<C-j>", function() vim.fn["ddu#ui#do_action"]("itemAction") end, { buffer = args.buf })
				vim.keymap.set("n", "o", function() vim.fn["ddu#ui#do_action"]("expandItem", { mode = "toggle" }) end, { buffer = args.buf })
				vim.keymap.set("n", "c", function() vim.fn["ddu#ui#do_action"]("toggleSelectItem") end, { buffer = args.buf })
				vim.keymap.set("n", "C", function() vim.fn["ddu#ui#do_action"]("toggleAllItems") end, { buffer = args.buf })
				vim.keymap.set("n", "a", function() vim.fn["ddu#ui#do_action"]("toggleAutoAction") end, { buffer = args.buf })
				vim.keymap.set("n", "i", function() vim.fn["ddu#ui#do_action"]("openFilterWindow") end, { buffer = args.buf })
			end
			vim.api.nvim_create_autocmd(
				"FileType",
				{
					pattern = "ddu-ff",
					callback = set_ff_keymaps
				}
			)
			local function set_filer_keymaps(args)
				vim.keymap.set(
					"n",
					"o",
					function ()
						local item = vim.fn["ddu#ui#get_item"]()
						if item.isTree then
							vim.fn["ddu#ui#do_action"]("expandItem", { mode = "toggle" })
						elseif item.action.isDirectory then
						else
							vim.fn["ddu#ui#do_action"]("itemAction", { name = "open" })
						end
					end,
					{ buffer = 0 }
				)
				vim.keymap.set("n", "K", function() vim.fn["ddu#ui#do_action"]("preview") end, { buffer = args.buf })
				vim.keymap.set("n", "j", "gj<Cmd>call ddu#ui#do_action('preview')<CR>", { buffer = args.buf })
				vim.keymap.set("n", "k", "gk<Cmd>call ddu#ui#do_action('preview')<CR>", { buffer = args.buf })
				vim.keymap.set("n", "q", function() vim.fn["ddu#ui#do_action"]("quit") end, { buffer = args.buf })
				vim.keymap.set("n", "y", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "copy"} ) end, { buffer = args.buf })
				vim.keymap.set("n", "p", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "paste"} ) end, { buffer = args.buf })
				vim.keymap.set("n", "r", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "rename"} ) end, { buffer = args.buf })
				vim.keymap.set("n", "ad", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "newDirectory"} ) end, { buffer = args.buf })
				vim.keymap.set("n", "af", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "newFile"} ) end, { buffer = args.buf })
				vim.keymap.set("n", "Y", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "yank"} ) end, { buffer = args.buf })
			end
			vim.api.nvim_create_autocmd({"FileType"}, {
				pattern = "ddu-filer",
				callback = set_filer_keymaps
			})
			vim.fn["ddu#custom#patch_global"] {
				ui = "ff",
				uiParams = {
					ff = {
						autoAction = {
							name = "preview",
							delay = 0
						},
						displaySourceName = "full",
						displayTree = true,
						floatingBorder = "single",
						previewFloating = true,
						previewFloatingBorder = "double",
						prompt = " >",
						split = "floating",
						statusline = false,
					},
					filer = {
						sort = "filename",
						split = "floating",
						floatingBorder = "single",
						previewFloating = true,
						previewFloatingBorder = "double"
					}
				},
				sourceOptions = {
					_ = {
						matchers = {
							"matcher_fzf"
						},
						sorters = {
							"sorter_fzf"
						},
						ignoreCase = true
					},
					file = {
						columns = {
							"icon_filename"
						}
					},
					file_rec = {
						columns = {
							"icon_filename"
						}
					},
					rg = {
						matchers = {},
						volatile = true,
					}
				},
				filterParams = {
					matcher_fzf = {
						highlightMatched = "Search"
					},
					rg = {
						args = { "--column", "--no-heading", "--color never", "--smart-case", "--json" },
					}
				},
				kindOptions = {
					file = {
						defaultAction = "open"
					},
					word = {
						defaultAction = "append"
					},
					lsp = {
						defaultAction = "open"
					},
					lsp_codeAction = {
						defaultAction = "apply"
					}
				},
				actionOptions = {
					_ = {
						quit = true
					}
				}
			}
			vim.fn["ddu#custom#patch_local"]("filer", {
				ui = "filer",
				sources = { "file" }
			})
			vim.fn["ddu#custom#patch_local"]("f", {
				ui = "ff",
				sources = { "file", "line", "register", "rg", "buffer" }
			})
			vim.fn["ddu#custom#patch_local"]("ff", {
				ui = "ff",
				sources = { "file" }
			})
			vim.fn["ddu#custom#patch_local"]("ffr", {
				ui = "ff",
				sources = { "file_rec" }
			})
			vim.fn["ddu#custom#patch_local"]("rg", {
				ui = "ff",
				sources = { "rg" }
			})
		end
	},
--##plugins-skkeleton
	{
		"vim-skk/skkeleton",
		dependencies = {
			"vim-denops/denops.vim",
			{
				"delphinus/skkeleton_indicator.nvim",
				config = true
			}
		},
		--NOTE: this does not work well
		-- keys = {
		-- 	{
		-- 		"<C-s>",
		-- 		"<Plug>(skkeleton-toggle)",
		-- 		mode = {"i", "c", "t"}
		-- 	}
		-- },
		config = function ()
			vim.keymap.set(
				{'c', 'i', "t"},
				"<C-s>",
				"<Plug>(skkeleton-toggle)"
			)
			vim.fn["skkeleton#config"] {
				globalDictionaries = {
					"~/.skk/SKK-JISYO.L"
				},
				keepState = false,
			}
		end
	},
--##plugins-utils
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			open_mapping = "<Leader>tt",
			insert_mappings = false,
			terminal_mappings = false
		}
	},
	{
		"uga-rosa/translate.nvim",
		config = function()
			vim.keymap.set(
				{'v', 'n'},
				"<Leader>tj",
				"<Cmd>Translate ja<CR>"
			)
			vim.keymap.set(
				{'v', 'n'},
				"<Leader>te",
				"<Cmd>Translate en<CR>"
			)
		end
	},
	{
		"guns/xterm-color-table.vim",
		cmd = "XtermColorTable"
	},
--##plugins-looks
	{
		"rebelot/heirline.nvim",
		cond = false,
		opts = {
			statusline = { },
			-- winbar = { },
			tabline = { },
			-- statuscolumn = { },
			opts = { }
		}
	},
	{
		"folke/edgy.nvim",
		init = function ()
			vim.opt.laststatus = 3
			vim.opt.splitkeep = "screen"
		end,
		opts = {
			options = {
				left = {
					size = 30
				},
				right = {
					size = 0.2
				},
				bottom = {
					size = 0.25
				}
			},
			left = {
				{
					ft = "NvimTree"
				}
			},
			bottom = {
				{
					ft = "toggleterm",
					filter = function ()
						return vim.b.toggleterm_use == nil
					end
				}
			},
			right = {
				{
					ft = "help",
					size = { width = 78 }
				},
				{
					ft = "copilot-chat",
				},
				{
					ft = "fugitive"
				},
				{
					ft = "gitcommit",
					size = { width = 70 }
				},
				{
					ft = "sagaoutline"
				}
			},
			top = { }
		}
	},
	{
		"rebelot/kanagawa.nvim",
		config = true
	},
--##plugins-nvimTree
	{
		"nvim-tree/nvim-tree.lua",
		opts = {
			view = {
				width = 30,
				preserve_window_proportions = true
			}
		}
	},
--##plugins-language
	{
		"sheerun/vim-polyglot",
		init = function()
			vim.g.polyglot_disabled = { }
		end
	},
	{
		"alaviss/nim.nvim",
		ft = "nim"
	},
	{
		"glebzlat/arduino-nvim",
		ft = "arduino",
		config = true
	},
	{
		"scalameta/nvim-metals",
		ft = { "scala", "sbt", "java" },
		opts = function()
			local metals_config = require("metals").bare_config()
			metals_config.on_attach = function(client, bufnr)
			end
			return metals_config
		end,
		config = function(self, metals_config)
			local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = self.ft,
				callback = function()
					require("metals").initialize_or_attach(metals_config)
				end,
				group = nvim_metals_group
			})
		end
	},
	{
		"evanleck/vim-svelte",
		ft = "svelte"
	},
	{
		"lervag/vimtex",
		init = function()
			vim.g.vimtex_indent_enabled = 0
		end,
		ft = {
			"tex",
			"latex"
		}
	},
	{
		"jdonaldson/vaxe",
		ft = {
			"hxml",
			"haxe"
		}
	}
}
require("lazy").setup(plugins, {
	performance = {
		rtp = {
			disabled_plugins = {
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
			}
		}
	}
})
