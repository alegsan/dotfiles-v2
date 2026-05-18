return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionActions",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "MeanderingProgrammer/render-markdown.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
    opts = {
      adapters = {
        http = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-sonnet-4.6",
                },
              },
            })
          end,
        },
      },

      interactions = {
        chat = {
          adapter = "copilot",
        },

        inline = {
          adapter = "copilot",
        },

        cmd = {
          adapter = {
            name = "copilot",
            model = "claude-haiku-4.5",
          },
        },

        background = {
          adapter = {
            name = "copilot",
            model = "claude-haiku-4.5",
          },
          chat = {
            callbacks = {
              ["on_ready"] = {
                actions = {
                  "interactions.background.builtin.chat_make_title",
                },
                -- Enable "on_ready" callback which contains the title generation action
                enabled = true,
              },
            },
            opts = {
              -- Enable background interactions generally
              enabled = true,
            },
          },
        },

        cli = {
          agent = "copilot",
          agents = {
            copilot = {
              cmd = "copilot",
              args = {},
              description = "Copilot CLI",
              provider = "terminal",
            },
          },
        },
      },

      prompt_library = {
        ["Caveman Mode"] = {
          interaction = "chat",
          description = "Start a caveman-mode chat (75% fewer tokens)",
          opts = {
            alias = "caveman",
            is_slash_cmd = true,
            auto_submit = false,
          },
          prompts = {
            {
              role = "system",
              content = function()
                local skill_path = vim.fn.expand("~/.agents/skills/caveman/SKILL.md")
                if vim.fn.filereadable(skill_path) == 1 then
                  local lines = vim.fn.readfile(skill_path)
                  local content = table.concat(lines, "\n")
                  -- strip YAML front-matter (--- ... ---)
                  content = content:gsub("^---%s*\n.-\n---%s*\n", "")
                  return content
                end
                return "Talk like caveman. Drop filler. Keep all technical accuracy."
              end,
            },
            {
              role = "user",
              content = "/caveman activated. Full caveman mode. Acknowledge briefly.",
            },
          },
        },
        ["PR Review"] = {
          interaction = "chat",
          description = "Structured PR code review (Linux kernel, U-Boot, ...)",
          opts = {
            alias = "pr-review",
            auto_submit = false,
          },
          tools = {
            "run_command",
            "files",
            opts = {
              auto_submit_errors  = true,
              auto_submit_success = true,
            },
          },
          prompts = {
            {
              role = "user",
              content = function()
                -- set by <leader>ar keymap via async snacks picker
                local chosen_file = vim.g._pr_review_profile
                if not chosen_file or chosen_file == "" then
                  vim.notify("[PR Review] No profile selected", vim.log.levels.WARN)
                  return nil
                end
                vim.g._pr_review_profile = nil

                local pr_url = vim.fn.input("PR URL: ")
                if pr_url == "" then return nil end

                -- Yocto: optionally review a related sublayer PR together
                local pr_url2 = ""
                if chosen_file == "profile-yocto.md" then
                  pr_url2 = vim.fn.input("Sublayer PR URL (leave empty to skip): ")
                end

                local pr_urls_section = "**PR URL:** " .. pr_url
                if pr_url2 ~= "" then
                  pr_urls_section = pr_urls_section
                    .. "\n**Sublayer PR URL:** " .. pr_url2
                    .. "\n**Note:** These two PRs are related — the main project PR includes a submodule update pointing to the sublayer PR. Review both together: check that the submodule pointer in the main PR matches the HEAD commit of the sublayer PR, and that the changes in both are consistent."
                end

                local subsystem = vim.fn.input("Subsystem (leave empty for auto): ")
                if subsystem == "" then subsystem = "auto" end

                local dir = vim.fn.stdpath("config") .. "/reviews"
                local ok1, profile_lines = pcall(vim.fn.readfile, dir .. "/" .. chosen_file)
                local ok2, base_lines    = pcall(vim.fn.readfile, dir .. "/base.md")
                if not ok1 or not ok2 then
                  vim.notify("[PR Review] Could not read profile files in " .. dir, vim.log.levels.ERROR)
                  return nil
                end
                return table.concat(profile_lines, "\n")
                  .. "\n\n---\n\n"
                  .. table.concat(base_lines, "\n")
                  .. "\n\n---\n\n"
                  .. pr_urls_section .. "\n"
                  .. "**SUBSYSTEM:** " .. subsystem
              end,
            },
          },
        },
        markdown = {
          dirs = {
            vim.fn.stdpath("config") .. "/prompts",
          },
        },
      },

      opts = {
        log_level = "DEBUG",
      },

      extensions = {
        history = {
          enabled = true,
          opts = {
            -- Keymap to open history from chat buffer (default: gh)
            keymap = "gh",
            -- Keymap to save the current chat manually (when auto_save is disabled)
            save_chat_keymap = "sc",
            -- Save all chats by default (disable to save only manually using 'sc')
            auto_save = false,
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 0,
            -- Picker interface (auto resolved to a valid picker)
            picker = "snacks", --- ("telescope", "snacks", "fzf-lua", or "default")
            ---Optional filter function to control which chats are shown when browsing
            chat_filter = nil, -- function(chat_data) return boolean end
            -- Customize picker keymaps (optional)
            picker_keymaps = {
              rename = { n = "r", i = "<M-r>" },
              delete = { n = "d", i = "<M-d>" },
              duplicate = { n = "<C-y>", i = "<C-y>" },
            },
            ---Automatically generate titles for new chats
            auto_generate_title = true,
            title_generation_opts = {
              ---Adapter for generating titles (defaults to current chat adapter)
              adapter = nil, -- "copilot"
              ---Model for generating titles (defaults to current chat model)
              model = "gpt-4o",
              ---Number of user prompts after which to refresh the title (0 to disable)
              refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
              ---Maximum number of times to refresh the title (default: 3)
              max_refreshes = 3,
              format_title = function(original_title)
                -- this can be a custom function that applies some custom
                -- formatting to the title.
                return original_title
              end,
            },
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            ---Enable detailed logging for history extension
            enable_logging = false,

            -- Summary system
            summary = {
              -- Keymap to generate summary for current chat (default: "gcs")
              create_summary_keymap = "gcs",
              -- Keymap to browse summaries (default: "gbs")
              browse_summaries_keymap = "gbs",

              generation_opts = {
                adapter = nil, -- defaults to current chat adapter
                model = "gpt-4o",
                context_size = 90000, -- max tokens that the model supports
                include_references = true, -- include slash command content
                include_tool_outputs = true, -- include tool execution results
                system_prompt = nil, -- custom system prompt (string or function)
                format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
              },
            },

            -- Memory system (requires VectorCode CLI)
            memory = {
              -- Automatically index summaries when they are generated
              auto_create_memories_on_summary_generation = true,
              -- Path to the VectorCode executable
              vectorcode_exe = "vectorcode",
              -- Tool configuration
              tool_opts = {
                -- Default number of memories to retrieve
                default_num = 10,
              },
              -- Enable notifications for indexing progress
              notify = true,
              -- Index all existing memories on startup
              -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
              index_on_startup = false,
            },
          },
        },
      },
    },

    keys = {
      {
        "<leader>av",
        function()
          require("codecompanion").prompt("caveman")
        end,
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "AI Chat (caveman mode)",
      },
      {
        "<leader>aa",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "AI Chat",
      },
      {
        "<leader>ac",
        "<cmd>CodeCompanionActions<cr>",
        mode = "n",
        noremap = true,
        silent = true,
        desc = "AI Actions",
      },
      {
        "<leader>ae",
        "<cmd>CodeCompanion<cr>",
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "AI Inline",
      },
      {
        "<leader>ag",
        "<cmd>CodeCompanionCmd<cr>",
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "AI Command",
      },
      {
        "ga",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = "v",
        noremap = true,
        silent = true,
        desc = "AI Add to Chat",
      },
      {
        "<leader>as",
        function()
          local chat = require("codecompanion.interactions.chat").buf_get_chat(0)
          require("codecompanion._extensions.history").exports.generate_summary(chat)
        end,
        mode = "n",
        noremap = true,
        silent = true,
        desc = "AI Generate Summary",
      },
      {
        "<leader>ar",
        function()
          local profiles = {
            { label = "Linux Kernel", file = "profile-linux.md" },
            { label = "U-Boot",       file = "profile-uboot.md" },
            { label = "Yocto/OE",     file = "profile-yocto.md" },
            { label = "Zephyr RTOS",  file = "profile-zephyr.md" },
            { label = "PTXdist",      file = "profile-ptxdist.md" },
          }
          vim.ui.select(profiles, {
            prompt = "Select review profile",
            format_item = function(p) return p.label end,
          }, function(p)
            if not p then return end
            vim.g._pr_review_profile = p.file
            require("codecompanion").prompt("pr-review")
          end)
        end,
        mode = "n",
        noremap = true,
        silent = true,
        desc = "AI PR Review",
      },
      {
        "<leader>gi",
        function()
          require("codecompanion").prompt("commit")
        end,
        mode = "n",
        noremap = true,
        silent = true,
        desc = "Git: generate commit message",
      },
    },

    init = function()
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
