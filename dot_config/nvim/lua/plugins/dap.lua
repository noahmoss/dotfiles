return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
			"mfussenegger/nvim-dap-python",
			"leoluz/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local dap_python = require("dap-python")

			require("nvim-dap-virtual-text").setup({
				commented = true,
			})

			dap_python.setup("python3")
			require("dap-go").setup()
			dapui.setup()

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			local opts = { noremap = true, silent = true }
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, opts)
			vim.keymap.set("n", "<leader>dc", dap.continue, opts)
			vim.keymap.set("n", "<leader>do", dap.step_over, opts)
			vim.keymap.set("n", "<leader>di", dap.step_into, opts)
			vim.keymap.set("n", "<leader>dO", dap.step_out, opts)
			vim.keymap.set("n", "<leader>dq", dap.terminate, opts)
			vim.keymap.set("n", "<leader>du", dapui.toggle, opts)
			vim.keymap.set("n", "<leader>dt", function()
				require("dap-go").debug_test()
			end, opts)
		end,
	},
}
